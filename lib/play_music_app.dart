import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:play_music/core/extensions/build_context_extensions.dart';
import 'package:play_music/core/navigation/routes.dart';
import 'package:play_music/features/settings/controller/settings_preferences_controller.dart';
import 'package:play_music/l10n/generated/app_localizations.dart';

class PlayMusicApp extends ConsumerWidget {
  const PlayMusicApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageLocaleCode = ref.watch(
      settingsPreferencesControllerProvider.select(
        (value) => value.languageLocaleCode,
      ),
    );
    final appTheme = ref.watch(
      settingsPreferencesControllerProvider.select((value) => value.appTheme),
    );
    final router = ref.watch(routerProvider);
    return CupertinoApp.router(
      onGenerateTitle: (context) => context.localization.appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      locale: Locale(languageLocaleCode),
      theme: appTheme.toCupertinoTheme(),
    );
  }
}
