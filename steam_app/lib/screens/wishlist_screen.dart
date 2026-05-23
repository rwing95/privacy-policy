import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/steam_data_provider.dart';
import '../models/wishlist_item.dart';
import '../theme/steam_theme.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<SteamDataProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Wishlist'),
            if (data.wishlist.isNotEmpty)
              Text(
                '${data.wishlist.length} games',
                style: const TextStyle(
                  color: SteamColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => data.fetchWishlist(),
          ),
        ],
      ),
      body: _buildBody(context, data),
    );
  }

  Widget _buildBody(BuildContext context, SteamDataProvider data) {
    if (data.isLoadingWishlist) return _buildShimmer();

    if (data.wishlistError != null && data.wishlist.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber, color: SteamColors.warning, size: 48),
              const SizedBox(height: 16),
              Text(
                data.wishlistError!,
                style: const TextStyle(color: SteamColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (data.wishlist.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bookmark_border, color: SteamColors.textMuted, size: 48),
            SizedBox(height: 12),
            Text(
              'Your wishlist is empty.',
              style: TextStyle(color: SteamColors.textMuted, fontSize: 15),
            ),
            SizedBox(height: 4),
            Text(
              'Make sure your wishlist is public on Steam.',
              style: TextStyle(color: SteamColors.textMuted, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => data.fetchWishlist(),
      color: SteamColors.accent,
      backgroundColor: SteamColors.surface,
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: data.wishlist.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) => _WishlistCard(item: data.wishlist[i], rank: i + 1),
      ),
    );
  }

  Widget _buildShimmer() {
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: 8,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: SteamColors.shimmerBase,
        highlightColor: SteamColors.shimmerHighlight,
        child: Container(
          height: 90,
          decoration: BoxDecoration(
            color: SteamColors.shimmerBase,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}

class _WishlistCard extends StatelessWidget {
  final WishlistItem item;
  final int rank;

  const _WishlistCard({required this.item, required this.rank});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SteamColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          _buildImage(),
          Expanded(child: _buildInfo()),
          _buildRank(),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return SizedBox(
      width: 120,
      height: 90,
      child: CachedNetworkImage(
        imageUrl: item.headerImageUrl,
        fit: BoxFit.cover,
        placeholder: (_, __) => Shimmer.fromColors(
          baseColor: SteamColors.shimmerBase,
          highlightColor: SteamColors.shimmerHighlight,
          child: Container(color: SteamColors.shimmerBase),
        ),
        errorWidget: (_, __, ___) => Container(
          color: SteamColors.card,
          child: const Icon(Icons.sports_esports, color: SteamColors.textMuted, size: 28),
        ),
      ),
    );
  }

  Widget _buildInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            item.name,
            style: const TextStyle(
              color: SteamColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          if (item.releaseString != null)
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 11, color: SteamColors.textMuted),
                const SizedBox(width: 4),
                Text(
                  item.releaseString!,
                  style: const TextStyle(color: SteamColors.textMuted, fontSize: 11),
                ),
              ],
            ),
          const SizedBox(height: 4),
          Row(
            children: [
              if (item.reviewDesc != null) _reviewBadge(),
              if (item.isFreeGame) _tag('FREE', SteamColors.success),
              if (item.earlyAccess) _tag('EA', SteamColors.warning),
            ],
          ),
        ],
      ),
    );
  }

  Widget _reviewBadge() {
    final css = item.reviewCss ?? 'default';
    Color color;
    if (css == 'positive') {
      color = SteamColors.success;
    } else if (css == 'mixed') {
      color = SteamColors.warning;
    } else if (css == 'negative') {
      color = Colors.redAccent;
    } else {
      color = SteamColors.textMuted;
    }

    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        item.reviewDesc!,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _tag(String label, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildRank() {
    return Container(
      width: 36,
      height: 90,
      color: SteamColors.card,
      child: Center(
        child: Text(
          '#$rank',
          style: const TextStyle(
            color: SteamColors.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
