# discord_oauth2

[![pub package](https://img.shields.io/pub/v/discord_oauth2.svg)](https://pub.dev/packages/discord_oauth2)
[![pub points](https://img.shields.io/pub/points/discord_oauth2.svg)](https://pub.dev/packages/discord_oauth2)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A lightweight, secure, and ready-to-use Flutter package to integrate Discord OAuth2 login with PKCE (Proof Key for Code Exchange) support.

Developed with Clean Architecture principles, this package handles the client-side system browser flow and safely hands off the temporary authorization code and code verifier to pass to your backend server.

---

## Features

- **Secure PKCE (RFC 7636) Flow**: Generates cryptographically secure code verifier and SHA-256 code challenge pairs automatically.
- **Web & Mobile Support**: Responsive design support that works on iOS, Android, and Web browsers.
- **Pre-styled Brand Components**: Includes the official `<DiscordSignInButton>` widget styled with the official Discord brand color (#5865F2 Blurple) and Discord icon.
- **Robust Exception Model**: Strongly typed exceptions for network issues, cancellation, protocol errors, or invalid callback parsing.
- **CSRF Protection**: Supports generating and passing custom `state` parameters to match OAuth2 security standards.

---

## Getting Started

### 1. Register Your Discord Application
1. Go to the [Discord Developer Portal](https://discord.com/developers/applications).
2. Create a new Application and navigate to the **OAuth2** tab.
3. Add your Redirect URIs.

> [!IMPORTANT]  
> Discord **does not support custom schemes** (e.g. `my-app-scheme://...`) directly in the developer portal redirect list. You must register a standard `https://` URL (like `https://api.yourdomain.com/auth/discord/callback`) for production, or `http://localhost:3000/auth/discord/callback` for local testing/web.
> 
> See the [Intermediary Server Redirect](#handling-redirection-on-mobile-server-side-intermediary-redirect) section below on how to easily redirect from your HTTPS server back to your mobile app custom scheme.

---

### 2. Configure Platforms

#### Android Configuration
Add the custom scheme intent filter to your `android/app/src/main/AndroidManifest.xml` (inside the `<activity>` tag of your main activity):

```xml
<intent-filter android:label="flutter_web_auth_2">
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data android:scheme="my-app-scheme" />
</intent-filter>
```

#### iOS Configuration
Add the custom scheme to your `ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>auth_callback</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>my-app-scheme</string>
        </array>
    </dict>
</array>
```

---

## Handling Redirection on Mobile (Server-Side Intermediary Redirect)

Since Discord requires a valid `https` redirect URI for production applications, you must set up a simple redirect endpoint on your server. When Discord redirects the user back to your HTTPS server, the server forwards the parameters back to your app's custom scheme (`my-app-scheme://`).

### Node.js (Express) Server Redirect Endpoint

Here is an example setup using Node.js and Express:

```javascript
app.get('/auth/discord/callback', (req, res) => {
  const { code, state, error, error_description } = req.query;
  
  let redirectUri = 'my-app-scheme://auth/discord/callback';
  const params = [];
  
  if (code) params.push(`code=${code}`);
  if (state) params.push(`state=${state}`);
  if (error) params.push(`error=${error}`);
  if (error_description) params.push(`error_description=${error_description}`);
  
  if (params.length > 0) {
    redirectUri += `?${params.join('&')}`;
  }
  
  // Forward to mobile custom scheme deep link
  res.redirect(redirectUri);
});
```

---

## Usage

### Complete Integration Example

```dart
import 'package:flutter/material.dart';
import 'package:discord_oauth2/discord_oauth2.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 1. Initialize DiscordSignIn configuration
  // For mobile: Use the HTTPS URL of your server-side intermediary as redirectUri.
  final DiscordSignIn _discordSignIn = DiscordSignIn(
    clientId: 'YOUR_DISCORD_CLIENT_ID',
    redirectUri: 'https://auth.yourdomain.com/discord/callback',
    customScheme: 'my-app-scheme',
    scopes: ['identify', 'email'],
  );

  bool _isLoading = false;

  Future<void> _login() async {
    setState(() => _isLoading = true);

    try {
      // 2. Launch browser auth flow
      final result = await _discordSignIn.getAuthCode(
        state: 'secure_random_state_string',
      );

      // 3. Send authorization code and verifier to your backend
      print('Auth Code: ${result.code}');
      print('PKCE Verifier: ${result.codeVerifier}');
      print('State: ${result.state}');

      await _exchangeCodeWithBackend(result.code, result.codeVerifier);

    } on DiscordAuthException catch (e) {
      if (e is DiscordAuthCancelledException) {
        print('Authentication cancelled.');
      } else {
        print('Authentication failed: ${e.message}');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _exchangeCodeWithBackend(String code, String verifier) async {
    // Send code and verifier to your backend server to exchange for tokens.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : DiscordSignInButton(onPressed: _login),
      ),
    );
  }
}
```

---

### Exception Hierarchy

All authentication exceptions subclass `DiscordAuthException`:
- **`DiscordAuthCancelledException`**: User closed the web flow prematurely.
- **`DiscordAuthFailedException`**: The flow failed (e.g., Discord returned an authorization error, invalid client credentials).
- **`DiscordAuthCodeMissingException`**: The redirect was parsed but did not contain the authorization code parameter.
- **`DiscordAuthNetworkException`**: A connection or Socket exception occurred during the browser request.

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
