class WishlistItem {
  final String appId;
  final String name;
  final String capsuleImage;
  final int priority;
  final int added;
  final String? releaseString;
  final int? releaseDate;
  final String? reviewDesc;
  final int? reviewsPercent;
  final String? reviewCss;
  final bool isFreeGame;
  final bool earlyAccess;

  const WishlistItem({
    required this.appId,
    required this.name,
    required this.capsuleImage,
    required this.priority,
    required this.added,
    this.releaseString,
    this.releaseDate,
    this.reviewDesc,
    this.reviewsPercent,
    this.reviewCss,
    this.isFreeGame = false,
    this.earlyAccess = false,
  });

  factory WishlistItem.fromJson(String appId, Map<String, dynamic> json) {
    return WishlistItem(
      appId: appId,
      name: json['name'] ?? 'Unknown Game',
      capsuleImage: json['capsule'] ?? '',
      priority: json['priority'] ?? 0,
      added: json['added'] ?? 0,
      releaseString: json['release_string'],
      releaseDate: json['release_date'] is int ? json['release_date'] : null,
      reviewDesc: json['review_desc'],
      reviewsPercent: json['reviews_percent'],
      reviewCss: json['review_css'],
      isFreeGame: json['is_free_game'] == true,
      earlyAccess: json['early_access'] == true,
    );
  }

  String get headerImageUrl {
    return 'https://cdn.cloudflare.steamstatic.com/steam/apps/$appId/header.jpg';
  }

  String get reviewColor {
    switch (reviewCss) {
      case 'positive':
        return '#4CAF50';
      case 'mixed':
        return '#FFC107';
      case 'negative':
        return '#F44336';
      default:
        return '#8FA3B1';
    }
  }
}
