import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:play_music/core/extensions/build_context_extensions.dart';
import 'package:play_music/core/extensions/go_router_extensions.dart';
import 'package:play_music/core/navigation/routes.dart';
import 'package:play_music/core/providers/filtered_audio_files_provider.dart';
import 'package:play_music/features/device/models/device_action.dart';
import 'package:play_music/features/device/services/device_buttons_service_provider.dart';
import 'package:play_music/features/music/album/providers/album_details_provider.dart';
import 'package:play_music/features/music/artists/providers/artist_names_provider.dart';
import 'package:play_music/features/settings/widgets/about_list_tile.dart';
import 'package:play_music/features/status_bar/widgets/status_bar.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(deviceButtonsServiceProvider, (prevState, newState) {
      if (newState == null ||
          context.router.locationNamed != Routes.about.name) {
        return;
      } else if (newState == DeviceAction.menu) {
        context.pop();
      }
    });

    return CupertinoPageScaffold(
      child: Column(
        children: [
          StatusBar(title: Routes.about.title(context)),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  context.localization.appTitle,
                  style: CupertinoTheme.of(context).textTheme.textStyle
                      .copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: context.appPrimaryTextColor,
                      ),
                ),
                const SizedBox(height: 10),
                AboutListTile(
                  titleText: context.localization.songsScreenTitle,
                  valueText:
                      "${ref.read(filteredAudioFilesProvider).requireValue.length}",
                ),
                AboutListTile(
                  titleText: context.localization.artistsScreenTitle,
                  valueText: "${ref.read(artistNamesProvider).length}",
                ),
                AboutListTile(
                  titleText: context.localization.albumsScreenTitle,
                  valueText: "${ref.read(albumDetailsProvider).length}",
                ),
                AboutListTile(
                  titleText: context.localization.versionAboutScreenTitle,
                  valueText: "1.12.0",
                ),
                AboutListTile(
                  titleText: context.localization.madeWithLoveTitle,
                  valueText: "Dhananjay Pawar",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
