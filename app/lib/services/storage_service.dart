import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _keySteamId = 'steam_id';
  static const _keyApiKey = 'steam_api_key';
  static const _keyBackendUrl = 'backend_url';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  String? get steamId => _prefs.getString(_keySteamId);
  String? get apiKey => _prefs.getString(_keyApiKey);
  String get backendUrl =>
      _prefs.getString(_keyBackendUrl) ?? 'http://10.0.2.2:3000';

  Future<void> saveSteamId(String id) => _prefs.setString(_keySteamId, id);
  Future<void> saveApiKey(String key) => _prefs.setString(_keyApiKey, key);
  Future<void> saveBackendUrl(String url) =>
      _prefs.setString(_keyBackendUrl, url);

  Future<void> clearAll() async {
    await _prefs.remove(_keySteamId);
    await _prefs.remove(_keyApiKey);
  }
}
