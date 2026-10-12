import 'package:flutter/material.dart';
import 'package:local_notifications_app/core/app_theme.dart';

/// The big purple card on top of Home that shows the daily reminder.
class ReminderCard extends StatelessWidget {
  const ReminderCard({
    super.key,
    required this.reminderTime,
    required this.onPickTime,
    required this.onCancel,
  });

  final TimeOfDay? reminderTime;
  final VoidCallback onPickTime;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final hasReminder = reminderTime != null;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.alarm, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Text(
                'Daily study reminder',
                style: TextStyle(color: Colors.white70, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            hasReminder ? reminderTime!.format(context) : '--:--',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          Text(
            hasReminder ? 'Every day at this time' : 'No reminder set yet',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: onPickTime,
                  icon: Icon(hasReminder ? Icons.edit : Icons.add_alarm),
                  label: Text(hasReminder ? 'Change time' : 'Pick study time'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primaryDark,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              if (hasReminder) ...[
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: onCancel,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54),
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 18,
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
