import 'package:discord_oauth2/src/core/exceptions.dart';
import 'package:discord_oauth2/src/core/util/pkce_util.dart';
import 'package:discord_oauth2/src/data/data_sources/discord_web_auth_data_source.dart';
import 'package:discord_oauth2/src/domain/repositories/discord_auth_repository.dart';

class DiscordAuthRepositoryImpl implements DiscordAuthRepository {
  final DiscordWebAuthDataSource webAuthDataSource;

  DiscordAuthRepositoryImpl({required this.webAuthDataSource});

  @override
  Future<DiscordAuthResult> getAuthorizationCode({
    required String clientId,
    required String redirectUri,
    required List<String> scopes,
    required String customScheme,
    String? state,
  }) async {
    // 1. Automatically generate the PKCE values per-session
    final pkce = PkcePair.generate();

    final queryParameters = {
      'response_type': 'code',
      'client_id': clientId,
      'redirect_uri': redirectUri,
      'scope': scopes.join(' '),
      'code_challenge': pkce.codeChallenge,
      'code_challenge_method': 'S256',
    };

    if (state != null) {
      queryParameters['state'] = state;
    }

    final url = Uri.https(
      'discord.com',
      '/api/oauth2/authorize',
      queryParameters,
    ).toString();

    final resultUrl = await webAuthDataSource.authenticate(
      url: url,
      scheme: customScheme,
    );

    final uri = Uri.parse(resultUrl);
    final code = uri.queryParameters['code'];
    final error = uri.queryParameters['error'];
    final errorDescription = uri.queryParameters['error_description'];
    final returnedState = uri.queryParameters['state'];

    if (error != null) {
      throw DiscordAuthFailedException(
        errorDescription ?? 'Authorization failed with error: $error',
        error,
      );
    }

    if (state != null && returnedState != state) {
      throw DiscordAuthFailedException(
        'State mismatch: Expected "$state" but got "$returnedState".',
        'state_mismatch',
      );
    }

    if (code == null) {
      throw const DiscordAuthCodeMissingException();
    }

    return DiscordAuthResult(code: code, codeVerifier: pkce.codeVerifier);
  }
}
