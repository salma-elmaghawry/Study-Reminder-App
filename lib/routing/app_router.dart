import 'package:flutter/material.dart';
import 'package:local_notifications_app/routing/routes.dart';
import 'package:local_notifications_app/screens/motivation_screen.dart';
import 'package:local_notifications_app/screens/home_screen.dart';

class AppRouter {
  // Nullable on purpose: returning null lets MaterialApp.onUnknownRoute
  // show the "page not found" screen.
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // '/' can still arrive after a hot reload, so send it to Home too
      case '/':
      case Routes.home:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const HomeScreen(),
        );

      case Routes.motivation:
        final payload = settings.arguments as String?;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => MotivationScreen(payload: payload),
        );

      default:
        return null;
    }
  }
}
