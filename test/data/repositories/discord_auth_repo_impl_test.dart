import 'package:flutter_test/flutter_test.dart';
import 'package:discord_oauth2/src/core/exceptions.dart';
import 'package:discord_oauth2/src/data/data_sources/discord_web_auth_data_source.dart';
import 'package:discord_oauth2/src/data/repositories/discord_auth_repo_impl.dart';

class MockDiscordWebAuthDataSource implements DiscordWebAuthDataSource {
  String? mockResultUrl;
  Object? mockError;
  String? capturedUrl;
  String? capturedScheme;

  @override
  Future<String> authenticate({
    required String url,
    required String scheme,
  }) async {
    capturedUrl = url;
    capturedScheme = scheme;

    if (mockError != null) {
      throw mockError!;
    }
    return mockResultUrl ??
        'my-app-scheme://auth/discord/callback?code=mock_code';
  }
}

void main() {
  group('DiscordAuthRepositoryImpl tests', () {
    late MockDiscordWebAuthDataSource mockDataSource;
    late DiscordAuthRepositoryImpl repository;

    setUp(() {
      mockDataSource = MockDiscordWebAuthDataSource();
      repository = DiscordAuthRepositoryImpl(webAuthDataSource: mockDataSource);
    });

    test(
      'getAuthorizationCode constructs correct URL and returns code',
      () async {
        mockDataSource.mockResultUrl =
            'my-app-scheme://auth/discord/callback?code=returned_auth_code';

        final result = await repository.getAuthorizationCode(
          clientId: '12345',
          redirectUri: 'http://localhost:3000/callback',
          scopes: ['identify', 'email'],
          customScheme: 'my-app-scheme',
        );

        expect(result.code, equals('returned_auth_code'));
        expect(result.codeVerifier, isNotEmpty);

        // Verify authorization URL
        final capturedUri = Uri.parse(mockDataSource.capturedUrl!);
        expect(capturedUri.scheme, equals('https'));
        expect(capturedUri.host, equals('discord.com'));
        expect(capturedUri.path, equals('/api/oauth2/authorize'));
        expect(capturedUri.queryParameters['response_type'], equals('code'));
        expect(capturedUri.queryParameters['client_id'], equals('12345'));
        expect(
          capturedUri.queryParameters['redirect_uri'],
          equals('http://localhost:3000/callback'),
        );
        expect(capturedUri.queryParameters['scope'], equals('identify email'));
        expect(capturedUri.queryParameters['code_challenge'], isNotEmpty);
        expect(
          capturedUri.queryParameters['code_challenge_method'],
          equals('S256'),
        );
        expect(mockDataSource.capturedScheme, equals('my-app-scheme'));
      },
    );

    test(
      'getAuthorizationCode supports state parameter and returns it in the result',
      () async {
        mockDataSource.mockResultUrl =
            'my-app-scheme://auth/discord/callback?code=returned_auth_code&state=secure_state_xyz';

        final result = await repository.getAuthorizationCode(
          clientId: '12345',
          redirectUri: 'http://localhost:3000/callback',
          scopes: ['identify'],
          customScheme: 'my-app-scheme',
          state: 'secure_state_xyz',
        );

        expect(result.code, equals('returned_auth_code'));
        expect(result.state, equals('secure_state_xyz'));
        expect(mockDataSource.capturedUrl, contains('state=secure_state_xyz'));
      },
    );

    test(
      'getAuthorizationCode throws DiscordAuthFailedException on error from Discord',
      () async {
        mockDataSource.mockResultUrl =
            'my-app-scheme://auth/discord/callback?error=access_denied&error_description=User+cancelled';

        expect(
          () => repository.getAuthorizationCode(
            clientId: '12345',
            redirectUri: 'http://localhost:3000/callback',
            scopes: ['identify'],
            customScheme: 'my-app-scheme',
          ),
          throwsA(
            isA<DiscordAuthFailedException>()
                .having((e) => e.message, 'message', 'User cancelled')
                .having((e) => e.details, 'details', 'access_denied'),
          ),
        );
      },
    );

    test(
      'getAuthorizationCode throws DiscordAuthCodeMissingException when code is absent',
      () async {
        mockDataSource.mockResultUrl = 'my-app-scheme://auth/discord/callback';

        expect(
          () => repository.getAuthorizationCode(
            clientId: '12345',
            redirectUri: 'http://localhost:3000/callback',
            scopes: ['identify'],
            customScheme: 'my-app-scheme',
          ),
          throwsA(isA<DiscordAuthCodeMissingException>()),
        );
      },
    );

    test('getAuthorizationCode wraps source exceptions properly', () async {
      mockDataSource.mockError = const DiscordAuthCancelledException(
        'User clicked close',
      );

      expect(
        () => repository.getAuthorizationCode(
          clientId: '12345',
          redirectUri: 'http://localhost:3000/callback',
          scopes: ['identify'],
          customScheme: 'my-app-scheme',
        ),
        throwsA(isA<DiscordAuthCancelledException>()),
      );
    });
  });
}
