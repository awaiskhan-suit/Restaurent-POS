// lib/screens/main_shell.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../bottom_navigation/bottom_navigation.dart';

/// Shell that hosts the four main tabs and a shared bottom navigation bar.
class MainShell extends StatelessWidget {
  const MainShell({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Currently selected tab page
      body: navigationShell,

      // Shared bottom navigation for all four screens
      bottomNavigationBar: MenuBottomNav(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) {
          // Navigate to the branch.
          // If the user taps the already-selected tab,
          // return to that branch’s initial location.
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}