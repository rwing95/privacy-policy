import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/steam_data_provider.dart';
import '../theme/steam_theme.dart';
import '../widgets/profile_header.dart';
import '../widgets/stat_chip.dart';
import 'game_detail_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final data = context.watch<SteamDataProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => data.fetchProfile(),
          ),
        ],
      ),
      body: _buildBody(context, auth, data),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AuthProvider auth,
    SteamDataProvider data,
  ) {
    if (!auth.hasApiKey) {
      return InfoBanner(
        message: 'Add your Steam API key in Settings to view your profile.',
        icon: Icons.key,
        onAction: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SettingsScreen()),
        ),
        actionLabel: 'Go to Settings',
      );
    }

    if (data.isLoadingProfile) {
      return Shimmer.fromColors(
        baseColor: SteamColors.shimmerBase,
        highlightColor: SteamColors.shimmerHighlight,
        child: Column(
          children: [
            Container(height: 120, color: SteamColors.shimmerBase),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(child: Container(height: 70, decoration: BoxDecoration(
                    color: SteamColors.shimmerBase,
                    borderRadius: BorderRadius.circular(8),
                  ))),
                  const SizedBox(width: 10),
                  Expanded(child: Container(height: 70, decoration: BoxDecoration(
                    color: SteamColors.shimmerBase,
                    borderRadius: BorderRadius.circular(8),
                  ))),
                  const SizedBox(width: 10),
                  Expanded(child: Container(height: 70, decoration: BoxDecoration(
                    color: SteamColors.shimmerBase,
                    borderRadius: BorderRadius.circular(8),
                  ))),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (data.profile == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person_outline, color: SteamColors.textMuted, size: 64),
            const SizedBox(height: 12),
            const Text(
              'Profile unavailable.',
              style: TextStyle(color: SteamColors.textSecondary, fontSize: 15),
            ),
            if (data.profileError != null) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  data.profileError!,
                  style: const TextStyle(color: SteamColors.textMuted, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      );
    }

    final profile = data.profile!;
    final totalHours = data.games.fold(0, (s, g) => s + g.playtimeForever) / 60;
    final recentHours = data.games.fold(0, (s, g) => s + g.playtime2Weeks) / 60;
    final mostPlayed = data.games.isNotEmpty ? data.games.first : null;

    return RefreshIndicator(
      onRefresh: () => data.fetchProfile(),
      color: SteamColors.accent,
      backgroundColor: SteamColors.surface,
      child: ListView(
        children: [
          ProfileHeader(profile: profile, gameCount: data.games.length),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'OVERVIEW',
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
                        label: 'Total Hours',
                        value: totalHours.toStringAsFixed(0),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: StatChip(
                        icon: Icons.trending_up,
                        label: 'Recent Hours',
                        value: recentHours.toStringAsFixed(1),
                        iconColor: recentHours > 0
                            ? SteamColors.success
                            : SteamColors.textMuted,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: StatChip(
                        icon: Icons.videogame_asset,
                        label: 'Games',
                        value: '${data.games.length}',
                      ),
                    ),
                  ],
                ),
                if (profile.timeCreated != null) ...[
                  const SizedBox(height: 16),
                  _infoRow(
                    Icons.cake_outlined,
                    'Member since',
                    DateFormat('MMM d, yyyy').format(
                      DateTime.fromMillisecondsSinceEpoch(profile.timeCreated! * 1000),
                    ),
                  ),
                ],
                if (profile.lastLogOff != null) ...[
                  const SizedBox(height: 8),
                  _infoRow(
                    Icons.login,
                    'Last seen',
                    DateFormat('MMM d, yyyy h:mm a').format(
                      DateTime.fromMillisecondsSinceEpoch(profile.lastLogOff! * 1000),
                    ),
                  ),
                ],
                if (mostPlayed != null) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'MOST PLAYED',
                    style: TextStyle(
                      color: SteamColors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GameDetailScreen(game: mostPlayed),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: SteamColors.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.emoji_events, color: SteamColors.warning, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  mostPlayed.name,
                                  style: const TextStyle(
                                    color: SteamColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  mostPlayed.playtimeLabel,
                                  style: const TextStyle(
                                    color: SteamColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: SteamColors.textMuted),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 15, color: SteamColors.textMuted),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(color: SteamColors.textSecondary, fontSize: 13),
        ),
        Text(
          value,
          style: const TextStyle(
            color: SteamColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
