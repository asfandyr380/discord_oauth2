import 'package:flutter/material.dart';
import 'package:discord_oauth2/discord_oauth2.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Discord Auth Package Example',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5865F2)),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 1. Initialize your package API instance with safe-to-expose values.
  // Replace these with actual values from the Discord Developer Portal.
  final DiscordSignIn _discordSignIn = DiscordSignIn(
    clientId: '1506189735058473101',
    redirectUri: 'http://localhost:3000/auth/discord/callback',
    customScheme: 'my-app-scheme',
    scopes: ['identify'], // Adjust scopes as needed
  );

  bool _isLoading = false;
  String? _authCode;
  String? _backendStatus;

  /// Starts the authentication process using the package API
  Future<void> _handleDiscordSignIn() async {
    setState(() {
      _isLoading = true;
      _authCode = null;
      _backendStatus = null;
    });

    try {
      // 2. Request only the Auth Code through the package browser interface.
      // We pass an optional state string to match the security best practices.
      final result = await _discordSignIn.getAuthCode(
        state: 'xyz_secure_state',
      );

      setState(() {
        _authCode = result.code;
      });
    } on DiscordAuthException catch (e) {
      if (e is DiscordAuthCancelledException) return;
      _showErrorSnackBar('Authentication Failed: ${e.message}');
    } catch (e) {
      _showErrorSnackBar('An unexpected error occurred: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discord Package Demo'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.security_outlined,
                size: 80,
                color: Colors.blueGrey,
              ),
              const SizedBox(height: 16),
              const Text(
                'Secure OAuth2 Flow Demonstration',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'This client app only retrieves the temporary authorization code. No secrets or tokens are stored on-device.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 40),

              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                // 4. Using your package's pre-styled official Blurple button UI component
                DiscordSignInButton(onPressed: _handleDiscordSignIn),

              if (_authCode != null) ...[
                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 16),
                const Text(
                  'Captured Authorization Code:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _authCode!,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                    ),
                  ),
                ),
              ],

              if (_backendStatus != null) ...[
                const SizedBox(height: 16),
                Text(
                  _backendStatus!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
