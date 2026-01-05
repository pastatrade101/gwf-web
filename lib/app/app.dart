import 'package:flutter/material.dart';
import '../features/home/home_screen.dart';
import '../pages/e_service_page.dart';
import '../pages/latest_news_page_pro.dart';
import '../pages/tovuti_page.dart';
import '../pages/settings_page.dart';
import '../shared_components/bottom_nav.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      LatestNewsPagePro(),
      EServicesPage(),
      WebsitesPage(), // ✅ not const
      const SettingsPage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: MainBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
