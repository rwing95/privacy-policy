import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/steam_data_provider.dart';
import '../theme/steam_theme.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _apiKeyController;
  late TextEditingController _backendUrlController;
  bool _apiKeyVisible = false;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _apiKeyController = TextEditingController(text: auth.apiKey ?? '');
    _backendUrlController = TextEditingController(text: auth.backendUrl);
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _backendUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    final auth = context.read<AuthProvider>();
    await auth.saveApiKey(_apiKeyController.text);
    await auth.saveBackendUrl(_backendUrlController.text.trim());
    context.read<SteamDataProvider>().refreshAll();
    setState(() => _saved = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _saved = false);
    });
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: SteamColors.surface,
        title: const Text('Sign Out', style: TextStyle(color: SteamColors.textPrimary)),
        content: const Text(
          'Are you sure you want to sign out?',
          style: TextStyle(color: SteamColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: SteamColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await context.read<AuthProvider>().logout();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionHeader('ACCOUNT'),
          const SizedBox(height: 8),
          _infoTile('Steam ID', auth.steamId ?? 'Not logged in'),
          const SizedBox(height: 24),
          _sectionHeader('STEAM WEB API KEY'),
          const SizedBox(height: 4),
          const Text(
            'Required to view your library, achievements, and profile.\nGet a free key at steamcommunity.com/dev/apikey',
            style: TextStyle(color: SteamColors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _apiKeyController,
            obscureText: !_apiKeyVisible,
            style: const TextStyle(color: SteamColors.textPrimary, fontFamily: 'monospace'),
            decoration: InputDecoration(
              labelText: 'API Key',
              hintText: 'Paste your Steam Web API key...',
              suffixIcon: IconButton(
                icon: Icon(
                  _apiKeyVisible ? Icons.visibility_off : Icons.visibility,
                  color: SteamColors.textMuted,
                  size: 18,
                ),
                onPressed: () => setState(() => _apiKeyVisible = !_apiKeyVisible),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _sectionHeader('BACKEND URL'),
          const SizedBox(height: 4),
          const Text(
            'The address where your Node.js server is running.\nAndroid emulator: http://10.0.2.2:3000\niOS simulator: http://localhost:3000\nReal device: your machine\'s local IP address',
            style: TextStyle(color: SteamColors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _backendUrlController,
            style: const TextStyle(color: SteamColors.textPrimary),
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(labelText: 'Backend URL'),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _saveSettings,
              icon: Icon(_saved ? Icons.check : Icons.save_outlined, size: 18),
              label: Text(_saved ? 'Saved!' : 'Save Settings'),
              style: _saved
                  ? ElevatedButton.styleFrom(backgroundColor: SteamColors.success)
                  : null,
            ),
          ),
          const SizedBox(height: 32),
          const Divider(color: SteamColors.divider),
          const SizedBox(height: 16),
          _sectionHeader('ABOUT'),
          const SizedBox(height: 8),
          _infoTile('Version', '1.0.0'),
          _infoTile('App', 'Steam Companion'),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout, size: 18, color: Colors.redAccent),
              label: const Text(
                'Sign Out',
                style: TextStyle(color: Colors.redAccent),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.redAccent, width: 1),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _sectionHeader(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: SteamColors.textMuted,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: SteamColors.textSecondary, fontSize: 13)),
          Text(
            value,
            style: const TextStyle(color: SteamColors.textPrimary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
