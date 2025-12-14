import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'bottom_navigation_bar.dart';
import 'floating_action_button_handler.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;

    return Scaffold(
      body: child,
      bottomNavigationBar: CustomBottomNavigationBar(currentPath: currentPath),
      floatingActionButton: FloatingActionButtonHandler(
        currentPath: currentPath,
      ),
    );
  }
}
