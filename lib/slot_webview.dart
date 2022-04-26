import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';

import 'main.dart';

class SlotWebView extends StatefulWidget {
  const SlotWebView(
      {Key? key,
      required this.id,
      required this.slug,
      required this.timeSlotClass,
      required this.weekDayIndex,
      required this.slotIndex})
      : super(key: key);
  final int id;
  final String slug;
  final String timeSlotClass;
  final int weekDayIndex;
  final int slotIndex;

  @override
  _SlotWebViewState createState() => _SlotWebViewState();
}

class _SlotWebViewState extends State<SlotWebView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      Provider.of<GlobalViewModel>(context, listen: false)
          .setLoadingOverlay(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: [
      SizedBox(
          width: 5,
          height: 5,
          child: InAppWebView(
              initialUrlRequest: URLRequest(
                  url: Uri.parse(
                      "https://projects.intra.42.fr/projects/${widget.slug}/slots?team_id=${widget.id}")),
              initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
                  mediaPlaybackRequiresUserGesture: false,
                ),
              ),
              initialUserScripts: UnmodifiableListView<UserScript>([
                UserScript(
                    source: """
                          let timeRef = null;
                          let isLoading = true;

                          (() => {
                            const affelou = setInterval(() => {
                                const loadingComponent = document.querySelector("div#loading");
                                const style = window.getComputedStyle(loadingComponent);

                                isLoading = style.getPropertyValue("display") !== "none";
                            }, 500);
                          })()

                          function simulateAll() {
                              timeRef = setInterval(() => {
                                if (isLoading) { return ;}
                                  try {

                                    const allTds = document.querySelectorAll(".fc-content-skeleton > table > tbody > tr > td");

                                    const event = allTds[${widget.weekDayIndex}].querySelector('[data-full="${widget.timeSlotClass}"]');
                                    event.click();

                                    setTimeout(() => {
                                      const selectSlot = document.querySelector('.modal-body > select');
                                      selectSlot.options.selectedIndex = ${widget.slotIndex};
                                      selectSlot.value = ${widget.slotIndex};

                                      setTimeout(() => {
                                        const okButton = document.querySelector('.btn.btn-primary');
                                        okButton.click();
                                        setTimeout(() => {
                                          window.flutter_inappwebview.callHandler("dataToFlutter", "isOk");
                                        }, 1500);
                                      }, 1000);

                                    }, 1000);
                                    clearInterval(timeRef);
                                    timeRef = null;
                                  } catch(_) {
                                  }
                              }, 100)
                              setTimeout(() => {
                                window.flutter_inappwebview.callHandler("dataToFlutter", "isNotOk");
                              }, 15000);
                        }
                      """,
                    injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START)
              ]),
              onLoadStop: (InAppWebViewController controller, Uri? url) async {
                await controller.evaluateJavascript(
                    source: '(() => {simulateAll() })()');
              },
              onWebViewCreated: (InAppWebViewController controller) {
                controller.addJavaScriptHandler(
                    handlerName: "dataToFlutter",
                    callback: (args) {
                      String returnedArg = args[0];
                      Provider.of<GlobalViewModel>(context, listen: false)
                          .setLoadingOverlay(false);
                      Navigator.pop(context);
                      Navigator.pop(context);
                      Navigator.pop(context);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Scaffold(
                                    body: Stack(children: [
                                  Center(
                                      child: Icon(
                                          returnedArg == 'isOk'
                                              ? Icons.check_circle_outline
                                              : Icons.error_outline,
                                          color: returnedArg == 'isOk'
                                              ? Colors.green
                                              : Colors.red,
                                          size: 100)),
                                  Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          15, 25, 0, 0),
                                      child: IconButton(
                                        icon: const Icon(Icons.arrow_back),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        splashRadius: 20,
                                        splashColor:
                                            Theme.of(context).primaryColor,
                                        iconSize: 35,
                                      )),
                                  Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          50, 135, 50, 0),
                                      child: Center(
                                        child: Text(
                                          (returnedArg == 'isOk')
                                              ? "You should recieve a mail confirming you got it very soon !"
                                              : "Oops, something went wrong.\nThe slot probably doesn't exist anymore.",
                                          textAlign: TextAlign.center,
                                        ),
                                      ))
                                ]))),
                      );
                      return {};
                    });
              },
              androidOnPermissionRequest: (InAppWebViewController controller,
                  String origin, List<String> resources) async {
                return PermissionRequestResponse(
                    resources: resources,
                    action: PermissionRequestResponseAction.GRANT);
              })),
      const Center(
        child: SizedBox.shrink(),
      )
    ]));
  }
}
