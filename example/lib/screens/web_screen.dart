import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:discord_oauth2/discord_oauth2.dart';

class WebScreen extends StatefulWidget {
  const WebScreen({super.key});

  @override
  State<WebScreen> createState() => _WebScreenState();
}

class _WebScreenState extends State<WebScreen> {
  final DiscordSignIn _discordSignIn = DiscordSignIn(
    clientId: '1506189735058473101',
    redirectUri: 'http://localhost:3000/auth/discord/callback',
    customScheme: 'my-app-scheme',
    scopes: ['identify', 'email'],
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
        state: 'web_secure_state_987',
      );

      setState(() {
        _authCode = result.code;
        _codeVerifier = result.codeVerifier;
        _returnedState = result.state;
      });
    } on DiscordAuthException catch (e) {
      if (e is DiscordAuthCancelledException) return;
      _showToast('Authentication Failed: ${e.message}', isError: true);
    } catch (e) {
      _showToast('An unexpected error occurred: $e', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showToast(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        backgroundColor: isError
            ? const Color(0xFFED4245)
            : const Color(0xFF5865F2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 24, right: 24, left: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        width: 380,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isDesktop = mediaQuery.size.width > 800;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1015),
      body: Stack(
        children: [
          // Background decorative gradients/glows
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF5865F2).withAlpha(38),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            right: -100,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFA5B4FC).withAlpha(20),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          // Main content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: isDesktop
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(child: _buildHeroSection()),
                            const SizedBox(width: 64),
                            Expanded(child: _buildAuthCard()),
                          ],
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildHeroSection(),
                            const SizedBox(height: 48),
                            _buildAuthCard(),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF5865F2).withAlpha(38),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.discord_outlined,
            size: 40,
            color: Color(0xFF5865F2),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Discord OAuth2\nIntegration Framework',
          style: TextStyle(
            color: Colors.white,
            fontSize: 42,
            fontWeight: FontWeight.w900,
            height: 1.15,
            letterSpacing: -1.0,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'A premium, secure solution to handle Discord authorization codes and PKCE validation. Clean architecture under the hood, ready to pair with your custom backend authentication workflow.',
          style: TextStyle(
            color: Colors.white.withAlpha(153),
            fontSize: 16,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        // Badges representing features
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildBadge(Icons.shield_outlined, 'Secure PKCE Flow'),
            _buildBadge(Icons.web_asset_outlined, 'OAuth2 Web Support'),
            _buildBadge(Icons.key_outlined, 'Auth State Validation'),
          ],
        ),
      ],
    );
  }

  Widget _buildBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2129),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(13)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFFA5B4FC)),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFFE2E8F0),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: const Color(0xFF16181F).withAlpha(179),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withAlpha(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Welcome Back',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Click authorization below to kick off the flow.',
                style: TextStyle(
                  color: Colors.white.withAlpha(102),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 36),
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: CircularProgressIndicator(color: Color(0xFF5865F2)),
                  ),
                )
              else
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: SizedBox(
                    height: 52,
                    child: DiscordSignInButton(
                      onPressed: _handleDiscordSignIn,
                      label: const Text(
                        'Authenticate with Discord',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              if (_authCode != null) ...[
                const SizedBox(height: 32),
                const Divider(color: Color(0xFF2E313E)),
                const SizedBox(height: 24),
                const Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      color: Color(0xFF57F287),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Successfully Authenticated',
                      style: TextStyle(
                        color: Color(0xFF57F287),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildDisplayField('Authorization Code', _authCode!),
                const SizedBox(height: 16),
                _buildDisplayField('Code Verifier', _codeVerifier!),
                if (_returnedState != null) ...[
                  const SizedBox(height: 16),
                  _buildDisplayField('Callback State', _returnedState!),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDisplayField(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white.withAlpha(102),
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF0F1015),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF2E313E)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFE2E8F0),
                    fontFamily: 'monospace',
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: value));
                    _showToast('$title copied to clipboard');
                  },
                  child: Icon(
                    Icons.copy_rounded,
                    size: 16,
                    color: Colors.white.withAlpha(128),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
