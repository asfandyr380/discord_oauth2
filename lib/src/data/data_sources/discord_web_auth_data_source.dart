import 'dart:io';
import 'package:discord_oauth2/src/core/exceptions.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

abstract interface class DiscordWebAuthDataSource {
  Future<String> authenticate({required String url, required String scheme});
}

class DiscordWebAuthDataSourceImpl implements DiscordWebAuthDataSource {
  @override
  Future<String> authenticate({
    required String url,
    required String scheme,
  }) async {
    try {
      return await FlutterWebAuth2.authenticate(
        url: url,
        callbackUrlScheme: scheme,
      );
    } on PlatformException catch (e) {
      if (e.code == 'CANCELED') {
        throw const DiscordAuthCancelledException();
      }
      throw DiscordAuthFailedException(
        'Web authentication failed with platform exception',
        e,
      );
    } on SocketException catch (e) {
      throw DiscordAuthNetworkException(e);
    } catch (e) {
      throw DiscordAuthFailedException(
        'Web authentication flow cancelled or failed',
        e,
      );
    }
  }
}
