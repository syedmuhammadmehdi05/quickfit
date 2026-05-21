import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_theme.dart';
import '../../models/app_user.dart';
import '../../services/auth_provider.dart';
import '../../services/user_service.dart';
import '../../widgets/common_widgets.dart';
import 'create_workout_screen.dart';

class CoachStudentsScreen extends StatelessWidget {
  const CoachStudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final coachId = context.watch<AuthProvider>().currentUser!.uid;
    return StreamBuilder<List<AppUser>>(
      stream: UserService().studentsForCoach(coachId),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const LoadingOverlay();
        }
        final students = snap.data ?? [];
        if (students.isEmpty) {
          return const EmptyState(
            icon: Icons.people_outline,
            message: 'No students yet',
            subMessage: 'Students will appear here once they sign up.',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: students.length,
          itemBuilder: (context, i) {
            final student = students[i];
            return _StudentCard(student: student);
          },
        );
      },
    );
  }
}

class _StudentCard extends StatelessWidget {
  final AppUser student;

  const _StudentCard({required this.student});

  @override
  Widget build(BuildContext context) {
    final stats = student.studentStats;
    final rate = stats?.weeklyCompletionRate ?? 0.0;

    Color rateColor;
    if (rate >= 0.7) {
      rateColor = AppTheme.primary;
    } else if (rate >= 0.4) {
      rateColor = AppTheme.accent;
    } else {
      rateColor = AppTheme.coral;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              UserAvatar(name: student.name),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(student.name,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreateWorkoutScreen(student: student),
                  ),
                ),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 14, color: AppTheme.primary),
                      SizedBox(width: 4),
                      Text('Assign',
                          style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _StatPill(
                  label: 'Workouts',
                  value: '${stats?.workoutsCompleted ?? 0}',
                  color: AppTheme.primary),
              const SizedBox(width: 8),
              _StatPill(
                  label: 'Challenges',
                  value: '${stats?.challengesJoined ?? 0}',
                  color: AppTheme.accent),
              const SizedBox(width: 8),
              _StatPill(
                  label: 'Wins',
                  value: '${stats?.challengesWon ?? 0}',
                  color: AppTheme.coral),
              const Spacer(),
              Text('${(rate * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: rateColor)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: rate,
              backgroundColor: AppTheme.border,
              color: rateColor,
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 4),
          const Align(
            alignment: Alignment.centerRight,
            // FIX 2: Made Text const (removed conflicting inner const on TextStyle)
            child: Text('weekly completion rate',
                style: TextStyle(fontSize: 10, color: AppTheme.textHint)),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatPill(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        // FIX 3: withOpacity() deprecated → use withValues(alpha:)
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color)),
          Text(label,
              style: const TextStyle(
                  fontSize: 10, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}
