import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'main.dart';
import 'slot_webview.dart';
import 'string_extension.dart';

class SlotView extends StatefulWidget {
  const SlotView(
      {Key? key, required this.id, required this.name, required this.slug})
      : super(key: key);
  final int id;
  final String name;
  final String slug;

  @override
  _SlotView createState() => _SlotView();
}

class _SlotView extends State<SlotView> {
  List<Map<String, dynamic>> _slots = [];
  int _duration = 0;

  void _setSlots(List<Map<String, dynamic>> newSlotList) {
    setState(() {
      _slots = newSlotList;
    });
  }

  void _setDuration(int newDuration) {
    setState(() {
      _duration = newDuration;
    });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      Provider.of<GlobalViewModel>(context, listen: false)
          .setLoadingOverlay(true);
      await _getDuration(context);
      bool foundSlot = false;
      while (!foundSlot) {
        if (mounted) {
          foundSlot = await _getSlots(context);
          await Future.delayed(const Duration(seconds: 15));
        } else {
          foundSlot = true;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 35, 10, 15),
              child: Material(
                  child: ListView.separated(
                      itemCount: _slots.length,
                      itemBuilder: (BuildContext context, int position) {
                        return _itemList(context, position);
                      },
                      separatorBuilder: (context, index) {
                        return const Divider();
                      })),
            ),
            Padding(
                padding: const EdgeInsets.fromLTRB(15, 25, 0, 0),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  splashRadius: 20,
                  splashColor: Theme.of(context).primaryColor,
                  iconSize: 35,
                )),
            _slots.isEmpty
                ? Padding(
                    padding: EdgeInsets.fromLTRB(
                        50, MediaQuery.of(context).size.height / 3, 50, 0),
                    child: Column(children: [
                      Text(
                        'There is currently no slot available for your project ${widget.name.toTitleCase()}.\n\nThe app will send you a notification once one is available.',
                        textAlign: TextAlign.center,
                      ),
                      Lottie.asset(
                        kIsWeb
                            ? '../assets/spaceLottie3.json'
                            : 'assets/spaceLottie3.json',
                        width: 360 / 2,
                        height: 202 / 2,
                        fit: BoxFit.fill,
                      ),
                    ]),
                  )
                : const SizedBox.shrink()
          ],
        ),
        floatingActionButton: IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            _getSlots(context);
          },
          splashRadius: 20,
          splashColor: Theme.of(context).primaryColor,
          iconSize: 35,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endTop);
  }

  Widget _itemList(BuildContext context, int i) {
    final DateTime startDate = DateTime.parse(_slots[i]['start']);
    final DateTime endDate = DateTime.parse(_slots[i]['end']);
    final DateFormat formatter = DateFormat('EEEE d MMMM H:m:s');
    final String startDateFormatted = formatter.format(startDate.toLocal());
    final String endDateFormatted = formatter.format(endDate.toLocal());

    return ListTile(
      title: Text(
        '${_slots[i]['title']}',
        style: const TextStyle(fontSize: 14),
      ),
      subtitle: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('start: $startDateFormatted',
                style: const TextStyle(fontSize: 10)),
            Text('end:   $endDateFormatted',
                style: const TextStyle(fontSize: 10))
          ]),
      onTap: () {
        _showListSlots(_slots[i]);
      },
    );
  }

  void _showListSlots(Map<String, dynamic> currSlot) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Select a slot'),
            content: SizedBox(
                height: 300.0,
                width: 300.0,
                child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: currSlot['slots']
                        .sublist(0, currSlot['slots'].length - _duration + 1)
                        .length,
                    itemBuilder: (BuildContext context, int position) {
                      return _itemListSlots(context, position, currSlot);
                    },
                    separatorBuilder: (context, index) {
                      return const Divider();
                    })),
          );
        });
  }

  Widget _itemListSlots(
      BuildContext context, int i, Map<String, dynamic> slots) {
    return ListTile(
      title: Row(children: [
        const Icon(Icons.arrow_right),
        Text(
          slots['slots'][i],
          style: const TextStyle(fontSize: 14),
        ),
      ]),
      onTap: () {
        log("id: ${widget.id.toString()} \nslug: ${widget.slug.toString()} \nrequiredDate: ${slots['requiredDate'].toString()} \nweekDatIndex: ${slots['weekdayIndex'].toString()} \ni: ${i.toString()}");
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SlotWebView(
                    id: widget.id,
                    slug: widget.slug,
                    timeSlotClass: slots['requiredDate'],
                    weekDayIndex: slots['weekdayIndex'],
                    slotIndex: i,
                  )),
        );
      },
    );
  }

  Future<bool> _getSlots(BuildContext context) async {
    String cookie =
        Provider.of<GlobalViewModel>(context, listen: false).userCookie;

    final startDate = DateTime.now().subtract(const Duration(days: 1));
    final endDate = DateTime.now().add(const Duration(days: 14));
    String startDateApiFormated = dateApiFormat(startDate);
    String endDateApiFormated = dateApiFormat(endDate);
    final responseSlots = await http.get(
        Uri.parse(
            'https://projects.intra.42.fr/projects/${widget.slug}/slots.json?team_id=${widget.id}&start=$startDateApiFormated&end=$endDateApiFormated'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Cookie': '_intra_42_session_production=$cookie',
        });

    if (responseSlots.statusCode != 200) {
      log(jsonEncode(responseSlots.statusCode));
      log(jsonEncode(responseSlots.body));
      Provider.of<GlobalViewModel>(context, listen: false)
          .setLoadingOverlay(false);
      return false;
    } else {
      List<Map<String, dynamic>> slotList =
          List.from((await jsonDecode(responseSlots.body)));
      // slotList = [
      //   {
      //     "ids":
      //         "yD_b7L0yTbutopcGF4-2iA==,iBC9i0q86Kk61AbWP9kZkQ==,fuvko-R7-WZk63g_RRg88g==,fuvko-R7-WZk63g_RRg88g==,fuvko-R7-WZk63g_RRg88g==,fuvko-R7-WZk63g_RRg88g==,fuvko-R7-WZk63g_RRg88g==,fuvko-R7-WZk63g_RRg88g==,fuvko-R7-WZk63g_RRg88g==,fuvko-R7-WZk63g_RRg88g==,fuvko-R7-WZk63g_RRg88g==,fuvko-R7-WZk63g_RRg88g==,fuvko-R7-WZk63g_RRg88g==,fuvko-R7-WZk63g_RRg88g==,fuvko-R7-WZk63g_RRg88g==,fuvko-R7-WZk63g_RRg88g==",
      //     "start": "2022-04-08T12:00:00.000+02:00",
      //     "end": "2022-04-08T15:45:00.000+02:00",
      //     "id": "iBC9i0q86Kk61AbWP9kZkQ==",
      //     "title": "Available"
      //   }
      // ];
      // comparer les deux listes. Si différente, trigger notification

      for (var slot in slotList) {
        DateTime startDate = DateTime.parse(slot['start']);
        DateTime endDate = DateTime.parse(slot['end']);
        String requiredDate =
            '${dateRequiredFormat(startDate)} - ${dateRequiredFormat(endDate)}';
        slot['requiredDate'] = requiredDate;
        slot['weekdayIndex'] = getWeekdayIndex(startDate);
        slot['slots'] = [];
        for (var i = 0; i < slot['ids'].split(',').length; i++) {
          slot['slots']
              .add(dateListFormat(startDate.add(Duration(minutes: 15 * i))));
        }
      }

      _setSlots(slotList);
      log(slotList.toString());

      FlutterLocalNotificationsPlugin notificationSystem =
          Provider.of<GlobalViewModel>(context, listen: false)
              .notificationSystem;
      NotificationDetails platformChannelSpecifics =
          Provider.of<GlobalViewModel>(context, listen: false)
              .platformChannelSpecifics;
      Provider.of<GlobalViewModel>(context, listen: false)
          .setLoadingOverlay(false);
      if (slotList.isEmpty) {
        return false;
      } else {
        // found slot
        await notificationSystem.show(0, 'Found a slot !',
            'For ${widget.name} project', platformChannelSpecifics,
            payload: 'Default_Sound');
        return true;
      }
    }
  }

  Future<bool> _getDuration(BuildContext context) async {
    String cookie =
        Provider.of<GlobalViewModel>(context, listen: false).userCookie;
    final responseSlots = await http.get(
        Uri.parse(
            'https://projects.intra.42.fr/projects/${widget.slug}/slots?team_id=${widget.id}'),
        headers: {
          'Cookie': '_intra_42_session_production=$cookie',
        });

    if (responseSlots.statusCode != 200) {
      return false;
    } else {
      String page = (responseSlots.body).toString();
      final regexp = RegExp(r"data-duration='([\d])'");
      final match = regexp.firstMatch(page);
      final durationFound = int.parse(match?.group(1) ?? "0");
      _setDuration(durationFound);
      return true;
    }
  }

  String dateApiFormat(DateTime date) {
    return '${date.year}-${date.month < 10 ? '0' + date.month.toString() : date.month}-${date.day < 10 ? '0' + date.day.toString() : date.day}';
  }

  String dateListFormat(DateTime date) {
    DateFormat part1;
    const locale = "en_US";
    initializeDateFormatting(locale);
    part1 = DateFormat.EEEE(locale).add_Hm();
    return part1.format(date.toLocal());
  }

  String dateRequiredFormat(DateTime date) {
    DateFormat part1;
    const locale = "en_US";
    initializeDateFormatting(locale);
    part1 = DateFormat.jm(locale);
    return part1.format(date.toLocal());
  }

  int getWeekdayIndex(DateTime date) {
    List<String> weekdaysAbr = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun'
    ];
    DateFormat weekday;
    const locale = "en_US";
    initializeDateFormatting(locale);
    weekday = DateFormat.E(locale);
    int index = 1;
    for (var weekdayAbr in weekdaysAbr) {
      if (weekdayAbr == weekday.format(date.toLocal())) {
        return index;
      }
      ++index;
    }
    return 1;
  }
}
