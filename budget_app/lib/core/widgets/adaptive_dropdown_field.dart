import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'adaptive_date_picker.dart';

bool _isPickerWheelPlatform(TargetPlatform platform) =>
    platform == TargetPlatform.iOS;

/// One entry of an [AdaptiveDropdownField].
///
/// `List<AdaptiveDropdownItem<T>>` is the DropdownMenuItem-compatible record
/// set from `contracts/adaptive_helpers_contract.md` section 5: a value, a
/// label widget and a required semantics label.
class AdaptiveDropdownItem<T extends Object> {
  /// Creates an item with a [value], a [label] widget and a [semanticsLabel].
  const AdaptiveDropdownItem({
    required this.value,
    required this.label,
    required this.semanticsLabel,
  });

  /// The value reported by [AdaptiveDropdownField.onChanged].
  final T value;

  /// The widget shown for this item on both branches.
  final Widget label;

  /// Accessibility label retained on both platform branches.
  final String semanticsLabel;
}

/// Platform-adaptive value-selection field
/// (`contracts/adaptive_helpers_contract.md` section 5).
///
/// On iOS the value picker opens as a [CupertinoPicker] wheel (itemExtent 36)
/// inside a [showCupertinoModalPopup] with a Done/Cancel bar, and the scroller
/// starts at the selected value via a [FixedExtentScrollController]. On
/// macOS/Android/web/Windows/Linux the Material [DropdownButtonFormField] is
/// rendered with the existing styling (dense-data menus are desktop-native,
/// research.md Decision 5).
///
/// The state flow is synchronous (standard `ValueChanged<T?>`): no Future-based
/// API change versus the plain Material dropdown, so Bloc event flows are
/// untouched. Values may be null (`T? value`); touch rows stay >= 48dp.
class AdaptiveDropdownField<T extends Object> extends StatelessWidget {
  /// Creates a dropdown field over [items] with the given [value].
  const AdaptiveDropdownField({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    this.decoration,
    this.hint,
    this.menuMaxHeight,
  });

  /// The selectable items, in display order.
  final List<AdaptiveDropdownItem<T>> items;

  /// The currently selected value, or null when nothing is selected.
  final T? value;

  /// Fires with the newly selected value.
  final ValueChanged<T?> onChanged;

  /// Material-branch input decoration.
  final InputDecoration? decoration;

  /// Shown when [value] is null.
  final Widget? hint;

  /// Material-branch menu height limit.
  final double? menuMaxHeight;

  @override
  Widget build(BuildContext context) {
    if (!_isPickerWheelPlatform(Theme.of(context).platform)) {
      return DropdownButtonFormField<T>(
        key: ValueKey<T?>(value),
        initialValue: value,
        decoration: decoration,
        hint: hint,
        menuMaxHeight: menuMaxHeight,
        items: <DropdownMenuItem<T>>[
          for (final AdaptiveDropdownItem<T> item in items)
            DropdownMenuItem<T>(value: item.value, child: item.label),
        ],
        onChanged: onChanged,
      );
    }
    return _CupertinoDropdownField<T>(
      items: items,
      value: value,
      onChanged: onChanged,
      hint: hint,
    );
  }
}

class _CupertinoDropdownField<T extends Object> extends StatelessWidget {
  const _CupertinoDropdownField({
    required this.items,
    required this.value,
    required this.onChanged,
    required this.hint,
  });

  final List<AdaptiveDropdownItem<T>> items;
  final T? value;
  final ValueChanged<T?> onChanged;
  final Widget? hint;

  Future<void> _openPicker(BuildContext context) async {
    int initialIndex = items.indexWhere(
      (AdaptiveDropdownItem<T> item) => item.value == value,
    );
    if (initialIndex < 0) {
      initialIndex = 0;
    }
    T picked = items[initialIndex].value;
    await showCupertinoModalPopup<void>(
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
                  onDone: () {
                    onChanged(picked);
                    Navigator.of(popupContext).pop();
                  },
                ),
                SizedBox(
                  height: 216,
                  child: CupertinoPicker(
                    itemExtent: 36,
                    scrollController: FixedExtentScrollController(
                      initialItem: initialIndex,
                    ),
                    onSelectedItemChanged: (int index) =>
                        picked = items[index].value,
                    children: <Widget>[
                      for (final AdaptiveDropdownItem<T> item in items)
                        Center(
                          heightFactor: 1,
                          child: Semantics(
                            label: item.semanticsLabel,
                            child: item.label,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final AdaptiveDropdownItem<T>? selected = items.cast<AdaptiveDropdownItem<T>?>().firstWhere(
          (AdaptiveDropdownItem<T>? item) => item?.value == value,
          orElse: () => null,
        );
    return Semantics(
      button: true,
      label: selected?.semanticsLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _openPicker(context),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: CupertinoColors.separator),
            ),
          ),
          child: selected != null ? selected.label : (hint ?? const SizedBox.shrink()),
        ),
      ),
    );
  }
}
