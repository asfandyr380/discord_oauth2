import 'package:flutter_test/flutter_test.dart';
import 'package:discord_oauth2/src/domain/repositories/discord_auth_repository.dart';
import 'package:discord_oauth2/src/presentation/discord_sigin_api.dart';

class MockDiscordAuthRepository implements DiscordAuthRepository {
  DiscordAuthResult? mockResult;
  Object? mockError;

  String? capturedClientId;
  String? capturedRedirectUri;
  List<String>? capturedScopes;
  String? capturedCustomScheme;
  String? capturedState;

  @override
  Future<DiscordAuthResult> getAuthorizationCode({
    required String clientId,
    required String redirectUri,
    required List<String> scopes,
    required String customScheme,
    String? state,
  }) async {
    capturedClientId = clientId;
    capturedRedirectUri = redirectUri;
    capturedScopes = scopes;
    capturedCustomScheme = customScheme;
    capturedState = state;

    if (mockError != null) {
      throw mockError!;
    }
    return mockResult ??
        const DiscordAuthResult(
          code: 'test_code',
          codeVerifier: 'test_verifier',
        );
  }
}

void main() {
  group('DiscordSignIn tests', () {
    late MockDiscordAuthRepository mockRepository;

    setUp(() {
      mockRepository = MockDiscordAuthRepository();
    });

    test('uses default scopes when not specified in getAuthCode', () async {
      final signIn = DiscordSignIn(
        clientId: 'client123',
        redirectUri: 'http://localhost/callback',
        customScheme: 'my-app',
        repository: mockRepository,
      );

      expect(signIn.clientId, equals('client123'));
      expect(signIn.redirectUri, equals('http://localhost/callback'));
      expect(signIn.customScheme, equals('my-app'));

      await signIn.getAuthCode();
      expect(mockRepository.capturedScopes, equals(['identify', 'email']));
    });

    test(
      'delegates getAuthCode to repository with correct parameters',
      () async {
        final signIn = DiscordSignIn(
          clientId: 'client123',
          redirectUri: 'http://localhost/callback',
          customScheme: 'my-app',
          repository: mockRepository,
        );

        final expectedResult = const DiscordAuthResult(
          code: 'auth_code_xyz',
          codeVerifier: 'verifier_xyz',
          state: 'custom_state_123',
        );
        mockRepository.mockResult = expectedResult;

        final result = await signIn.getAuthCode(
          state: 'custom_state_123',
          scopes: ['identify', 'guilds'],
        );

        expect(result, equals(expectedResult));
        expect(mockRepository.capturedClientId, equals('client123'));
        expect(
          mockRepository.capturedRedirectUri,
          equals('http://localhost/callback'),
        );
        expect(mockRepository.capturedScopes, equals(['identify', 'guilds']));
        expect(mockRepository.capturedCustomScheme, equals('my-app'));
        expect(mockRepository.capturedState, equals('custom_state_123'));
      },
    );
  });
}
