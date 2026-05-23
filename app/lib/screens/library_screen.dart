import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/auth_provider.dart';
import '../providers/steam_data_provider.dart';
import '../theme/steam_theme.dart';
import '../widgets/game_card.dart';
import '../widgets/stat_chip.dart';
import 'game_detail_screen.dart';
import 'settings_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  bool _gridView = true;
  String _searchQuery = '';
  String _sortBy = 'playtime';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<SteamDataProvider>();
    final auth = context.watch<AuthProvider>();

    final filtered = data.games.where((g) {
      return g.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    if (_sortBy == 'name') {
      filtered.sort((a, b) => a.name.compareTo(b.name));
    } else if (_sortBy == 'recent') {
      filtered.sort((a, b) => b.playtime2Weeks.compareTo(a.playtime2Weeks));
    } else {
      filtered.sort((a, b) => b.playtimeForever.compareTo(a.playtimeForever));
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('My Library'),
            if (data.games.isNotEmpty)
              Text(
                '${data.games.length} games',
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
            icon: Icon(_gridView ? Icons.list : Icons.grid_view),
            onPressed: () => setState(() => _gridView = !_gridView),
            tooltip: _gridView ? 'List view' : 'Grid view',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            color: SteamColors.surface,
            onSelected: (v) => setState(() => _sortBy = v),
            itemBuilder: (_) => [
              _menuItem('playtime', 'Most Played', _sortBy == 'playtime'),
              _menuItem('recent', 'Recently Played', _sortBy == 'recent'),
              _menuItem('name', 'Name A-Z', _sortBy == 'name'),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => data.fetchGames(),
          ),
        ],
      ),
      body: Column(
        children: [
          if (!auth.hasApiKey)
            InfoBanner(
              message: 'Add your Steam API key to view your library.',
              icon: Icons.key,
              onAction: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ),
              actionLabel: 'Settings',
            ),
          _buildSearchBar(),
          Expanded(child: _buildContent(data, filtered)),
        ],
      ),
    );
  }

  PopupMenuItem<String> _menuItem(String value, String label, bool selected) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          if (selected)
            const Icon(Icons.check, size: 16, color: SteamColors.accent)
          else
            const SizedBox(width: 16),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: SteamColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v),
        style: const TextStyle(color: SteamColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search games...',
          prefixIcon: const Icon(Icons.search, color: SteamColors.textMuted, size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: SteamColors.textMuted, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  Widget _buildContent(SteamDataProvider data, List games) {
    if (data.isLoadingGames) return _buildShimmer();
    if (data.gamesError != null && data.games.isEmpty) {
      return _buildError(data.gamesError!);
    }
    if (data.games.isEmpty) {
      return const Center(
        child: Text('No games found.', style: TextStyle(color: SteamColors.textMuted)),
      );
    }

    return RefreshIndicator(
      onRefresh: () => data.fetchGames(),
      color: SteamColors.accent,
      backgroundColor: SteamColors.surface,
      child: _gridView ? _buildGrid(games) : _buildList(games),
    );
  }

  Widget _buildGrid(List games) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemCount: games.length,
      itemBuilder: (_, i) => GameCard(
        game: games[i],
        onTap: () => _openGame(games[i]),
      ),
    );
  }

  Widget _buildList(List games) {
    return ListView.separated(
      itemCount: games.length,
      separatorBuilder: (_, __) => const Divider(height: 1, color: SteamColors.divider),
      itemBuilder: (_, i) => GameListTile(
        game: games[i],
        onTap: () => _openGame(games[i]),
      ),
    );
  }

  Widget _buildShimmer() {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemCount: 8,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: SteamColors.shimmerBase,
        highlightColor: SteamColors.shimmerHighlight,
        child: Container(
          decoration: BoxDecoration(
            color: SteamColors.shimmerBase,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber, color: SteamColors.warning, size: 48),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(color: SteamColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _openGame(game) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GameDetailScreen(game: game)),
    );
  }
}
