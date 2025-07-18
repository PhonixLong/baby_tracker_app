import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';
import '../record/record_view.dart';
import '../stats/stats_home_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeView extends StatefulWidget {
  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0;

  static List<Widget> _pages = <Widget>[
    Center(child: Text('首页', style: TextStyle(fontSize: 24))),
    RecordView(),
    StatsPage(),
    Center(child: Text('我的', style: TextStyle(fontSize: 24))),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Baby Tracker', style: TextStyle(fontSize: 20.sp)),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 24.w),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit, size: 24.w),
            label: '记录',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart, size: 24.w),
            label: '统计',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 24.w),
            label: '我的',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        onTap: _onItemTapped,
      ),
    );
  }
}
