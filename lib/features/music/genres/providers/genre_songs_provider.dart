import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:play_music/core/models/music_metadata.dart';
import 'package:play_music/core/providers/filtered_audio_files_provider.dart';

final genreSongsMetadataListProvider = Provider.autoDispose
    .family<List<MusicMetadata>, String>((ref, genreName) {
      final List<MusicMetadata> genreSongsMetadataList = [];

      ref.read(filteredAudioFilesProvider).requireValue.forEach((metadata) {
        if (metadata.genres.contains(genreName)) {
          genreSongsMetadataList.add(metadata);
        }
      });

      return genreSongsMetadataList;
    });
