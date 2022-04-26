import 'package:flutter/material.dart';

import 'bottom_menu.dart';
import 'project_list_view.dart';
import 'own_slots_view.dart';

class GetSlotApp extends StatefulWidget {
  const GetSlotApp({Key? key}) : super(key: key);

  @override
  _GetSlotAppState createState() => _GetSlotAppState();
}

class _GetSlotAppState extends State<GetSlotApp> {
  int _selectedIndexParent = 1;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndexParent = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      const OwnSlotsView(),
      const ProjectListView(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Get Slots App'),
        backgroundColor: const Color(0xFF7289da),
      ),
      body: IndexedStack(
        index: _selectedIndexParent,
        children: pages,
      ),
      bottomNavigationBar: BottomMenu(
        selectedIndex: _onItemTapped,
      ),
    );
  }
}
