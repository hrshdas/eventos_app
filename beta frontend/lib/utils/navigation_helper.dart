import 'package:flutter/material.dart';
import '../screens/main_navigation_screen.dart';

class NavigationHelper {
  static void navigateToMainScreen(BuildContext context, int index) {
    // Pop all routes until we reach the main navigation screen
    Navigator.of(context).popUntil((route) {
      if (route.settings.name == '/main' || route.isFirst) {
        return true;
      }
      return false;
    });
    
    // If we're not on MainNavigationScreen, navigate to it
    if (!Navigator.of(context).canPop()) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => MainNavigationScreen(initialIndex: index),
        ),
      );
    } else {
      // Pop to root and push MainNavigationScreen
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => MainNavigationScreen(initialIndex: index),
        ),
        (route) => false,
      );
    }
  }
}

