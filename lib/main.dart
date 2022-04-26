import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:skeletons/skeletons.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'get_token.dart';
import 'get_user_token.dart';
import 'handle_tokens_view.dart';

Future<void> main() async => {runApp(const FlutterCompanionAppApp())};

class FlutterCompanionAppApp extends StatelessWidget {
  const FlutterCompanionAppApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GlobalViewModel>(
        create: (BuildContext context) => GlobalViewModel(),
        child: SkeletonTheme(
            darkShimmerGradient: const LinearGradient(colors: [
              Color.fromARGB(255, 84, 84, 134),
              Color.fromARGB(255, 86, 86, 136),
              Color.fromARGB(255, 93, 93, 143),
              Color.fromARGB(255, 86, 86, 136),
              Color.fromARGB(255, 84, 84, 134),
            ]),
            child: MaterialApp(
              title: 'Get Slots App',
              theme: ThemeData.dark().copyWith(
                colorScheme: const ColorScheme.dark()
                    .copyWith(primary: const Color.fromARGB(255, 97, 128, 238)),
                primaryColor: const Color(0xFF7289da),
                secondaryHeaderColor: const Color.fromARGB(255, 93, 93, 143),
              ),
              home: const HandleTokens(),
              builder: (context, child) {
                return Stack(
                  children: [
                    child!,
                    Provider.of<GlobalViewModel>(context).loadingOverlay
                        ? _overlayLoading()
                        : const SizedBox.shrink()
                  ],
                );
              },
            )));
  }

  Widget _overlayLoading() {
    return Stack(children: [
      BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 0.75, sigmaY: 0.75),
        child: Container(
          color: Colors.black.withOpacity(0.65),
        ),
      ),
      Center(
        child: Lottie.asset(
          kIsWeb ? '../assets/spaceLottie3.json' : 'assets/spaceLottie3.json',
          width: 360,
          height: 202,
          fit: BoxFit.fill,
        ),
      )
    ]);
  }
}

NotificationDetails initPlatformChannelSpecifics() {
  const androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'Id',
    'Title',
    channelDescription: 'Description',
    importance: Importance.max,
    priority: Priority.high,
  );
  const iOSPlatformChannelSpecifics = IOSNotificationDetails();

  return const NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics);
}

class GlobalViewModel extends ChangeNotifier {
  String _token = '';
  String _userToken = '';
  String _userTokenRefresh = '';
  String _userCookie = '';
  String _code = '';
  bool _loadingOverlay = false;
  FlutterLocalNotificationsPlugin _notificationSystem =
      FlutterLocalNotificationsPlugin();
  final NotificationDetails _platformChannelSpecifics =
      initPlatformChannelSpecifics();

  String get token => _token;
  String get userToken => _userToken;
  String get userTokenRefresh => _userTokenRefresh;
  String get userCookie => _userCookie;
  String get code => _code;
  bool get loadingOverlay => _loadingOverlay;
  FlutterLocalNotificationsPlugin get notificationSystem => _notificationSystem;
  NotificationDetails get platformChannelSpecifics => _platformChannelSpecifics;

  void setToken(String newToken, int expireIn, BuildContext context) {
    _token = newToken;
    notifyListeners();
    if (expireIn < 250) {
      getToken(context);
    } else {
      _waitExpiresToken(context, expireIn - 150);
    }
  }

  void setUserToken(String newToken, String newRefreshToken, int expireIn,
      BuildContext context) {
    _userToken = newToken;
    _userTokenRefresh = newRefreshToken;
    notifyListeners();
    if (expireIn < 250) {
      refreshUserToken(context);
    } else {
      _waitExpiresTokenUser(context, expireIn - 150);
    }
  }

  void setUserCookie(String newCookie) {
    _userCookie = newCookie;
    notifyListeners();
  }

  void setCode(String newCode) {
    _code = newCode;
    notifyListeners();
  }

  void setLoadingOverlay(bool v) async {
    _loadingOverlay = v;
    notifyListeners();
  }

  void setNotificationSystem(
      FlutterLocalNotificationsPlugin newNotificationSystem) {
    _notificationSystem = newNotificationSystem;
    notifyListeners();
  }

  Future<void> _waitExpiresToken(BuildContext context, int expireIn) async {
    await Future.delayed(Duration(seconds: expireIn));
    getToken(context);
  }

  Future<void> _waitExpiresTokenUser(BuildContext context, int expireIn) async {
    await Future.delayed(Duration(seconds: expireIn));

    refreshUserToken(context);
  }
}
