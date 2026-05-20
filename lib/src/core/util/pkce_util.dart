import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

class PkcePair {
  final String codeVerifier;
  final String codeChallenge;

  const PkcePair({required this.codeVerifier, required this.codeChallenge});

  /// Generates a valid PKCE Verifier and S256 Challenge pair
  factory PkcePair.generate() {
    final random = Random.secure();

    // 1. Generate random unguessable entropy (between 43 and 128 characters long)
    final values = List<int>.generate(64, (i) => random.nextInt(256));
    final verifier = base64UrlEncode(values).replaceAll('=', '');

    // 2. Hash it using SHA-256
    final bytes = utf8.encode(verifier);
    final digest = sha256.convert(bytes);

    // 3. Base64Url encode the hash to create the challenge
    final challenge = base64UrlEncode(digest.bytes).replaceAll('=', '');

    return PkcePair(codeVerifier: verifier, codeChallenge: challenge);
  }
}
