import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:play_music/core/constants/app_color_scheme.dart';
import 'package:play_music/l10n/generated/app_localizations.dart';

extension BuildContextExtensions on BuildContext {
  Size get screenSize {
    return MediaQuery.sizeOf(this);
  }

  GoRouter get router {
    return GoRouter.of(this);
  }

  AppLocalizations get localization {
    return AppLocalizations.of(this)!;
  }
}

extension BuildContextColorExtensions on BuildContext {
  Color get appBackgroundColor =>
      AppColorScheme.screenBackground.resolveFrom(this);

  Color get appSurfaceColor => AppColorScheme.surface.resolveFrom(this);

  Color get appPrimaryTextColor => AppColorScheme.primaryText.resolveFrom(this);

  Color get appSecondaryTextColor =>
      AppColorScheme.secondaryText.resolveFrom(this);

  Color get appInverseTextColor => AppColorScheme.inverseText.resolveFrom(this);

  Color get appOutlineColor => AppColorScheme.outline.resolveFrom(this);

  Color get appDeviceScreenBorderColor =>
      AppColorScheme.deviceScreenBorder.resolveFrom(this);

  Color get appDeviceScreenBackgroundColor =>
      AppColorScheme.deviceScreenBackground.resolveFrom(this);

  Color get appControlSurfaceColor =>
      AppColorScheme.controlSurface.resolveFrom(this);

  Color get appIconEmphasisColor =>
      AppColorScheme.iconEmphasis.resolveFrom(this);
}
