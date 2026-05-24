import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:play_music/core/constants/app_palette.dart';
import 'package:play_music/core/navigation/routes.dart';
import 'package:play_music/features/custom_screen_elements/custom_screen.dart';
import 'package:play_music/features/settings/controller/settings_preferences_controller.dart';
import 'package:play_music/features/settings/models/device_color.dart';
import 'package:play_music/features/status_bar/widgets/status_bar.dart';

class DeviceColorSelectionScreen extends ConsumerStatefulWidget {
  const DeviceColorSelectionScreen({super.key});

  @override
  ConsumerState createState() => _DeviceColorSelectionScreenState();
}

class _DeviceColorSelectionScreenState extends ConsumerState with CustomScreen {
  @override
  String get routeName => Routes.deviceColor.name;

  @override
  List<DeviceColor> get displayItems => DeviceColor.values;

  @override
  Future<void> onSelectPressed() => _selectColor(selectedDisplayItem);

  Future<void> _selectColor(int index) async {
    setState(() => selectedDisplayItem = index);
    await ref
        .read(settingsPreferencesControllerProvider.notifier)
        .setDeviceColor(displayItems[index]);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Column(
        children: [
          StatusBar(title: Routes.deviceColor.title(context)),
          Flexible(
            child: CupertinoScrollbar(
              controller: scrollController,
              child: ListView.builder(
                controller: scrollController,
                itemCount: displayItems.length,
                prototypeItem: _DeviceColorOptionTile(
                  deviceColor: displayItems.first,
                  isSelected: false,
                  onTap: () {},
                ),
                itemBuilder: (context, index) {
                  final deviceColor = displayItems[index];
                  final isSelected = selectedDisplayItem == index;
                  return _DeviceColorOptionTile(
                    deviceColor: deviceColor,
                    isSelected: isSelected,
                    onTap: () async => _selectColor(index),
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

class _DeviceColorOptionTile extends StatelessWidget {
  final DeviceColor deviceColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _DeviceColorOptionTile({
    required this.deviceColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final deviceColorStyle = deviceColor.style;
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 30,
        width: double.infinity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: isSelected
                ? const Border(
                    top: BorderSide(
                      color: AppPalette.selectedTileTopBorderColor,
                    ),
                    bottom: BorderSide(
                      color: AppPalette.selectedTileBottomBorderColor,
                    ),
                  )
                : null,
            gradient: isSelected
                ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppPalette.selectedTileGradientColor1,
                      AppPalette.selectedTileGradientColor2,
                    ],
                  )
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: deviceColorStyle.frameGradientColors,
                    ),
                    border: Border.all(
                      color: deviceColorStyle.controlBorderColor,
                      width: 1.5,
                    ),
                  ),
                  child: const SizedBox(height: 18, width: 18),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    deviceColor.title(context),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? CupertinoColors.white
                          : CupertinoColors.black,
                    ),
                    maxLines: 1,
                  ),
                ),
                if (isSelected)
                  const Icon(
                    CupertinoIcons.right_chevron,
                    color: CupertinoColors.white,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
