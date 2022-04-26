import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'credentials.dart';
import 'main.dart';

class GetUserToken extends StatefulWidget {
  const GetUserToken({Key? key}) : super(key: key);

  @override
  _GetUserToken createState() => _GetUserToken();
}

class _GetUserToken extends State<GetUserToken> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      await getUserToken(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

Future<bool> getUserToken(BuildContext context) async {
  final responseToken =
      await http.post(Uri.parse('https://api.intra.42.fr/v2/oauth/token'),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({
            'grant_type': 'authorization_code',
            'client_id': CLIENT_UID,
            'client_secret': CLIENT_SECRET,
            'code': Provider.of<GlobalViewModel>(context, listen: false).code,
            'redirect_uri': 'http://localhost:5000/',
          }));

  if (responseToken.statusCode != 200) {
    return false;
  } else {
    Provider.of<GlobalViewModel>(context, listen: false).setUserToken(
        await jsonDecode(responseToken.body)['access_token'],
        await jsonDecode(responseToken.body)['refresh_token'],
        await jsonDecode(responseToken.body)['expires_in'],
        context);
    return true;
  }
}

Future<bool> refreshUserToken(BuildContext context) async {
  final responseToken =
      await http.post(Uri.parse('https://api.intra.42.fr/v2/oauth/token'),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({
            'grant_type': 'refresh_token',
            'client_id': CLIENT_UID,
            'client_secret': CLIENT_SECRET,
            'refresh_token':
                Provider.of<GlobalViewModel>(context, listen: false)
                    .userTokenRefresh,
            'redirect_uri': 'http://localhost:5000/',
          }));

  if (responseToken.statusCode != 200) {
    return false;
  } else {
    Provider.of<GlobalViewModel>(context, listen: false).setUserToken(
        await jsonDecode(responseToken.body)['access_token'],
        await jsonDecode(responseToken.body)['refresh_token'],
        await jsonDecode(responseToken.body)['expires_in'],
        context);
    return true;
  }
}
