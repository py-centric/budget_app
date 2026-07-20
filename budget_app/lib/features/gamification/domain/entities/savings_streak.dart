import 'package:equatable/equatable.dart';

class SavingsStreak extends Equatable {
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastSavingsDate;

  const SavingsStreak({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastSavingsDate,
  });

  factory SavingsStreak.fromMap(Map<String, dynamic> map) {
    return SavingsStreak(
      currentStreak: map['current_streak'] as int? ?? 0,
      longestStreak: map['longest_streak'] as int? ?? 0,
      lastSavingsDate: map['last_savings_date'] != null ? DateTime.parse(map['last_savings_date'] as String) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'last_savings_date': lastSavingsDate?.toIso8601String(),
    };
  }

  SavingsStreak copyWith({
    int? currentStreak,
    int? longestStreak,
    DateTime? lastSavingsDate,
  }) {
    return SavingsStreak(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastSavingsDate: lastSavingsDate ?? this.lastSavingsDate,
    );
  }

  @override
  List<Object?> get props => [currentStreak, longestStreak, lastSavingsDate];
}
