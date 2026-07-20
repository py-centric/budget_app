import 'package:equatable/equatable.dart';

class AccessibilitySettings extends Equatable {
  final bool highContrast;
  final double fontSize;
  final bool reduceMotion;

  const AccessibilitySettings({
    this.highContrast = false,
    this.fontSize = 14.0,
    this.reduceMotion = false,
  });

  factory AccessibilitySettings.fromMap(Map<String, dynamic> map) {
    return AccessibilitySettings(
      highContrast: map['high_contrast'] as bool? ?? false,
      fontSize: (map['font_size'] as num? ?? 14).toDouble(),
      reduceMotion: map['reduce_motion'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'high_contrast': highContrast,
      'font_size': fontSize,
      'reduce_motion': reduceMotion,
    };
  }

  AccessibilitySettings copyWith({
    bool? highContrast,
    double? fontSize,
    bool? reduceMotion,
  }) {
    return AccessibilitySettings(
      highContrast: highContrast ?? this.highContrast,
      fontSize: fontSize ?? this.fontSize,
      reduceMotion: reduceMotion ?? this.reduceMotion,
    );
  }

  @override
  List<Object?> get props => [highContrast, fontSize, reduceMotion];
}
