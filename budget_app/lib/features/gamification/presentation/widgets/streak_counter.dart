import 'package:flutter/material.dart';
import '../../domain/entities/savings_streak.dart';

class StreakCounter extends StatelessWidget {
  final SavingsStreak streak;

  const StreakCounter({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                const Icon(Icons.local_fire_department, size: 32, color: Colors.orange),
                const SizedBox(height: 4),
                Text(
                  '${streak.currentStreak}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const Text('Day Streak', style: TextStyle(fontSize: 12)),
              ],
            ),
            Column(
              children: [
                const Icon(Icons.emoji_events, size: 32, color: Colors.amber),
                const SizedBox(height: 4),
                Text(
                  '${streak.longestStreak}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
                const Text('Best Streak', style: TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
