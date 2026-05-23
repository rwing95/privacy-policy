import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:intl/intl.dart';
import '../models/steam_game.dart';
import '../providers/steam_data_provider.dart';
import '../theme/steam_theme.dart';
import '../widgets/stat_chip.dart';

class GameDetailScreen extends StatefulWidget {
  final SteamGame game;

  const GameDetailScreen({super.key, required this.game});

  @override
  State<GameDetailScreen> createState() => _GameDetailScreenState();
}

class _GameDetailScreenState extends State<GameDetailScreen> {
  List<SteamAchievement>? _achievements;
  bool _loadingAchievements = false;
  String? _achievementsError;

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    setState(() {
      _loadingAchievements = true;
      _achievementsError = null;
    });
    try {
      final list = await context
          .read<SteamDataProvider>()
          .fetchAchievements(widget.game.appId);
      setState(() => _achievements = list);
    } catch (_) {
      setState(() => _achievementsError = 'Could not load achievements.');
    } finally {
      setState(() => _loadingAchievements = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    final unlocked = _achievements?.where((a) => a.achieved).length ?? 0;
    final total = _achievements?.length ?? 0;
    final percent = total > 0 ? unlocked / total : 0.0;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(game),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStats(game, unlocked, total, percent),
                if (game.rTimeLastPlayed != null && game.rTimeLastPlayed! > 0)
                  _buildLastPlayed(game.rTimeLastPlayed!),
                if (_achievements != null && _achievements!.isNotEmpty)
                  _buildAchievementsSection(unlocked, total, percent),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(SteamGame game) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: SteamColors.card,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          game.name,
          style: const TextStyle(
            color: SteamColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: game.headerImageUrl,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => const ColoredBox(color: SteamColors.card),
            ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, SteamColors.card],
                  stops: [0.4, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats(SteamGame game, int unlocked, int total, double percent) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'STATISTICS',
            style: TextStyle(
              color: SteamColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: StatChip(
                  icon: Icons.schedule,
                  label: 'Total Playtime',
                  value: game.playtimeLabel,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatChip(
                  icon: Icons.trending_up,
                  label: 'Last 2 Weeks',
                  value: game.recentPlaytimeLabel,
                  iconColor: game.playtime2Weeks > 0
                      ? SteamColors.success
                      : SteamColors.textMuted,
                ),
              ),
              if (total > 0) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: StatChip(
                    icon: Icons.emoji_events,
                    label: 'Achievements',
                    value: '$unlocked / $total',
                    iconColor: SteamColors.warning,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLastPlayed(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final formatted = DateFormat('MMM d, yyyy').format(date);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: SteamColors.card,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: SteamColors.divider),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 16, color: SteamColors.textMuted),
            const SizedBox(width: 8),
            const Text(
              'Last played: ',
              style: TextStyle(color: SteamColors.textSecondary, fontSize: 13),
            ),
            Text(
              formatted,
              style: const TextStyle(
                color: SteamColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsSection(int unlocked, int total, double percent) {
    final unlocked_ = _achievements!.where((a) => a.achieved).toList();
    final locked = _achievements!.where((a) => !a.achieved).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ACHIEVEMENTS',
            style: TextStyle(
              color: SteamColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: LinearPercentIndicator(
                  lineHeight: 8,
                  percent: percent.clamp(0.0, 1.0),
                  backgroundColor: SteamColors.card,
                  progressColor: SteamColors.warning,
                  barRadius: const Radius.circular(4),
                  padding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${(percent * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: SteamColors.warning,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (unlocked_.isNotEmpty) ...[
            _sectionLabel('UNLOCKED', SteamColors.success),
            const SizedBox(height: 8),
            ...unlocked_.map(_buildAchievementTile),
          ],
          if (locked.isNotEmpty) ...[
            const SizedBox(height: 12),
            _sectionLabel('LOCKED', SteamColors.textMuted),
            const SizedBox(height: 8),
            ...locked.take(20).map(_buildAchievementTile),
            if (locked.length > 20)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '+ ${locked.length - 20} more locked achievements',
                  style: const TextStyle(color: SteamColors.textMuted, fontSize: 12),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _sectionLabel(String text, Color color) {
    return Text(
      text,
      style: TextStyle(
        color: color,
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildAchievementTile(SteamAchievement a) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: SteamColors.card,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: a.achieved
              ? SteamColors.warning.withOpacity(0.3)
              : SteamColors.divider,
        ),
      ),
      child: Row(
        children: [
          Icon(
            a.achieved ? Icons.emoji_events : Icons.lock_outline,
            color: a.achieved ? SteamColors.warning : SteamColors.textMuted,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  a.name ?? a.apiName,
                  style: TextStyle(
                    color: a.achieved
                        ? SteamColors.textPrimary
                        : SteamColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (a.description != null && a.description!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    a.description!,
                    style: const TextStyle(
                      color: SteamColors.textMuted,
                      fontSize: 11,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (a.achieved && a.unlockTime != null && a.unlockTime! > 0) ...[
            const SizedBox(width: 8),
            Text(
              DateFormat('MMM d').format(
                DateTime.fromMillisecondsSinceEpoch(a.unlockTime! * 1000),
              ),
              style: const TextStyle(color: SteamColors.textMuted, fontSize: 10),
            ),
          ],
        ],
      ),
    );
  }
}
