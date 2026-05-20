import 'package:flutter/material.dart';

class DiscordSignInButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget? label;

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
