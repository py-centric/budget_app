import 'dart:ui';
import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:intl/intl.dart';
import 'package:budget_app/features/settings/data/models/user_settings.dart';

// Events
/// Base event for settings changes.
/// Concrete subclasses represent currency, theme, and initialization actions.
abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class UpdateCurrencyEvent extends SettingsEvent {
  final String currencyCode;

  const UpdateCurrencyEvent(this.currencyCode);

  @override
  List<Object?> get props => [currencyCode];
}

class UpdateThemeEvent extends SettingsEvent {
  final String themeMode;

  const UpdateThemeEvent(this.themeMode);

  @override
  List<Object?> get props => [themeMode];
}

class UpdateSeedColorEvent extends SettingsEvent {
  final int color;

  const UpdateSeedColorEvent(this.color);

  @override
  List<Object?> get props => [color];
}

class UpdateIncomeColorEvent extends SettingsEvent {
  final int color;

  const UpdateIncomeColorEvent(this.color);

  @override
  List<Object?> get props => [color];
}

class UpdateExpenseColorEvent extends SettingsEvent {
  final int color;

  const UpdateExpenseColorEvent(this.color);

  @override
  List<Object?> get props => [color];
}

class InitializeSettingsEvent extends SettingsEvent {
  const InitializeSettingsEvent();
}

// States
/// Holds the current application settings (currency, theme, week start day).
/// Persisted automatically via HydratedBloc.
class SettingsState extends Equatable {
  final UserSettings settings;

  const SettingsState({this.settings = const UserSettings()});

  SettingsState copyWith({UserSettings? settings}) {
    return SettingsState(settings: settings ?? this.settings);
  }

  @override
  List<Object?> get props => [settings];

  Map<String, dynamic> toMap() {
    return {'settings': settings.toMap()};
  }

  factory SettingsState.fromMap(Map<String, dynamic> map) {
    return SettingsState(
      settings: UserSettings.fromMap(map['settings'] as Map<String, dynamic>),
    );
  }
}

// Bloc
/// Manages user preferences such as currency and theme.
/// Persists state to disk via HydratedBloc and auto-detects locale currency.
class SettingsBloc extends HydratedBloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(const SettingsState()) {
    on<UpdateCurrencyEvent>((event, emit) {
      emit(
        state.copyWith(
          settings: state.settings.copyWith(currencyCode: event.currencyCode),
        ),
      );
    });

    on<UpdateThemeEvent>((event, emit) {
      emit(
        state.copyWith(
          settings: state.settings.copyWith(themeMode: event.themeMode),
        ),
      );
    });

    on<UpdateSeedColorEvent>((event, emit) {
      emit(
        state.copyWith(
          settings: state.settings.copyWith(seedColor: event.color),
        ),
      );
    });

    on<UpdateIncomeColorEvent>((event, emit) {
      emit(
        state.copyWith(
          settings: state.settings.copyWith(incomeColor: event.color),
        ),
      );
    });

    on<UpdateExpenseColorEvent>((event, emit) {
      emit(
        state.copyWith(
          settings: state.settings.copyWith(expenseColor: event.color),
        ),
      );
    });

    on<InitializeSettingsEvent>((event, emit) {
      // Logic: If currencyCode is the default USD, try to detect from locale.
      // This will only run once effectively because HydratedBloc will persist the detected value.

      final locale = PlatformDispatcher.instance.locale;
      final format = NumberFormat.simpleCurrency(locale: locale.toString());
      final detectedCurrency = format.currencyName;

      if (detectedCurrency != null &&
          detectedCurrency.isNotEmpty &&
          state.settings.currencyCode == 'USD') {
        emit(
          state.copyWith(
            settings: state.settings.copyWith(currencyCode: detectedCurrency),
          ),
        );
      }
    });
  }

  @override
  SettingsState? fromJson(Map<String, dynamic> json) {
    return SettingsState.fromMap(json);
  }

  @override
  Map<String, dynamic>? toJson(SettingsState state) {
    return state.toMap();
  }
}
