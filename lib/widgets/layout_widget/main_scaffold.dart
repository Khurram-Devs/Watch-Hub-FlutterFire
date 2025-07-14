import 'package:flutter/material.dart';
import 'package:watch_hub_ep/widgets/layout_widget/app_header.dart';
import 'package:watch_hub_ep/widgets/layout_widget/nav_drawer.dart';
import 'package:watch_hub_ep/widgets/layout_widget/bottom_navbar.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;
  final int? currentIndex;

  const MainScaffold({
    super.key,
    required this.child,
    this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(),
      drawer: const NavDrawer(),
      body: SafeArea(child: child),
      bottomNavigationBar: currentIndex != null
          ? AdaptiveBottomNavBar(currentIndex: currentIndex!)
          : null,
    );
  }
}
