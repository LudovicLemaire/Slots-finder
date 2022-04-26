import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';

import 'main.dart';

class OwnSlotsView extends StatefulWidget {
  const OwnSlotsView({Key? key}) : super(key: key);

  @override
  _OwnSlotsView createState() => _OwnSlotsView();
}

class _OwnSlotsView extends State<OwnSlotsView> {
  List<Map<String, dynamic>> _slots = [];

  void _setSlots(List<Map<String, dynamic>> newSlotList) {
    setState(() {
      _slots = newSlotList;
    });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      await _getSlots(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
              child: Material(
                  child: _slots.isNotEmpty
                      ? ListView.separated(
                          itemCount: _slots.length,
                          itemBuilder: (BuildContext context, int position) {
                            return _itemList(context, position);
                          },
                          separatorBuilder: (context, index) {
                            return const Divider();
                          })
                      : const Center(
                          child: Padding(
                          padding: EdgeInsets.fromLTRB(25, 0, 25, 0),
                          child: Text(
                            "You didn't put any slots\n(slots to correct your own projects aren't visible here)",
                            textAlign: TextAlign.center,
                          ),
                        ))),
            ),
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
    );
  }

  // for (var slot in reducedSlots(_slots[i]['slots']))
  Future<void> _getSlots(BuildContext context) async {
    Provider.of<GlobalViewModel>(context, listen: false)
        .setLoadingOverlay(true);
    String cookie =
        Provider.of<GlobalViewModel>(context, listen: false).userCookie;

    final startDate = DateTime.now().subtract(const Duration(days: 1));
    final endDate = DateTime.now().add(const Duration(days: 6));
    String startDateApiFormated = dateApiFormat(startDate);
    String endDateApiFormated = dateApiFormat(endDate);
    final responseSlots = await http.get(
        Uri.parse(
            'https://profile.intra.42.fr/slots.json?start=$startDateApiFormated&end=$endDateApiFormated'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Cookie': '_intra_42_session_production=$cookie',
        });

    // 4078066

    if (responseSlots.statusCode != 200) {
      log(jsonEncode(responseSlots.statusCode));
      log(jsonEncode(responseSlots.body));
      Provider.of<GlobalViewModel>(context, listen: false)
          .setLoadingOverlay(false);
    } else {
      List<Map<String, dynamic>> slotList =
          List.from((await jsonDecode(responseSlots.body)));

      _setSlots(slotList);

      Provider.of<GlobalViewModel>(context, listen: false)
          .setLoadingOverlay(false);
    }
  }

  String dateConfirmFormat(DateTime date) {
    DateFormat part1;
    const locale = "fr";
    initializeDateFormatting(locale);
    part1 = DateFormat.EEEE(locale).add_Hm();
    return part1.format(date.toLocal());
  }

  String dateApiFormat(DateTime date) {
    return '${date.year}-${date.month < 10 ? '0' + date.month.toString() : date.month}-${date.day < 10 ? '0' + date.day.toString() : date.day}';
  }
}
