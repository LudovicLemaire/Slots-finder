import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:ft_sus/credentials.dart';
import 'package:provider/provider.dart';

import 'main.dart';

class GetCodeView extends StatefulWidget {
  const GetCodeView({Key? key}) : super(key: key);

  @override
  _GetCodeViewState createState() => _GetCodeViewState();
}

class _GetCodeViewState extends State<GetCodeView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      Provider.of<GlobalViewModel>(context, listen: false)
          .setLoadingOverlay(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    CookieManager _cookieManager = CookieManager.instance();

    return Column(
      children: <Widget>[
        Expanded(
            child: InAppWebView(
                initialUrlRequest: URLRequest(url: Uri.parse(AUTHORIZE_URL)),
                initialOptions: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(
                    mediaPlaybackRequiresUserGesture: false,
                  ),
                ),
                onLoadStart:
                    (InAppWebViewController controller, Uri? url) async {
                  if (url?.host == 'localhost') {
                    Provider.of<GlobalViewModel>(context, listen: false)
                        .setLoadingOverlay(true);
                    Provider.of<GlobalViewModel>(context, listen: false)
                        .setCode(url.toString().split('=')[1]);
                  }
                },
                onLoadStop:
                    (InAppWebViewController controller, Uri? url) async {
                  if (url?.host != 'localhost') {
                    List<Cookie> cookies =
                        await _cookieManager.getCookies(url: url as Uri);
                    for (var cookie in cookies) {
                      if (cookie.name == '_intra_42_session_production') {
                        Provider.of<GlobalViewModel>(context, listen: false)
                            .setUserCookie(cookie.value);
                      }
                    }
                  }
                },
                onWebViewCreated: (InAppWebViewController controller) {},
                androidOnPermissionRequest: (InAppWebViewController controller,
                    String origin, List<String> resources) async {
                  return PermissionRequestResponse(
                      resources: resources,
                      action: PermissionRequestResponseAction.GRANT);
                }))
      ],
    );
  }
}
