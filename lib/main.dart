import 'package:flutter/material.dart';
import 'package:local_notifications_app/core/app_theme.dart';
import 'package:local_notifications_app/routing/app_router.dart';
import 'package:local_notifications_app/routing/routes.dart';
import 'package:local_notifications_app/services/notification_service.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();

  // App open (foreground/background) -> user taps a notification
  NotificationService.onNotificationClick = (payload) {
    navigatorKey.currentState?.pushNamed(Routes.motivation, arguments: payload);
  };
  // App was closed -> opened by tapping a notification
  final launchPayload = await NotificationService.getLaunchPayload();

  runApp(MyApp(launchPayload: launchPayload));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.launchPayload});

  final String? launchPayload;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Study Reminder',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      navigatorKey: navigatorKey,
      initialRoute: Routes.home,
      onGenerateRoute: AppRouter.generateRoute,
      onGenerateInitialRoutes: (initialRoute) => [
        AppRouter.generateRoute(RouteSettings(name: initialRoute))!,
        if (launchPayload != null)
          AppRouter.generateRoute(
            RouteSettings(name: Routes.motivation, arguments: launchPayload),
          )!,
      ],
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text('Page not found')),
          body: const Center(child: Text("We couldn't find that page.")),
        ),
      ),
    );
  }
}
