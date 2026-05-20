/// Base sealed class for all exceptions related to the Discord OAuth2 authentication flow.
sealed class DiscordAuthException implements Exception {
  /// A user-friendly message describing the authentication exception.
  final String message;

  /// Optional low-level details or nested exceptions associated with this exception.
  final dynamic details;

  /// Creates a [DiscordAuthException] with the specified [message] and optional [details].
  const DiscordAuthException(this.message, [this.details]);

  @override
  String toString() => 'DiscordAuthException: $message ($details)';
}

/// Exception thrown when the authentication flow is cancelled by the user.
///
/// This typically happens when the user closes the web browser tab or sheet before completion.
class DiscordAuthCancelledException extends DiscordAuthException {
  /// Creates a [DiscordAuthCancelledException] with optional [details].
  const DiscordAuthCancelledException([dynamic details])
    : super('Authentication flow was cancelled by the user.', details);
}

/// Exception thrown when the authentication flow fails due to a protocol or server error.
class DiscordAuthFailedException extends DiscordAuthException {
  /// Creates a [DiscordAuthFailedException] with the specified error [message] and optional [details].
  const DiscordAuthFailedException(super.message, [super.details]);
}

/// Exception thrown when the redirected callback URI is parsed successfully but does
/// not contain the expected `code` parameter.
class DiscordAuthCodeMissingException extends DiscordAuthException {
  /// Creates a [DiscordAuthCodeMissingException].
  const DiscordAuthCodeMissingException()
    : super('Authorization code absent in callback redirect URI.');
}

/// Exception thrown when a network error occurs while initiating or performing the authentication flow.
class DiscordAuthNetworkException extends DiscordAuthException {
  /// Creates a [DiscordAuthNetworkException] with optional error [details].
  const DiscordAuthNetworkException([dynamic details])
    : super('Network error occurred during authentication.', details);
}
