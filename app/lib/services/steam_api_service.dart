import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/steam_profile.dart';
import '../models/steam_game.dart';
import '../models/wishlist_item.dart';

class SteamApiService {
  final String backendUrl;
  final String steamId;
  final String? apiKey;

  SteamApiService({
    required this.backendUrl,
    required this.steamId,
    this.apiKey,
  });

  String _url(String path, [Map<String, String>? extra]) {
    final params = <String, String>{};
    if (apiKey != null && apiKey!.isNotEmpty) params['apiKey'] = apiKey!;
    if (extra != null) params.addAll(extra);
    final query = params.isNotEmpty
        ? '?${params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&')}'
        : '';
    return '$backendUrl$path$query';
  }

  Future<SteamProfile?> fetchProfile() async {
    if (apiKey == null || apiKey!.isEmpty) return null;
    final response = await http
        .get(Uri.parse(_url('/api/profile/$steamId')))
        .timeout(const Duration(seconds: 15));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data != null) return SteamProfile.fromJson(data);
    }
    return null;
  }

  Future<List<SteamGame>> fetchGames() async {
    if (apiKey == null || apiKey!.isEmpty) return [];
    final response = await http
        .get(Uri.parse(_url('/api/games/$steamId')))
        .timeout(const Duration(seconds: 20));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final games = (data['games'] as List? ?? [])
          .map((g) => SteamGame.fromJson(g))
          .toList();
      games.sort((a, b) => b.playtimeForever.compareTo(a.playtimeForever));
      return games;
    }
    return [];
  }

  Future<List<WishlistItem>> fetchWishlist() async {
    final response = await http
        .get(Uri.parse('$backendUrl/api/wishlist/$steamId'))
        .timeout(const Duration(seconds: 15));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final items = data.entries
          .where((e) => e.value is Map)
          .map((e) => WishlistItem.fromJson(e.key, e.value as Map<String, dynamic>))
          .toList();
      items.sort((a, b) => a.priority.compareTo(b.priority));
      return items;
    }
    return [];
  }

  Future<List<SteamAchievement>> fetchAchievements(int appId) async {
    if (apiKey == null || apiKey!.isEmpty) return [];
    final response = await http
        .get(Uri.parse(_url('/api/achievements/$steamId/$appId')))
        .timeout(const Duration(seconds: 15));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final list = data['achievements'] as List? ?? [];
      return list.map((a) => SteamAchievement.fromJson(a)).toList();
    }
    return [];
  }

  Future<List<SteamGame>> fetchRecentGames() async {
    if (apiKey == null || apiKey!.isEmpty) return [];
    final response = await http
        .get(Uri.parse(_url('/api/recent/$steamId')))
        .timeout(const Duration(seconds: 15));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final games = (data['games'] as List? ?? [])
          .map((g) => SteamGame.fromJson(g))
          .toList();
      return games;
    }
    return [];
  }
}
