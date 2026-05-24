import 'package:hive_ce/hive.dart';
import 'package:play_music/core/models/music_metadata.dart';
import 'package:play_music/features/music/playlist/models/playlist_model.dart';
import 'package:play_music/features/settings/models/exclude_directory_model.dart';

part 'hive_adapters.g.dart';

@GenerateAdapters([
  AdapterSpec<MusicMetadata>(),
  AdapterSpec<PlaylistModel>(),
  AdapterSpec<ExcludeDirectoryModel>(),
])
class HiveAdapters {}
