// Stub for on_audio_query package on web.
// This class is never called on web (all usage is behind !kIsWeb guards).
class OnAudioQuery {
  Future<List<SongModel>> querySongs() async => [];
}

class SongModel {
  String get data => '';
}
