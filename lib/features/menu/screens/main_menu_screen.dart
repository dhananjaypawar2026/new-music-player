import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:play_music/core/extensions/build_context_extensions.dart';
import 'package:play_music/core/navigation/routes.dart';
import 'package:play_music/core/providers/filtered_audio_files_provider.dart';
import 'package:play_music/core/services/audio_files_service.dart';
import 'package:play_music/core/services/audio_player_service.dart';
import 'package:play_music/core/widgets/display_list_tile.dart';
import 'package:play_music/features/custom_screen_elements/custom_screen.dart';
import 'package:play_music/features/menu/controller/split_screen_controller.dart';
import 'package:play_music/features/menu/models/split_screen_type.dart';
import 'package:play_music/features/music/album/providers/album_details_provider.dart';
import 'package:play_music/features/music/artists/providers/artist_names_provider.dart';
import 'package:play_music/features/music/genres/providers/genres_provider.dart';
import 'package:play_music/features/music/playlist/providers/playlists_provider.dart';
import 'package:play_music/features/music/songs/provider/songs_provider.dart';
import 'package:play_music/features/status_bar/widgets/status_bar.dart';
import 'package:play_music/features/tutorial/controller/tutorial_controller.dart';

enum _MainMenuDisplayItems {
  music,
  importMusic,
  settings,
  shuffleSongs,
  nowPlaying;

  String title(BuildContext context) {
    switch (this) {
      case music:
        return context.localization.musicMenuScreenTitle;
      case importMusic:
        return 'Import Music';
      case settings:
        return context.localization.settingsScreenTitle;
      case shuffleSongs:
        return context.localization.shuffleSongsMenuTitle;
      case nowPlaying:
        return context.localization.nowPlayingScreenTitle;
    }
  }
}

class MainMenuScreen extends ConsumerStatefulWidget {
  final bool showTutorial;

  const MainMenuScreen({super.key, this.showTutorial = false});

  @override
  ConsumerState createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends ConsumerState<MainMenuScreen>
    with CustomScreen {
  @override
  String get routeName => Routes.menu.name;

  @override
  List<_MainMenuDisplayItems> get displayItems => _MainMenuDisplayItems.values;

  @override
  void onMenuButtonPressed() {
    return;
  }

  @override
  Future<void> onSelectPressed() =>
      _navigateToScreen(_MainMenuDisplayItems.values[selectedDisplayItem]);

  Future<void> _navigateToScreen(_MainMenuDisplayItems menuItem) async {
    setState(() => selectedDisplayItem = displayItems.indexOf(menuItem));
    switch (menuItem) {
      case _MainMenuDisplayItems.music:
        context.goNamed(Routes.musicMenu.name);
        break;
      case _MainMenuDisplayItems.importMusic:
        await _importMusic();
        break;
      case _MainMenuDisplayItems.nowPlaying:
        await _navigateToNowPlayingScreen();
        break;
      case _MainMenuDisplayItems.settings:
        context.goNamed(Routes.settings.name);
        break;
      case _MainMenuDisplayItems.shuffleSongs:
        await ref.read(audioPlayerServiceProvider.notifier).shuffleAllSongs();
        await _navigateToNowPlayingScreen();
        break;
    }
  }

  Future<void> _importMusic() async {
    // Trigger the file import
    await ref
        .read(audioFilesServiceProvider.notifier)
        .importMusicFiles();

    // Re-read the newly imported tracks
    final importedTracks = ref.read(audioFilesServiceProvider).asData?.value;
    if (importedTracks != null && importedTracks.isNotEmpty) {
      // Update the audio player with the new track list
      await ref
          .read(audioPlayerServiceProvider.notifier)
          .setAudioSource(musicMetadataList: importedTracks.toList());

      // Refresh all music-related providers
      ref.invalidate(albumDetailsProvider);
      ref.invalidate(artistNamesProvider);
      ref.invalidate(songsProvider);
      ref.invalidate(playlistsProvider);
      ref.invalidate(genresProvider);
      ref.invalidate(filteredAudioFilesProvider);
    }
  }

  Future<void> _navigateToNowPlayingScreen() async {
    unawaited(ref.read(splitScreenViewControllerProvider).closeSplitView());
    await context.pushNamed(Routes.nowPlaying.name, extra: Routes.menu.name);
    unawaited(ref.read(splitScreenViewControllerProvider).openSplitView());
  }

  Future<void> _changeSplitScreenType() async {
    await Future.delayed(const Duration(milliseconds: 150));
    switch (displayItems[selectedDisplayItem]) {
      case _MainMenuDisplayItems.music:
        ref.read(splitScreenControllerProvider.notifier).changeSplitScreenType =
            SplitScreenType.albumArt;
        break;
      case _MainMenuDisplayItems.importMusic:
        ref.read(splitScreenControllerProvider.notifier).changeSplitScreenType =
            SplitScreenType.albumArt;
        break;
      case _MainMenuDisplayItems.settings:
        ref.read(splitScreenControllerProvider.notifier).changeSplitScreenType =
            SplitScreenType.settings;
        break;
      case _MainMenuDisplayItems.shuffleSongs:
        ref.read(splitScreenControllerProvider.notifier).changeSplitScreenType =
            SplitScreenType.shuffle;
        break;
      case _MainMenuDisplayItems.nowPlaying:
        ref.read(splitScreenControllerProvider.notifier).changeSplitScreenType =
            SplitScreenType.nowPlaying;
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(tutorialControllerProvider.notifier).playMenuTutorial();
    });
  }

  @override
  void didUpdateWidget(covariant MainMenuScreen oldWidget) {
    if (widget.showTutorial) {
      ref.read(tutorialControllerProvider.notifier).playMenuTutorial();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    unawaited(_changeSplitScreenType());
    if (!ref.read(splitScreenViewControllerProvider).isScreenVisible) {
      unawaited(ref.read(splitScreenViewControllerProvider).openSplitView());
    }

    return CupertinoPageScaffold(
      child: Column(
        children: [
          StatusBar(title: Routes.menu.title(context)),
          Expanded(
            child: CupertinoScrollbar(
              controller: scrollController,
              child: ListView.builder(
                controller: scrollController,
                itemCount: displayItems.length,
                prototypeItem: const DisplayListTile(
                  text: '',
                  isSelected: false,
                ),
                itemBuilder: (context, index) {
                  return DisplayListTile(
                    key: ValueKey(displayItems[index]),
                    text: displayItems[index].title(context),
                    isSelected: selectedDisplayItem == index,
                    onTap: () async => _navigateToScreen(displayItems[index]),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
