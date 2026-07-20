import 'package:flutter/material.dart';
import '../../domain/entities/achievement.dart';

class AchievementsPage extends StatelessWidget {
  final List<Achievement> achievements;

  const AchievementsPage({super.key, required this.achievements});

  @override
  Widget build(BuildContext context) {
    final unlockedCount = achievements.where((a) => a.isUnlocked).length;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Column(
              children: [
                Text(
                  '$unlockedCount / ${achievements.length} Unlocked',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: achievements.isNotEmpty ? unlockedCount / achievements.length : 0,
                  minHeight: 8,
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: achievements.length,
              itemBuilder: (context, index) {
                final achievement = achievements[index];
                return _AchievementCard(achievement: achievement);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;

  const _AchievementCard({required this.achievement});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              achievement.isUnlocked ? Icons.emoji_events : Icons.lock_outline,
              size: 32,
              color: achievement.isUnlocked ? Colors.amber : Colors.grey,
            ),
            const SizedBox(height: 4),
            Text(
              achievement.name,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              achievement.description,
              style: TextStyle(fontSize: 9, color: Colors.grey[600]),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
