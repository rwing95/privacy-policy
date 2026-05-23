import 'package:flutter/foundation.dart';
import '../models/steam_profile.dart';
import '../models/steam_game.dart';
import '../models/wishlist_item.dart';
import '../services/steam_api_service.dart';
import '../services/storage_service.dart';

class SteamDataProvider extends ChangeNotifier {
  final StorageService _storage;

  String? _steamId;
  String? _apiKey;

  SteamProfile? profile;
  List<SteamGame> games = [];
  List<WishlistItem> wishlist = [];
  List<SteamGame> recentGames = [];

  bool isLoadingProfile = false;
  bool isLoadingGames = false;
  bool isLoadingWishlist = false;

  String? profileError;
  String? gamesError;
  String? wishlistError;

  SteamDataProvider(this._storage);

  void updateAuth(String? steamId, String? apiKey) {
    if (_steamId != steamId || _apiKey != apiKey) {
      _steamId = steamId;
      _apiKey = apiKey;
      _clearData();
    }
  }

  void _clearData() {
    profile = null;
    games = [];
    wishlist = [];
    recentGames = [];
    profileError = null;
    gamesError = null;
    wishlistError = null;
    notifyListeners();
  }

  SteamApiService? get _api {
    if (_steamId == null) return null;
    return SteamApiService(
      backendUrl: _storage.backendUrl,
      steamId: _steamId!,
      apiKey: _apiKey,
    );
  }

  Future<void> fetchProfile() async {
    final api = _api;
    if (api == null) return;
    isLoadingProfile = true;
    profileError = null;
    notifyListeners();
    try {
      profile = await api.fetchProfile();
      if (profile == null && (_apiKey == null || _apiKey!.isEmpty)) {
        profileError = 'Add a Steam API key in Settings to view your profile.';
      }
    } catch (e) {
      profileError = 'Failed to load profile. Check your API key and connection.';
    } finally {
      isLoadingProfile = false;
      notifyListeners();
    }
  }

  Future<void> fetchGames() async {
    final api = _api;
    if (api == null) return;
    isLoadingGames = true;
    gamesError = null;
    notifyListeners();
    try {
      if (_apiKey == null || _apiKey!.isEmpty) {
        gamesError = 'Add a Steam API key in Settings to view your library.';
        games = [];
      } else {
        games = await api.fetchGames();
      }
    } catch (e) {
      gamesError = 'Failed to load library. Check your connection.';
    } finally {
      isLoadingGames = false;
      notifyListeners();
    }
  }

  Future<void> fetchWishlist() async {
    final api = _api;
    if (api == null) return;
    isLoadingWishlist = true;
    wishlistError = null;
    notifyListeners();
    try {
      wishlist = await api.fetchWishlist();
    } catch (e) {
      wishlistError = 'Failed to load wishlist. Check your connection.';
    } finally {
      isLoadingWishlist = false;
      notifyListeners();
    }
  }

  Future<void> fetchRecentGames() async {
    final api = _api;
    if (api == null || _apiKey == null || _apiKey!.isEmpty) return;
    try {
      recentGames = await api.fetchRecentGames();
      notifyListeners();
    } catch (_) {}
  }

  Future<List<SteamAchievement>> fetchAchievements(int appId) async {
    final api = _api;
    if (api == null) return [];
    return api.fetchAchievements(appId);
  }

  Future<void> refreshAll() async {
    await Future.wait([
      fetchProfile(),
      fetchGames(),
      fetchWishlist(),
      fetchRecentGames(),
    ]);
  }
}
