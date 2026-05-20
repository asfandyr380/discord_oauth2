import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:discord_oauth2/src/core/util/pkce_util.dart';

void main() {
  group('PkcePair tests', () {
    test('PkcePair.generate generates valid pair', () {
      final pair = PkcePair.generate();

      expect(pair.codeVerifier, isNotEmpty);
      expect(pair.codeChallenge, isNotEmpty);

      // Verifier should be between 43 and 128 characters
      expect(pair.codeVerifier.length, greaterThanOrEqualTo(43));
      expect(pair.codeVerifier.length, lessThanOrEqualTo(128));

      // Verifier should only contain URL-safe characters
      final urlSafeRegex = RegExp(r'^[a-zA-Z0-9\-\._~]+$');
      expect(urlSafeRegex.hasMatch(pair.codeVerifier), isTrue);

      // Challenge should be the URL-safe Base64 SHA-256 hash of the verifier without padding
      final bytes = utf8.encode(pair.codeVerifier);
      final digest = sha256.convert(bytes);
      final expectedChallenge = base64UrlEncode(
        digest.bytes,
      ).replaceAll('=', '');

      expect(pair.codeChallenge, equals(expectedChallenge));
    });

    test('Multiple generations yield different values', () {
      final pair1 = PkcePair.generate();
      final pair2 = PkcePair.generate();

      expect(pair1.codeVerifier, isNot(equals(pair2.codeVerifier)));
      expect(pair1.codeChallenge, isNot(equals(pair2.codeChallenge)));
    });
  });
}
