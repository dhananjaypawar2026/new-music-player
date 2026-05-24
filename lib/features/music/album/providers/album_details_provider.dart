import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:play_music/core/providers/filtered_audio_files_provider.dart';
import 'package:play_music/features/music/album/models/album_model.dart';

final albumDetailsProvider = Provider<List<AlbumModel>>((ref) {
  final List<AlbumModel> albumDetails = [];
  final metadataList = ref.read(filteredAudioFilesProvider).requireValue;

  for (int i = 0; i < metadataList.length; i++) {
    final albumDetail = AlbumModel(
      albumName: metadataList[i].getAlbumName,
      albumArtPath: metadataList[i].thumbnailPath,
      albumArtistName: metadataList[i].getAlbumArtistName,
      albumSongs: [metadataList[i]],
    );

    // If album does not exist, add the album
    if (!albumDetails.contains(albumDetail)) {
      albumDetails.add(albumDetail);
    }
    // If album already exists, add the song to the album
    else {
      final int existingIdx = albumDetails.indexWhere((e) => e == albumDetail);
      if (existingIdx != -1) {
        albumDetails[existingIdx].albumSongs.add(metadataList[i]);
      }
    }
  }

  // Sort the album details by artist name, album name
  albumDetails.sort((a, b) {
    final artistCompare = a.albumArtistName.compareTo(b.albumArtistName);
    if (artistCompare != 0) return artistCompare;
    return a.albumName.compareTo(b.albumName);
  });

  // Sort the songs in each album by track number
  for (final album in albumDetails) {
    album.albumSongs.sort(
      (a, b) => a.getTrackNumber.compareTo(b.getTrackNumber),
    );
  }

  return albumDetails;
});
