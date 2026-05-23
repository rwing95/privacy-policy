import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../models/steam_game.dart';
import '../theme/steam_theme.dart';

class GameCard extends StatelessWidget {
  final SteamGame game;
  final VoidCallback onTap;

  const GameCard({super.key, required this.game, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: SteamColors.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(),
            Expanded(child: _buildInfo()),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return AspectRatio(
      aspectRatio: 460 / 215,
      child: CachedNetworkImage(
        imageUrl: game.headerImageUrl,
        fit: BoxFit.cover,
        placeholder: (_, __) => Shimmer.fromColors(
          baseColor: SteamColors.shimmerBase,
          highlightColor: SteamColors.shimmerHighlight,
          child: Container(color: SteamColors.shimmerBase),
        ),
        errorWidget: (_, __, ___) => Container(
          color: SteamColors.card,
          child: const Center(
            child: Icon(Icons.sports_esports, color: SteamColors.textMuted, size: 32),
          ),
        ),
      ),
    );
  }

  Widget _buildInfo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            game.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: SteamColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.schedule, size: 12, color: SteamColors.textMuted),
              const SizedBox(width: 4),
              Text(
                game.playtimeLabel,
                style: const TextStyle(
                  color: SteamColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          if (game.achievementPercent != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.emoji_events, size: 12, color: SteamColors.warning),
                const SizedBox(width: 4),
                Text(
                  '${game.achievementsUnlocked}/${game.achievementsTotal}',
                  style: const TextStyle(
                    color: SteamColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class GameListTile extends StatelessWidget {
  final SteamGame game;
  final VoidCallback onTap;

  const GameListTile({super.key, required this.game, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: CachedNetworkImage(
          imageUrl: game.headerImageUrl,
          width: 80,
          height: 37,
          fit: BoxFit.cover,
          placeholder: (_, __) => Shimmer.fromColors(
            baseColor: SteamColors.shimmerBase,
            highlightColor: SteamColors.shimmerHighlight,
            child: Container(width: 80, height: 37, color: SteamColors.shimmerBase),
          ),
          errorWidget: (_, __, ___) => Container(
            width: 80,
            height: 37,
            color: SteamColors.card,
            child: const Icon(Icons.sports_esports, color: SteamColors.textMuted, size: 18),
          ),
        ),
      ),
      title: Text(
        game.name,
        style: const TextStyle(
          color: SteamColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        game.playtimeLabel,
        style: const TextStyle(color: SteamColors.textSecondary, fontSize: 12),
      ),
      trailing: game.playtime2Weeks > 0
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: SteamColors.accentDark.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: SteamColors.accent.withOpacity(0.4)),
              ),
              child: Text(
                '${game.recentPlaytimeHours.toStringAsFixed(1)}h recent',
                style: const TextStyle(color: SteamColors.accent, fontSize: 10),
              ),
            )
          : null,
    );
  }
}
