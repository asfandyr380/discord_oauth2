import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:discord_oauth2/discord_oauth2.dart';

class MobileScreen extends StatefulWidget {
  const MobileScreen({super.key});

  @override
  State<MobileScreen> createState() => _MobileScreenState();
}

class _MobileScreenState extends State<MobileScreen> {
  final DiscordSignIn _discordSignIn = DiscordSignIn(
    clientId: '1506189735058473101',
    redirectUri: 'http://localhost:3000/auth/discord/callback',
    customScheme: 'my-app-scheme',
  );

  bool _isLoading = false;
  String? _authCode;
  String? _codeVerifier;
  String? _returnedState;

  Future<void> _handleDiscordSignIn() async {
    setState(() {
      _isLoading = true;
      _authCode = null;
      _codeVerifier = null;
      _returnedState = null;
    });

    try {
      final result = await _discordSignIn.getAuthCode(
        state: 'mobile_secure_state',
        scopes: ['identify'],
      );

      setState(() {
        _authCode = result.code;
        _codeVerifier = result.codeVerifier;
        _returnedState = result.state;
      });
    } on DiscordAuthException catch (e) {
      if (e is DiscordAuthCancelledException) return;
      _showSnackBar('Authentication Failed: ${e.message}', isError: true);
    } catch (e) {
      _showSnackBar('An unexpected error occurred: $e', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : const Color(0xFF5865F2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primaryContainer.withAlpha(102),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5865F2).withAlpha(26),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.discord,
                      size: 72,
                      color: Color(0xFF5865F2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Discord OAuth2 Mobile Client',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'This mobile interface requests authorization and retrieves a temporary code to pass to your backend securely.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(179),
                  ),
                ),
                const Spacer(),
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else
                  DiscordSignInButton(onPressed: _handleDiscordSignIn),
                if (_authCode != null) ...[
                  const SizedBox(height: 24),
                  _buildResultsCard(),
                ],
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultsCard() {
    final theme = Theme.of(context);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Authorization Successful',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildResultField('Code', _authCode!),
            const SizedBox(height: 12),
            _buildResultField('Verifier', _codeVerifier!),
            if (_returnedState != null) ...[
              const SizedBox(height: 12),
              _buildResultField('Returned State', _returnedState!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.copy, size: 20),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: value));
                _showSnackBar('$label copied to clipboard');
              },
            ),
          ],
        ),
      ],
    );
  }
}
