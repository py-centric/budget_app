import '../entities/user_settings.dart';
import '../services/settings_service.dart';

/// Use case: Persist user settings.
class SaveSettings {
  final SettingsService _service;

  SaveSettings(this._service);

  Future<void> call(UserSettings settings) async {
    await _service.saveSettings(settings);
  }
}
