import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../providers/auth_provider.dart';
import '../theme/steam_theme.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _showWebView = false;
  bool _isLoading = true;
  WebViewController? _webViewController;

  void _startLogin() {
    final auth = context.read<AuthProvider>();
    final backendUrl = auth.backendUrl;

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(SteamColors.background)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) => setState(() => _isLoading = false),
          onNavigationRequest: (request) {
            if (request.url.startsWith('steamcompanion://')) {
              _handleCallback(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onWebResourceError: (error) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Could not connect to backend. Is the server running?'),
                  backgroundColor: Colors.redAccent,
                ),
              );
              setState(() => _showWebView = false);
            }
          },
        ),
      )
      ..loadRequest(Uri.parse('$backendUrl/auth/steam'));

    setState(() {
      _webViewController = controller;
      _showWebView = true;
      _isLoading = true;
    });
  }

  Future<void> _handleCallback(String url) async {
    final uri = Uri.parse(url);
    final steamId = uri.queryParameters['steamId'];
    final error = uri.queryParameters['error'];

    if (error != null || steamId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${error ?? 'unknown error'}'),
            backgroundColor: Colors.redAccent,
          ),
        );
        setState(() => _showWebView = false);
      }
      return;
    }

    await context.read<AuthProvider>().login(steamId);
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showWebView && _webViewController != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Sign in via Steam'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => setState(() => _showWebView = false),
          ),
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _webViewController!),
            if (_isLoading)
              const LinearProgressIndicator(
                color: SteamColors.accent,
                backgroundColor: SteamColors.card,
              ),
          ],
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLogo(),
              const SizedBox(height: 48),
              _buildSignInButton(),
              const SizedBox(height: 24),
              _buildNote(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: SteamColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: SteamColors.accent.withOpacity(0.4)),
          ),
          child: const Icon(Icons.sports_esports, color: SteamColors.accent, size: 44),
        ),
        const SizedBox(height: 20),
        const Text(
          'Steam Companion',
          style: TextStyle(
            color: SteamColors.textPrimary,
            fontSize: 26,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Your library and wishlist, at a glance.',
          style: TextStyle(color: SteamColors.textSecondary, fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSignInButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: _startLogin,
        icon: const Icon(Icons.login, size: 20),
        label: const Text(
          'Sign in with Steam',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildNote() {
    return Column(
      children: [
        const Text(
          'Make sure the backend server is running before signing in.',
          style: TextStyle(color: SteamColors.textMuted, fontSize: 12),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: _showBackendConfig,
          child: const Text(
            'Configure backend URL',
            style: TextStyle(color: SteamColors.accent, fontSize: 12),
          ),
        ),
      ],
    );
  }

  void _showBackendConfig() {
    final auth = context.read<AuthProvider>();
    final controller = TextEditingController(text: auth.backendUrl);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: SteamColors.surface,
        title: const Text('Backend URL', style: TextStyle(color: SteamColors.textPrimary)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: SteamColors.textPrimary),
          decoration: const InputDecoration(
            hintText: 'http://10.0.2.2:3000',
            labelText: 'URL',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: SteamColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              auth.saveBackendUrl(controller.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
