import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

bool _isCupertinoPlatform(TargetPlatform platform) =>
    platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;

/// One segment of an [AdaptiveSegmentedControl].
///
/// [semanticsLabel] is required so both branches keep screen-reader parity
/// (`contracts/adaptive_helpers_contract.md` section 2).
class AdaptiveSegment<T extends Object> {
  /// Creates a segment with a [value], a [label] widget (icon and/or short
  /// text per HIG) and a required [semanticsLabel].
  const AdaptiveSegment({
    required this.value,
    required this.label,
    required this.semanticsLabel,
  });

  /// The value reported by [AdaptiveSegmentedControl.onChanged].
  final T value;

  /// Icon and/or short text shown for this segment.
  final Widget label;

  /// Accessibility label retained on both platform branches.
  final String semanticsLabel;
}

/// Platform-adaptive single-select segmented control
/// (`contracts/adaptive_helpers_contract.md` section 2).
///
/// Apple platforms (iOS and macOS) render a [CupertinoSlidingSegmentedControl]
/// with explicit colors derived from the ambient [ColorScheme] (thumb
/// `primary`, track `surfaceContainerLow`, foreground `onPrimary`/`onSurface`),
/// because the Cupertino control does not bridge Material colors
/// automatically. All other platforms render a Material [SegmentedButton].
///
/// Single-select only. Text scaling is clamped on the Cupertino branch so
/// narrow 3-4 segment rows can never overflow.
class AdaptiveSegmentedControl<T extends Object> extends StatelessWidget {
  /// Creates a single-select segmented control from [segments].
  const AdaptiveSegmentedControl({
    super.key,
    required this.segments,
    required this.selected,
    required this.onChanged,
  });

  /// The selectable segments, in display order.
  final List<AdaptiveSegment<T>> segments;

  /// The currently selected value.
  final T selected;

  /// Fires with the newly selected value.
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    if (!_isCupertinoPlatform(theme.platform)) {
      return SegmentedButton<T>(
        showSelectedIcon: false,
        segments: <ButtonSegment<T>>[
          for (final AdaptiveSegment<T> segment in segments)
            ButtonSegment<T>(
              value: segment.value,
              label: Semantics(
                label: segment.semanticsLabel,
                child: segment.label,
              ),
            ),
        ],
        selected: <T>{selected},
        onSelectionChanged: (Set<T> selection) => onChanged(selection.first),
      );
    }

    final ColorScheme scheme = theme.colorScheme;
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.3,
      child: CupertinoSlidingSegmentedControl<T>(
        groupValue: selected,
        onValueChanged: onChanged,
        thumbColor: scheme.primary,
        backgroundColor: scheme.surfaceContainerLow,
        children: <T, Widget>{
          for (final AdaptiveSegment<T> segment in segments)
            segment.value: Semantics(
              label: segment.semanticsLabel,
              child: DefaultTextStyle(
                style: DefaultTextStyle.of(context).style.copyWith(
                      color: segment.value == selected
                          ? scheme.onPrimary
                          : scheme.onSurface,
                    ),
                child: segment.label,
              ),
            ),
        },
      ),
    );
  }
}
