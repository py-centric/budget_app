import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/reminder_bloc.dart';
import '../bloc/reminder_state.dart';
import '../pages/reminders_page.dart';

class BillReminderBadge extends StatelessWidget {
  final Widget child;

  const BillReminderBadge({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReminderBloc, ReminderState>(
      builder: (context, state) {
        if (state is ReminderLoaded && state.unreadCount > 0) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              child,
              Positioned(
                right: -4,
                top: -4,
                child: GestureDetector(
                  onTap: () => _showRemindersPage(context),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withValues(alpha: 0.3),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      state.unreadCount > 9 ? '9+' : '${state.unreadCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          );
        }
        return child;
      },
    );
  }

  void _showRemindersPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RemindersPage()),
    );
  }
}

class ReminderIndicator extends StatelessWidget {
  final int unreadCount;

  const ReminderIndicator({super.key, required this.unreadCount});

  @override
  Widget build(BuildContext context) {
    if (unreadCount == 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 16),
            SizedBox(width: 4),
            Text(
              'All caught up!',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.notifications_active,
            color: Colors.orange,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            '$unreadCount upcoming bill${unreadCount > 1 ? 's' : ''}',
            style: const TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
