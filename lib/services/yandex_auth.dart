import 'dart:convert';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;
import 'package:ya_disk_explorer/utils/token_storage.dart';

class YandexAuth {
  static const String clientId = "53f12fa4f3ec453fb06dbd21ed463f42";
  static const String clientSecret = "309c59ba35174aa0bf9b3f44df2db0a2";
  static const String redirectUri = "com.yourapp://callback";

  static const String authUrl = "https://oauth.yandex.ru/authorize";
  static const String tokenUrl = "https://oauth.yandex.ru/token";

  static Future<void> authenticate() async {
    try {
      final result = await FlutterWebAuth2.authenticate(
        url: "$authUrl?response_type=code&client_id=$clientId&redirect_uri=$redirectUri",
        callbackUrlScheme: "com.yourapp",
      );

      final code = Uri.parse(result).queryParameters['code'];

      if (code != null) {
        await exchangeCodeForToken(code);
      }
    } catch (_) {}
  }

  static Future<void> exchangeCodeForToken(String authorizationCode) async {
    try {
      final response = await http.post(
        Uri.parse(tokenUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'authorization_code',
          'code': authorizationCode,
          'client_id': clientId,
          'client_secret': clientSecret,
          'redirect_uri': redirectUri,
        },
      );

      if (response.statusCode == 200) {
        final tokenData = json.decode(response.body);

        if (tokenData.containsKey('access_token')) {
          TokenStorage.saveToken(tokenData['access_token']);
        }
      }
    } catch (_) {}
  }
}
