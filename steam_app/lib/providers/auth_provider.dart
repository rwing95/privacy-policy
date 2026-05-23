import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final StorageService _storage;

  String? _steamId;
  String? _apiKey;

  AuthProvider(this._storage);

  String? get steamId => _steamId;
  String? get apiKey => _apiKey;
  String get backendUrl => _storage.backendUrl;
  bool get isLoggedIn => _steamId != null && _steamId!.isNotEmpty;
  bool get hasApiKey => _apiKey != null && _apiKey!.isNotEmpty;

  Future<void> init() async {
    _steamId = _storage.steamId;
    _apiKey = _storage.apiKey;
    notifyListeners();
  }

  Future<void> login(String steamId) async {
    _steamId = steamId;
    await _storage.saveSteamId(steamId);
    notifyListeners();
  }

  Future<void> saveApiKey(String key) async {
    _apiKey = key.trim();
    await _storage.saveApiKey(_apiKey!);
    notifyListeners();
  }

  Future<void> saveBackendUrl(String url) async {
    await _storage.saveBackendUrl(url);
    notifyListeners();
  }

  Future<void> logout() async {
    _steamId = null;
    _apiKey = null;
    await _storage.clearAll();
    notifyListeners();
  }
}
