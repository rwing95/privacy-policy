class SteamProfile {
  final String steamId;
  final String personaName;
  final String avatarUrl;
  final String avatarFullUrl;
  final String profileUrl;
  final int personaState;
  final String? realName;
  final String? countryCode;
  final int? timeCreated;
  final int? lastLogOff;

  const SteamProfile({
    required this.steamId,
    required this.personaName,
    required this.avatarUrl,
    required this.avatarFullUrl,
    required this.profileUrl,
    required this.personaState,
    this.realName,
    this.countryCode,
    this.timeCreated,
    this.lastLogOff,
  });

  factory SteamProfile.fromJson(Map<String, dynamic> json) {
    return SteamProfile(
      steamId: json['steamid'] ?? '',
      personaName: json['personaname'] ?? 'Unknown',
      avatarUrl: json['avatar'] ?? '',
      avatarFullUrl: json['avatarfull'] ?? json['avatar'] ?? '',
      profileUrl: json['profileurl'] ?? '',
      personaState: json['personastate'] ?? 0,
      realName: json['realname'],
      countryCode: json['loccountrycode'],
      timeCreated: json['timecreated'],
      lastLogOff: json['lastlogoff'],
    );
  }

  String get statusLabel {
    switch (personaState) {
      case 1:
        return 'Online';
      case 2:
        return 'Busy';
      case 3:
        return 'Away';
      case 4:
        return 'Snooze';
      default:
        return 'Offline';
    }
  }
}
