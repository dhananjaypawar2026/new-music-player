import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:play_music/features/music/album/models/album_model.dart';
import 'package:play_music/features/music/album/providers/album_details_provider.dart';

final artistAlbumDetailListProvider = Provider.autoDispose
    .family<List<AlbumModel>, String>((ref, artistName) {
      final List<AlbumModel> artistAlbumDetailsList = [];

      ref.read(albumDetailsProvider).forEach((albumDetail) {
        if (albumDetail.albumArtistName == artistName) {
          artistAlbumDetailsList.add(albumDetail);
        }
      });

      return artistAlbumDetailsList;
    });
