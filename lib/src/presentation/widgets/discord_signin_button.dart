import 'package:flutter/material.dart';

/// A pre-styled, official-branded Discord sign-in button.
///
/// Features the official Discord brand color (#5865F2 Blurple) and the Discord icon.
class DiscordSignInButton extends StatelessWidget {
  /// Callback triggered when the button is pressed. Typically kicks off the OAuth2 flow.
  final VoidCallback onPressed;

  /// Custom label widget. If null, defaults to a Text widget containing 'Sign in with Discord'.
  final Widget? label;

  /// Creates a [DiscordSignInButton] widget.
  const DiscordSignInButton({super.key, required this.onPressed, this.label});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF5865F2), // Discord Official Blurple
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      icon: const Icon(Icons.discord, size: 24),
      label: label ?? const Text('Sign in with Discord'),
    );
  }
}
