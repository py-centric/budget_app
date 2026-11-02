import 'package:budget_app/core/localization/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

bool _isCupertinoPlatform(TargetPlatform platform) =>
    platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;

/// Shared Done/Cancel action bar for Cupertino picker popups.
///
/// Labels resolve through [AppLocalizations] (`done`/`cancel` keys, mirrored in
/// `lib/core/localization/l10n/app_en.arb`), so no string is hard-coded here.
class AdaptivePickerActionBar extends StatelessWidget {
  /// Creates the bar with [onCancel] and [onDone] callbacks.
  const AdaptivePickerActionBar({
    super.key,
    required this.onCancel,
    required this.onDone,
  });

  /// Dismisses the picker without a value.
  final VoidCallback onCancel;

  /// Confirms the currently picked value.
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        CupertinoButton(
          onPressed: onCancel,
          child: Text(localizations.translate('cancel')),
        ),
        CupertinoButton(
          onPressed: onDone,
          child: Text(localizations.translate('done')),
        ),
      ],
    );
  }
}

/// Shows a platform-adaptive date picker
/// (`contracts/adaptive_helpers_contract.md` section 3).
///
/// Apple platforms host a [CupertinoDatePicker] (date wheel) inside a
/// [showCupertinoModalPopup] with a Done/Cancel bar; [firstDate]/[lastDate] map
/// to `minimumDate`/`maximumDate`. All other platforms call the Material
/// [showDatePicker] unchanged.
///
/// Confirm semantics: the wheel fires `onDateTimeChanged` continuously, but the
/// returned Future resolves ONLY on Done (with the last selected value) or
/// Cancel (`null`). This preserves the Material confirm-then-return protocol so
/// no call site needs a platform branch. The helper reads no live clock: the
/// wheel initial value equals [initialDate] truncated to the day.
Future<DateTime?> showAdaptiveDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
  DatePickerEntryMode initialEntryMode = DatePickerEntryMode.calendar,
  Locale? locale,
  RouteSettings? routeSettings,
}) {
  if (!_isCupertinoPlatform(Theme.of(context).platform)) {
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      initialEntryMode: initialEntryMode,
      locale: locale,
      routeSettings: routeSettings,
    );
  }

  DateTime picked = DateTime(initialDate.year, initialDate.month, initialDate.day);
  return showCupertinoModalPopup<DateTime>(
    context: context,
    routeSettings: routeSettings,
    builder: (BuildContext popupContext) {
      return CupertinoPopupSurface(
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              AdaptivePickerActionBar(
                onCancel: () => Navigator.of(popupContext).pop(),
                onDone: () => Navigator.of(popupContext).pop(picked),
              ),
              SizedBox(
                height: 216,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: picked,
                  minimumDate: firstDate,
                  maximumDate: lastDate,
                  onDateTimeChanged: (DateTime value) => picked = value,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// Shows a platform-adaptive time picker
/// (`contracts/adaptive_helpers_contract.md` section 4).
///
/// Apple platforms host a [CupertinoDatePicker] in time mode inside a popup and
/// convert `TimeOfDay` <-> `DateTime` internally on a fixed anchor day (no live
/// clock reads). All other platforms call the Material [showTimePicker]
/// unchanged.
Future<TimeOfDay?> showAdaptiveTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
}) {
  if (!_isCupertinoPlatform(Theme.of(context).platform)) {
    return showTimePicker(context: context, initialTime: initialTime);
  }

  final DateTime anchor = DateTime(2000, 1, 1, initialTime.hour, initialTime.minute);
  DateTime picked = anchor;
  return showCupertinoModalPopup<TimeOfDay>(
    context: context,
    builder: (BuildContext popupContext) {
      return CupertinoPopupSurface(
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              AdaptivePickerActionBar(
                onCancel: () => Navigator.of(popupContext).pop(),
                onDone: () => Navigator.of(popupContext).pop(
                      TimeOfDay.fromDateTime(picked),
                    ),
              ),
              SizedBox(
                height: 216,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  use24hFormat:
                      MediaQuery.of(popupContext).alwaysUse24HourFormat,
                  initialDateTime: anchor,
                  onDateTimeChanged: (DateTime value) => picked = value,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
