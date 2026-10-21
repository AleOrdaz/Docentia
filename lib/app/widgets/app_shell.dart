import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_bottom_nav_bar.dart';

class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}

class SlidingNavigationContainer extends StatefulWidget {
  final int currentIndex;
  final List<Widget> children;

  const SlidingNavigationContainer({
    super.key,
    required this.currentIndex,
    required this.children,
  });

  @override
  State<SlidingNavigationContainer> createState() =>
      _SlidingNavigationContainerState();
}

class _SlidingNavigationContainerState extends State<SlidingNavigationContainer> {
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: widget.currentIndex);
  }

  @override
  void didUpdateWidget(SlidingNavigationContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex && _controller.hasClients) {
      _controller.animateToPage(
        widget.currentIndex,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _controller,
      physics: const NeverScrollableScrollPhysics(),
      children: widget.children,
    );
  }
}
