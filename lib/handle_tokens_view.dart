import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import '../main.dart';

import 'get_code.dart';
import 'get_slot_app.dart';
import 'get_token.dart';
import 'get_user_token.dart';

class HandleTokens extends StatefulWidget {
  const HandleTokens({Key? key}) : super(key: key);

  @override
  _HandleTokens createState() => _HandleTokens();
}

class _HandleTokens extends State<HandleTokens> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(seconds: 1));
      initNotificationSystem();
    });
  }

  @override
  Widget build(BuildContext context) {
    return (Provider.of<GlobalViewModel>(context).token == '' ||
            Provider.of<GlobalViewModel>(context).code == '' ||
            Provider.of<GlobalViewModel>(context).userToken == '')
        ? Scaffold(
            appBar: AppBar(
              title: const Text('Get Slots App'),
              backgroundColor: const Color(0xFF7289da),
            ),
            body: _showCorrectCollectView(),
          )
        : const GetSlotApp();
  }

  Widget _showCorrectCollectView() {
    if (Provider.of<GlobalViewModel>(context).token == '') {
      return const GetToken();
    } else if (Provider.of<GlobalViewModel>(context).code == '') {
      return const GetCodeView();
    } else if (Provider.of<GlobalViewModel>(context).userToken == '') {
      return const GetUserToken();
    } else {
      return const SizedBox.shrink();
    }
  }

  void initNotificationSystem() {
    FlutterLocalNotificationsPlugin notificationSystem =
        Provider.of<GlobalViewModel>(context, listen: false).notificationSystem;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOS = IOSInitializationSettings();

    const settings = InitializationSettings(android: android, iOS: iOS);
    notificationSystem.initialize(settings);
    Provider.of<GlobalViewModel>(context, listen: false)
        .setNotificationSystem(notificationSystem);
  }
}
