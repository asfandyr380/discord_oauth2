import 'package:discord_oauth2/src/data/data_sources/discord_web_auth_data_source.dart';
import 'package:discord_oauth2/src/data/repositories/discord_auth_repo_impl.dart';
import 'package:discord_oauth2/src/domain/repositories/discord_auth_repository.dart';

/// Exposes the main API to perform authentication against Discord's OAuth2 servers.
///
/// Under the hood, this class uses the PKCE extension to securely request and return
/// the temporary authorization code, allowing your backend to exchange it for an access token safely.
class DiscordSignIn {
  /// The client ID of your Discord application. Exposeable on client apps.
  final String clientId;

  /// The redirect URI where Discord sends the user after authentication.
  ///
  /// This must match one of the redirect URIs registered on the Discord developer portal.
  final String redirectUri;

  /// The custom URI scheme used to capture the redirect callback back into your mobile app.
  ///
  /// For example, if your redirect is `my-app://auth/discord`, the [customScheme] is `my-app`.
  final String customScheme;

  /// The list of OAuth2 scopes requesting user permissions.
  ///
  /// Defaults to `['identify', 'email']`.
  final List<String> scopes;

  late final DiscordAuthRepository _repository;

  /// Creates a [DiscordSignIn] helper client.
  ///
  /// * [clientId]: The Discord client ID of your application.
  /// * [redirectUri]: The redirect URL registered in the Discord developer portal.
  /// * [customScheme]: The custom URI scheme to redirect back to mobile devices.
  /// * [scopes]: The list of scopes requested (defaults to `['identify', 'email']`).
  /// * [repository]: An optional [DiscordAuthRepository] to override the default implementation. Used for mock testing.
  DiscordSignIn({
    required this.clientId,
    required this.redirectUri,
    required this.customScheme,
    this.scopes = const ['identify', 'email'],
    DiscordAuthRepository? repository,
  }) {
    // Inversion of Control: dependency injection made ready for mock testing
    _repository =
        repository ??
        DiscordAuthRepositoryImpl(
          webAuthDataSource: DiscordWebAuthDataSourceImpl(),
        );
  }

  /// Launches the system browser to prompt the user to authorize.
  ///
  /// Returns a [DiscordAuthResult] with the code and PKCE verifier upon success.
  /// Throws a [DiscordAuthException] if the authorization fails or is cancelled.
  ///
  /// * [state]: An optional parameter to maintain state and prevent CSRF attacks.
  Future<DiscordAuthResult> getAuthCode({String? state}) async {
    return await _repository.getAuthorizationCode(
      clientId: clientId,
      redirectUri: redirectUri,
      scopes: scopes,
      customScheme: customScheme,
      state: state,
    );
  }
}
