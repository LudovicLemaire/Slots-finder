import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'main.dart';
import 'credentials.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class GetToken extends StatefulWidget {
  const GetToken({Key? key}) : super(key: key);

  @override
  _GetToken createState() => _GetToken();
}

class _GetToken extends State<GetToken> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      Provider.of<GlobalViewModel>(context, listen: false)
          .setLoadingOverlay(true);
      await getToken(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

Future<bool> getToken(BuildContext context) async {
  final responseToken =
      await http.post(Uri.parse('https://api.intra.42.fr/oauth/token'),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({
            'grant_type': 'client_credentials',
            'client_id': CLIENT_UID,
            'client_secret': CLIENT_SECRET,
          }));

  if (responseToken.statusCode != 200) {
    return false;
  } else {
    Provider.of<GlobalViewModel>(context, listen: false).setToken(
        jsonDecode(responseToken.body)['access_token'],
        jsonDecode(responseToken.body)['expires_in'],
        context);
    return true;
  }
}
