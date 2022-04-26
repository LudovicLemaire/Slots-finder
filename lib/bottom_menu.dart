import 'package:flutter/material.dart';

class BottomMenu extends StatefulWidget {
  const BottomMenu({Key? key, required this.selectedIndex}) : super(key: key);
  final Function(int) selectedIndex;

  @override
  _BottomMenuState createState() => _BottomMenuState();
}

class _BottomMenuState extends State<BottomMenu> {
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      selectedItemColor: const Color(0xFF7289da),
      selectedIconTheme:
          const IconThemeData(color: Color(0xFF7289da), size: 30),
      selectedFontSize: 15,
      elevation: 5,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.schedule_send),
          label: 'Your slots',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.content_paste_search),
          label: 'Find slot',
        ),
      ],
      currentIndex: _selectedIndex,
      onTap: (v) {
        _onItemTapped(v);
        widget.selectedIndex(v);
      },
    );
  }
}
