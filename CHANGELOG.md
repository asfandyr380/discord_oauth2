## 1.0.1

* Moved the `scopes` parameter from the `DiscordSignIn` constructor to the `getAuthCode` method to allow dynamic scope requesting per authorization call.
* Updated test suite, example app code, and README documentation to match the new API structure.

## 1.0.0

* Initial release of `discord_oauth2`.
* Fully secure PKCE (Proof Key for Code Exchange) flow generation using SHA-256 challenges.
* High-quality `<DiscordSignInButton>` featuring official brand Blurple color and Discord asset logo.
* Strongly typed exceptions (`DiscordAuthCancelledException`, `DiscordAuthFailedException`, `DiscordAuthCodeMissingException`, and `DiscordAuthNetworkException`).
* Seamless dynamic screen routing and layout configurations for mobile and web integration.
* Robust unit and widget test suite covering cryptographic safety, repository pipelines, and interface responsiveness.
