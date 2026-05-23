class SteamGame {
  final int appId;
  final String name;
  final String imgIconUrl;
  final int playtimeForever;
  final int playtime2Weeks;
  final int? rTimeLastPlayed;
  int? achievementsUnlocked;
  int? achievementsTotal;

  SteamGame({
    required this.appId,
    required this.name,
    required this.imgIconUrl,
    required this.playtimeForever,
    required this.playtime2Weeks,
    this.rTimeLastPlayed,
    this.achievementsUnlocked,
    this.achievementsTotal,
  });

  factory SteamGame.fromJson(Map<String, dynamic> json) {
    return SteamGame(
      appId: json['appid'] ?? 0,
      name: json['name'] ?? 'Unknown Game',
      imgIconUrl: json['img_icon_url'] ?? '',
      playtimeForever: json['playtime_forever'] ?? 0,
      playtime2Weeks: json['playtime_2weeks'] ?? 0,
      rTimeLastPlayed: json['rtime_last_played'],
    );
  }

  String get iconUrl {
    if (imgIconUrl.isEmpty) return '';
    return 'https://media.steampowered.com/steamcommunity/public/images/apps/$appId/$imgIconUrl.jpg';
  }

  String get headerImageUrl {
    return 'https://cdn.cloudflare.steamstatic.com/steam/apps/$appId/header.jpg';
  }

  String get capsuleImageUrl {
    return 'https://cdn.cloudflare.steamstatic.com/steam/apps/$appId/capsule_231x87.jpg';
  }

  double get playtimeHours => playtimeForever / 60.0;

  double get recentPlaytimeHours => playtime2Weeks / 60.0;

  String get playtimeLabel {
    if (playtimeForever == 0) return 'Never played';
    final hours = playtimeHours;
    if (hours < 1) return '${playtimeForever} mins';
    return '${hours.toStringAsFixed(1)} hrs';
  }

  String get recentPlaytimeLabel {
    if (playtime2Weeks == 0) return 'Not recent';
    final hours = recentPlaytimeHours;
    if (hours < 1) return '${playtime2Weeks} mins';
    return '${hours.toStringAsFixed(1)} hrs';
  }

  double? get achievementPercent {
    if (achievementsTotal == null || achievementsTotal == 0) return null;
    return (achievementsUnlocked ?? 0) / achievementsTotal!;
  }
}

class SteamAchievement {
  final String apiName;
  final bool achieved;
  final int? unlockTime;
  final String? name;
  final String? description;

  const SteamAchievement({
    required this.apiName,
    required this.achieved,
    this.unlockTime,
    this.name,
    this.description,
  });

  factory SteamAchievement.fromJson(Map<String, dynamic> json) {
    return SteamAchievement(
      apiName: json['apiname'] ?? '',
      achieved: (json['achieved'] ?? 0) == 1,
      unlockTime: json['unlocktime'],
      name: json['name'],
      description: json['description'],
    );
  }
}
