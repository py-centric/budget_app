import 'package:budget_app/core/localization/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

bool _isCupertinoPlatform(TargetPlatform platform) =>
    platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;

/// Shows a platform-adaptive modal sheet
/// (`contracts/adaptive_helpers_contract.md` section 1).
///
/// Apple platforms (iOS and macOS via `Theme.of(context).platform`) route
/// through [showCupertinoModalPopup] with an iOS-style popup surface and
/// barrier dismissal semantics per iOS conventions; all other platforms route
/// through [showModalBottomSheet] with the current theme styling.
///
/// The returned future resolves `null` on dismiss/Cancel on both branches and
/// resolves `T` on user action. Keyboard insets remain the caller's
/// responsibility because popup sheets ignore `bottomSheetTheme`.
///
/// Any [l10nTitleKey] header label is resolved through [AppLocalizations] and
/// MUST also exist in `lib/core/localization/l10n/app_en.arb`. Colors are never
/// hard-coded: [backgroundColor] is passed through and the rest comes from the
/// ambient theme.
Future<T?> showAdaptiveModalSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool useSafeArea = true,
  bool isDismissible = true,
  bool enableDrag = true,
  Color? backgroundColor,
  String? l10nTitleKey,
  RouteSettings? routeSettings,
}) {
  if (_isCupertinoPlatform(Theme.of(context).platform)) {
    return showCupertinoModalPopup<T>(
      context: context,
      routeSettings: routeSettings,
      barrierDismissible: isDismissible,
      builder: (BuildContext popupContext) {
        Widget content = builder(popupContext);
        if (l10nTitleKey != null) {
          content = Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Text(
                  AppLocalizations.of(popupContext).translate(l10nTitleKey),
                  style: Theme.of(popupContext).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              content,
            ],
          );
        }
        if (useSafeArea) {
          content = SafeArea(top: false, child: content);
        }
        if (backgroundColor != null) {
          content = ColoredBox(color: backgroundColor, child: content);
        }
        return CupertinoPopupSurface(child: content);
      },
    );
  }
  return showModalBottomSheet<T>(
    context: context,
    routeSettings: routeSettings,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    useSafeArea: useSafeArea,
    backgroundColor: backgroundColor,
    builder: builder,
  );
}
