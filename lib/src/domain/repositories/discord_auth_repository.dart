class DiscordAuthResult {
  final String code;
  final String codeVerifier;
  final String? state;
  const DiscordAuthResult({
    required this.code,
    required this.codeVerifier,
    this.state,
  });
}

abstract interface class DiscordAuthRepository {
  /// Gets the authorization code from Discord's OAuth2 flow.
  /// [clientId] is the application's client ID.
  /// [redirectUri] is the URI to which Discord will redirect after authorization.
  /// [scopes] is a list of permissions the application is requesting.
  /// [customScheme] is the custom URI scheme used for redirecting back to the app.
  /// [state] is an optional parameter to maintain state between the request and callback.
  Future<DiscordAuthResult> getAuthorizationCode({
    required String clientId,
    required String redirectUri,
    required List<String> scopes,
    required String customScheme,
    String? state,
  });
}
