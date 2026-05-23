import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/steam_profile.dart';
import '../theme/steam_theme.dart';

class ProfileHeader extends StatelessWidget {
  final SteamProfile profile;
  final int? gameCount;

  const ProfileHeader({super.key, required this.profile, this.gameCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [SteamColors.surfaceVariant, SteamColors.card],
        ),
      ),
      child: Row(
        children: [
          _buildAvatar(),
          const SizedBox(width: 16),
          Expanded(child: _buildInfo()),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: SteamColors.accent, width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: profile.avatarFullUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: profile.avatarFullUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        const ColoredBox(color: SteamColors.card),
                    errorWidget: (_, __, ___) => const Icon(
                      Icons.person,
                      color: SteamColors.textMuted,
                      size: 36,
                    ),
                  )
                : const Icon(Icons.person, color: SteamColors.textMuted, size: 36),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: _StatusDot(state: profile.personaState),
        ),
      ],
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          profile.personaName,
          style: const TextStyle(
            color: SteamColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (profile.realName != null) ...[
          const SizedBox(height: 2),
          Text(
            profile.realName!,
            style: const TextStyle(color: SteamColors.textSecondary, fontSize: 13),
          ),
        ],
        const SizedBox(height: 6),
        Row(
          children: [
            _StatusDot(state: profile.personaState, size: 8),
            const SizedBox(width: 6),
            Text(
              profile.statusLabel,
              style: const TextStyle(color: SteamColors.textSecondary, fontSize: 12),
            ),
            if (profile.countryCode != null) ...[
              const SizedBox(width: 12),
              const Icon(Icons.location_on, size: 12, color: SteamColors.textMuted),
              const SizedBox(width: 2),
              Text(
                profile.countryCode!,
                style: const TextStyle(color: SteamColors.textMuted, fontSize: 12),
              ),
            ],
          ],
        ),
        if (gameCount != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: SteamColors.accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: SteamColors.accent.withOpacity(0.3)),
            ),
            child: Text(
              '$gameCount games',
              style: const TextStyle(
                color: SteamColors.accent,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _StatusDot extends StatelessWidget {
  final int state;
  final double size;

  const _StatusDot({required this.state, this.size = 10});

  Color get _color {
    switch (state) {
      case 1:
        return const Color(0xFF57CBE8);
      case 2:
        return const Color(0xFFE8A157);
      case 3:
      case 4:
        return const Color(0xFFB8BFC8);
      default:
        return const Color(0xFF6A7785);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _color,
        border: Border.all(color: SteamColors.card, width: 1.5),
      ),
    );
  }
}
