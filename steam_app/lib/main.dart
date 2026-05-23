import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/steam_theme.dart';
import 'services/storage_service.dart';
import 'providers/auth_provider.dart';
import 'providers/steam_data_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final storage = StorageService(prefs);
  runApp(SteamCompanionApp(storage: storage));
}

class SteamCompanionApp extends StatelessWidget {
  final StorageService storage;

  const SteamCompanionApp({super.key, required this.storage});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(storage)),
        ChangeNotifierProxyProvider<AuthProvider, SteamDataProvider>(
          create: (_) => SteamDataProvider(storage),
          update: (_, auth, data) {
            data!.updateAuth(auth.steamId, auth.apiKey);
            return data;
          },
        ),
      ],
      child: MaterialApp(
        title: 'Steam Companion',
        theme: SteamTheme.darkTheme,
        home: const _AuthGate(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await context.read<AuthProvider>().init();
    if (mounted) setState(() => _initialized = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(
        backgroundColor: SteamColors.background,
        body: Center(
          child: CircularProgressIndicator(color: SteamColors.accent),
        ),
      );
    }
    final isLoggedIn = context.watch<AuthProvider>().isLoggedIn;
    return isLoggedIn ? const HomeScreen() : const LoginScreen();
  }
}
