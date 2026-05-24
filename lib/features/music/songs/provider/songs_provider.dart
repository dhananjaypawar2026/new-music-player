import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:play_music/core/models/music_metadata.dart';
import 'package:play_music/core/providers/filtered_audio_files_provider.dart';

final songsProvider = Provider<List<MusicMetadata>>((ref) {
  final metadataList = ref
      .read(filteredAudioFilesProvider)
      .requireValue
      .toList();
  metadataList.sort((a, b) => a.getTrackName.compareTo(b.getTrackName));
  return metadataList;
});
