/// Represents the successful result of a Discord OAuth2 authorization flow.
///
/// Contains the temporary authorization code and the PKCE verifier needed to
/// trade the code for an access token.
class DiscordAuthResult {
  /// The temporary authorization code returned by Discord.
  ///
  /// This code must be exchanged on your backend server for an access token
  /// along with the [codeVerifier].
  final String code;

  /// The cryptographically secure code verifier used during the PKCE flow.
  ///
  /// Must be sent to the backend server to complete the authorization token swap.
  final String codeVerifier;

  /// The state string returned in the callback.
  ///
  /// Can be validated externally by the client developer to ensure request integrity.
  final String? state;

  /// Creates a [DiscordAuthResult] with the provided [code], [codeVerifier], and optional [state].
  const DiscordAuthResult({
    required this.code,
    required this.codeVerifier,
    this.state,
  });
}

/// Interface defining the repository responsible for initiating the web-based
/// authorization flow and retrieving the authorization code from Discord.
abstract interface class DiscordAuthRepository {
  /// Gets the authorization code from Discord's OAuth2 flow.
  ///
  /// * [clientId]: The Discord application client ID from the developer portal.
  /// * [redirectUri]: The redirect URL registered in the Discord developer portal.
  /// * [scopes]: The list of scopes/permissions the application is requesting.
  /// * [customScheme]: The custom URI scheme used on mobile devices to redirect back.
  /// * [state]: An optional parameter to maintain state and prevent CSRF attacks.
  ///
  /// Returns a [DiscordAuthResult] containing the authorization code and the PKCE verifier.
  Future<DiscordAuthResult> getAuthorizationCode({
    required String clientId,
    required String redirectUri,
    required List<String> scopes,
    required String customScheme,
    String? state,
  });
}
