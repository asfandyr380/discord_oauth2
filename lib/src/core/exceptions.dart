sealed class DiscordAuthException {
  final String message;
  final dynamic details;
  const DiscordAuthException(this.message, [this.details]);

  @override
  String toString() => 'DiscordAuthException: $message ($details)';
}

class DiscordAuthCancelledException extends DiscordAuthException {
  const DiscordAuthCancelledException([dynamic details])
    : super('Authentication flow was cancelled by the user.', details);
}

class DiscordAuthFailedException extends DiscordAuthException {
  const DiscordAuthFailedException(super.message, [super.details]);
}

class DiscordAuthCodeMissingException extends DiscordAuthException {
  const DiscordAuthCodeMissingException()
    : super('Authorization code absent in callback redirect URI.');
}

class DiscordAuthNetworkException extends DiscordAuthException {
  const DiscordAuthNetworkException([dynamic details])
    : super('Network error occurred during authentication.', details);
}
