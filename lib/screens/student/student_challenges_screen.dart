import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/challenge.dart';
import '../../services/auth_provider.dart';
import '../../services/challenge_service.dart';
import '../../widgets/common_widgets.dart';
import '../../models/app_theme.dart';

class StudentChallengesScreen extends StatelessWidget {
  const StudentChallengesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser!;
    final service = ChallengeService();
    final coachId = user.coachId;

    if (coachId == null) {
      return const EmptyState(
        icon: Icons.emoji_events_outlined,
        message: 'No coach assigned',
        subMessage: 'You have no coach linked. Please contact support.',
      );
    }

    return StreamBuilder<List<Challenge>>(
      stream: service.coachChallenges(coachId),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const LoadingOverlay();
        }
        final challenges = snap.data ?? [];
        if (challenges.isEmpty) {
          return const EmptyState(
            icon: Icons.emoji_events_outlined,
            message: 'No challenges yet',
            subMessage: 'Your coach will create challenges here.',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: challenges.length,
          itemBuilder: (context, i) {
            final c = challenges[i];
            return ChallengeCard(
              challenge: c,
              currentUserId: user.uid,
              onJoin: () => _joinChallenge(context, c, user.uid, user.name),
            );
          },
        );
      },
    );
  }

  void _joinChallenge(
      BuildContext context, Challenge c, String uid, String name) async {
    try {
      await ChallengeService().joinChallenge(c.id, uid, name);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Joined "${c.title}"! 🏆'),
            backgroundColor: AppTheme.primary,
          ),
        );
        context.read<AuthProvider>().refreshUser();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to join challenge.'),
            backgroundColor: AppTheme.coral,
          ),
        );
      }
    }
  }
}
