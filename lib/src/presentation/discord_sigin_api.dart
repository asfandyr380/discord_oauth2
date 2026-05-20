import 'package:discord_oauth2/src/data/data_sources/discord_web_auth_data_source.dart';
import 'package:discord_oauth2/src/data/repositories/discord_auth_repo_impl.dart';
import 'package:discord_oauth2/src/domain/repositories/discord_auth_repository.dart';

class DiscordSignIn {
  final String clientId;
  final String redirectUri;
  final String customScheme;
  final List<String> scopes;

  late final DiscordAuthRepository _repository;

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

  /// Triggers the system browser and returns the temporary
  /// authorization code required by your backend server.
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
