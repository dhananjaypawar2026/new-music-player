import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io' if (dart.library.html) 'package:play_music/core/stubs/io_stub.dart';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:on_audio_query/on_audio_query.dart'
    if (dart.library.html) 'package:play_music/core/stubs/on_audio_query_stub.dart';
import 'package:play_music/core/constants/constants.dart';
import 'package:play_music/core/constants/online_audio_files_metadata.dart';
import 'package:play_music/core/models/music_metadata.dart';
import 'package:play_music/core/providers/device_directory_provider.dart';
import 'package:play_music/core/repositories/metadata_reader_repository.dart';
import 'package:play_music/features/settings/controller/settings_preferences_controller.dart';
import 'package:universal_html/html.dart' as html;


final audioFilesServiceProvider =
    AsyncNotifierProvider<
      AudioFilesServiceNotifier,
      UnmodifiableListView<MusicMetadata>
    >(AudioFilesServiceNotifier.new);

class AudioFilesServiceNotifier
    extends AsyncNotifier<UnmodifiableListView<MusicMetadata>> {
  @override
  Future<UnmodifiableListView<MusicMetadata>> build() async {
    return getAudioFilesMetadata();
  }

  Future<UnmodifiableListView<MusicMetadata>> getAudioFilesMetadata() async {
    state = const AsyncLoading();
    try {
      if (ref.read(settingsPreferencesControllerProvider).fetchOnlineMusic) {
        return UnmodifiableListView(onlineDemoAudioFilesMetaData);
      }
      // Fetch metadata from local files
      else {
        final Box<MusicMetadata> metadataBox = Hive.box<MusicMetadata>(
          Constants.metadataBoxName,
        );
        // Check if the metadata box is empty
        if (metadataBox.isEmpty) {
          if (kIsWeb) {
            // On web: let the user pick audio files via the browser file picker
            return await _pickAudioFilesOnWeb(metadataBox);
          } else if (Platform.isWindows ||
              Platform.isLinux ||
              Platform.isMacOS) {
            final newDirectory = await FilePicker.platform.getDirectoryPath(
              dialogTitle: 'Select Music Directory',
              lockParentWindow: true,
              initialDirectory: ref
                  .read(deviceDirectoryProvider)
                  .requireValue
                  .musicFolderPath,
            );
            if (newDirectory != null) {
              final result = await compute(
                ref
                    .read(metadataReaderRepositoryProvider)
                    .extractMetadataFromDirectory,
                newDirectory,
              );
              await metadataBox.addAll(result);
              return UnmodifiableListView(result);
            } else {
              return UnmodifiableListView([]);
            }
          } else if (Platform.isIOS) {
            final pickedFiles = await FilePicker.platform.pickFiles(
              allowMultiple: true,
              dialogTitle: 'Pick Song Files',
            );

            if (pickedFiles == null || pickedFiles.files.isEmpty) {
              return UnmodifiableListView([]);
            }

            final result = await compute(
              ref
                  .read(metadataReaderRepositoryProvider)
                  .extractMetadataFromFiles,
              pickedFiles.files.map((f) => f.path!).toList(),
            );

            await metadataBox.addAll(result);
            return UnmodifiableListView(result);
          }
          // On Android Automatically Fetch Music Files
          else {
            final OnAudioQuery audioQuery = OnAudioQuery();
            final queriedSongs = await audioQuery.querySongs();

            final result = await compute(
              ref
                  .read(metadataReaderRepositoryProvider)
                  .extractMetadataFromFiles,
              queriedSongs.map((e) => e.data).toList(growable: false),
            );
            await metadataBox.addAll(result);
            return UnmodifiableListView(result);
          }
        }
        // Return cached metadata
        else {
          return UnmodifiableListView(metadataBox.values);
        }
      }
    } catch (e) {
      return UnmodifiableListView([]);
    }
  }

  /// Pick audio files on web using the browser file picker.
  /// Creates MusicMetadata with blob URLs for web playback.
  Future<UnmodifiableListView<MusicMetadata>> _pickAudioFilesOnWeb(
    Box<MusicMetadata> metadataBox,
  ) async {
    final pickedFiles = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.audio,
      withData: true,
    );

    if (pickedFiles == null || pickedFiles.files.isEmpty) {
      return UnmodifiableListView([]);
    }

    final List<MusicMetadata> result = [];
    int index = 0;

    for (final file in pickedFiles.files) {
      try {
        if (file.bytes == null) continue;
        // Create a blob URL for web playback
        final blobUrl = _createBlobUrl(file.bytes!, file.name);
        // Extract a clean track name from the filename
        final trackName = _fileNameToTrackName(file.name);
        result.add(
          MusicMetadata(
            trackName: trackName,
            trackArtistNames: ['Unknown Artist'],
            albumName: 'Unknown Album',
            albumArtistName: 'Unknown Artist',
            genres: const [],
            filePath: blobUrl,
            originalSongIndex: index,
            isOnDevice: false,
          ),
        );
        index++;
      } catch (e) {
        debugPrint('Web file import error: $e');
      }
    }

    // Note: we don't persist to Hive on web (blob URLs are session-only)
    return UnmodifiableListView(result);
  }

  String _fileNameToTrackName(String fileName) {
    // Remove extension
    final dot = fileName.lastIndexOf('.');
    final name = dot > 0 ? fileName.substring(0, dot) : fileName;
    return name;
  }

  String _createBlobUrl(Uint8List bytes, String fileName) {
    // Determine MIME type from extension
    final ext = fileName.toLowerCase().split('.').last;
    final mimeTypes = {
      'mp3': 'audio/mpeg',
      'wav': 'audio/wav',
      'ogg': 'audio/ogg',
      'flac': 'audio/flac',
      'm4a': 'audio/mp4',
      'aac': 'audio/aac',
      'opus': 'audio/ogg; codecs=opus',
    };
    final mime = mimeTypes[ext] ?? 'audio/mpeg';

    if (kIsWeb) {
      final blob = html.Blob([bytes], mime);
      return html.Url.createObjectUrlFromBlob(blob);
    }

    final base64 = base64Encode(bytes);
    return 'data:$mime;base64,$base64';
  }

  /// Import additional music files (can be called from menu).
  Future<void> importMusicFiles() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      if (kIsWeb) {
        final Box<MusicMetadata> metadataBox = Hive.box<MusicMetadata>(
          Constants.metadataBoxName,
        );
        // On web we always show the picker (blob URLs are session-only)
        final newTracks = await _pickAudioFilesOnWeb(metadataBox);
        final existing =
            state.valueOrNull ?? UnmodifiableListView<MusicMetadata>([]);
        final combined = [
          ...existing,
          ...newTracks.map(
            (t) => t.copyWith(originalSongIndex: existing.length + newTracks.indexOf(t)),
          ),
        ];
        return UnmodifiableListView(combined);
      } else {
        // On native platforms, clear the cache and re-scan
        final Box<MusicMetadata> metadataBox = Hive.box<MusicMetadata>(
          Constants.metadataBoxName,
        );
        await metadataBox.clear();
        return getAudioFilesMetadata();
      }
    });
  }
}
