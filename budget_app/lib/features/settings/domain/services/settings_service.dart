import '../entities/user_settings.dart';

/// Abstract service for persisting and loading user settings.
abstract class SettingsService {
  Future<UserSettings> loadSettings();
  Future<void> saveSettings(UserSettings settings);
}
