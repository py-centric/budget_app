import 'dart:ui';
import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:intl/intl.dart';
import '../../../budget/data/models/user_settings.dart';

// Events
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

class InitializeSettingsEvent extends SettingsEvent {
  const InitializeSettingsEvent();
}

// States
class SettingsState extends Equatable {
  final UserSettings settings;

  const SettingsState({
    this.settings = const UserSettings(),
  });

  SettingsState copyWith({
    UserSettings? settings,
  }) {
    return SettingsState(
      settings: settings ?? this.settings,
    );
  }

  @override
  List<Object?> get props => [settings];

  Map<String, dynamic> toMap() {
    return {
      'settings': settings.toMap(),
    };
  }

  factory SettingsState.fromMap(Map<String, dynamic> map) {
    return SettingsState(
      settings: UserSettings.fromMap(map['settings'] as Map<String, dynamic>),
    );
  }
}

// Bloc
class SettingsBloc extends HydratedBloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(const SettingsState()) {
    on<UpdateCurrencyEvent>((event, emit) {
      emit(state.copyWith(
        settings: state.settings.copyWith(currencyCode: event.currencyCode),
      ));
    });

    on<UpdateThemeEvent>((event, emit) {
      emit(state.copyWith(
        settings: state.settings.copyWith(themeMode: event.themeMode),
      ));
    });

    on<InitializeSettingsEvent>((event, emit) {
      // Logic: If currencyCode is the default USD, try to detect from locale.
      // This will only run once effectively because HydratedBloc will persist the detected value.
      
      final locale = PlatformDispatcher.instance.locale;
      final format = NumberFormat.simpleCurrency(locale: locale.toString());
      final detectedCurrency = format.currencyName;
      
      if (detectedCurrency != null && detectedCurrency.isNotEmpty && state.settings.currencyCode == 'USD') {
         emit(state.copyWith(
           settings: state.settings.copyWith(currencyCode: detectedCurrency),
         ));
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
