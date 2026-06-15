import '../entities/user_settings.dart';
import '../services/settings_service.dart';

/// Use case: Load user settings from persistence.
class LoadSettings {
  final SettingsService _service;

  LoadSettings(this._service);

  Future<UserSettings> call() async {
    return await _service.loadSettings();
  }
}
