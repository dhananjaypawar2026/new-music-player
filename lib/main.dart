import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:play_music/core/constants/app_palette.dart';
import 'package:play_music/features/app_startup/screens/app_startup_screen.dart';
import 'package:play_music/play_music_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: AppPalette.transparentColor,
      statusBarColor: AppPalette.transparentColor,
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  runApp(const ProviderScope(child: AppStartupScreen(app: PlayMusicApp())));
}
