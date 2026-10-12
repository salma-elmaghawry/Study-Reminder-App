import 'package:flutter/material.dart';
import 'package:local_notifications_app/core/app_theme.dart';
import 'package:local_notifications_app/core/reminder_ids.dart';
import 'package:local_notifications_app/services/notification_service.dart';
import 'package:local_notifications_app/widgets/action_tile.dart';
import 'package:local_notifications_app/widgets/reminder_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TimeOfDay? _reminderTime;

  void _showMessage(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  // <<---------------------- Part 2: Permission ---------->>
  Future<void> _allowNotifications() async {
    final granted = await NotificationService.requestPermission();
    if (mounted) _showMessage(granted ? 'Allowed ✅' : 'Denied ❌');
  }

  // <<---------------------- Part 2: First notification ---------->>
  Future<void> _testNotification() {
    return NotificationService.showNotification(
      id: ReminderIds.test,
      title: 'Notifications are working 🎉',
      body: 'You will get your study reminders here',
      payload: 'test_notification',
    );
  }

  // <<---------------------- Part 3: Quick scheduled test ---------->>
  Future<void> _remindIn10Seconds() async {
    await NotificationService.scheduleAfter(
      id: ReminderIds.quick,
      title: 'Study time 📚',
      body: 'This is a quick test reminder',
      duration: const Duration(seconds: 10),
      payload: 'quick_reminder',
    );
    if (mounted) _showMessage('Reminder in 10 seconds, close the app!');
  }

  // <<---------------------- Part 3: Daily reminder ---------->>
  Future<void> _pickStudyTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return; // user pressed cancel

    await NotificationService.scheduleDaily(
      id: ReminderIds.daily,
      title: 'Study time 📚',
      body: 'Open your notes, just 25 minutes!',
      hour: time.hour,
      minute: time.minute,
      payload: 'daily_reminder',
    );

    if (!mounted) return;
    setState(() => _reminderTime = time);
    _showMessage('Daily reminder at ${time.format(context)}');
  }

  // <<---------------------- Part 3: Cancel only the daily reminder ---------->>
  Future<void> _cancelReminder() async {
    await NotificationService.cancel(ReminderIds.daily);
    setState(() => _reminderTime = null);
    _showMessage('Reminder cancelled');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          children: [
            const Text(
              'Hello 👋',
              style: TextStyle(fontSize: 16, color: AppColors.textMuted),
            ),
            const SizedBox(height: 4),
            const Text(
              'Ready to study today?',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 24),
            ReminderCard(
              reminderTime: _reminderTime,
              onPickTime: _pickStudyTime,
              onCancel: _cancelReminder,
            ),
            const SizedBox(height: 32),
            const Text(
              'Try it out',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            ActionTile(
              icon: Icons.notifications_active_outlined,
              color: Colors.teal,
              title: 'Allow notifications',
              subtitle: 'Android 13+ and iOS ask first',
              onTap: _allowNotifications,
            ),
            ActionTile(
              icon: Icons.bolt,
              color: AppColors.accent,
              title: 'Test notification now',
              subtitle: 'Shows instantly',
              onTap: _testNotification,
            ),
            ActionTile(
              icon: Icons.timer_outlined,
              color: Colors.pinkAccent,
              title: 'Remind me in 10 seconds',
              subtitle: 'Close the app and wait',
              onTap: _remindIn10Seconds,
            ),
          ],
        ),
      ),
    );
  }
}
