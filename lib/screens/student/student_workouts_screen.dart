import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_theme.dart';
import '../../models/workout.dart';
import '../../services/auth_provider.dart';
import '../../services/workout_service.dart';
import '../../widgets/common_widgets.dart';

class StudentWorkoutsScreen extends StatefulWidget {
  const StudentWorkoutsScreen({super.key});

  @override
  State<StudentWorkoutsScreen> createState() => _StudentWorkoutsScreenState();
}

class _StudentWorkoutsScreenState extends State<StudentWorkoutsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser!;
    final service = WorkoutService();

    return Column(
      children: [
        Container(
          color: AppTheme.cardBgOf(context),
          child: TabBar(
            controller: _tabCtrl,
            labelColor: AppTheme.primary,
            unselectedLabelColor: AppTheme.textHintOf(context),
            indicatorColor: AppTheme.primary,
            tabs: const [
              Tab(text: 'Pending'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Workout>>(
            stream: service.studentWorkouts(user.uid),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const LoadingOverlay();
              }
              final all = snap.data ?? [];
              final pending = all.where((w) => !w.isCompleted).toList();
              final done = all.where((w) => w.isCompleted).toList();

              return TabBarView(
                controller: _tabCtrl,
                children: [
                  _WorkoutList(
                    workouts: pending,
                    userId: user.uid,
                    emptyMessage: 'No pending workouts',
                    emptySubMessage: 'Your coach will assign workouts here.',
                    emptyIcon: Icons.fitness_center_outlined,
                  ),
                  _WorkoutList(
                    workouts: done,
                    userId: user.uid,
                    emptyMessage: 'No completed workouts yet',
                    emptySubMessage: 'Complete your first workout to see it here.',
                    emptyIcon: Icons.check_circle_outline,
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _WorkoutList extends StatelessWidget {
  final List<Workout> workouts;
  final String userId;
  final String emptyMessage;
  final String? emptySubMessage;
  final IconData emptyIcon;

  const _WorkoutList({
    required this.workouts,
    required this.userId,
    required this.emptyMessage,
    this.emptySubMessage,
    required this.emptyIcon,
  });

  @override
  Widget build(BuildContext context) {
    if (workouts.isEmpty) {
      return EmptyState(
        icon: emptyIcon,
        message: emptyMessage,
        subMessage: emptySubMessage,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: workouts.length,
      itemBuilder: (context, i) {
        final w = workouts[i];
        return WorkoutCard(
          workout: w,
          onTap: () => _showDetail(context, w),
          onComplete: !w.isCompleted
              ? () => _showCompleteDialog(context, w)
              : null,
        );
      },
    );
  }

  void _showDetail(BuildContext context, Workout w) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardBgOf(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, ctrl) => SingleChildScrollView(
          controller: ctrl,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.borderOf(context),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(w.title,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimaryOf(context))),
                  ),
                  if (w.isCompleted)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: const Text('Completed',
                          style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w500)),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Instructions',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondaryOf(context))),
              const SizedBox(height: 8),
              Text(w.description,
                  style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textPrimaryOf(context),
                      height: 1.6)),
              if (w.studentNotes != null && w.studentNotes!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text('Your Notes',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondaryOf(context))),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.accentLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(w.studentNotes!,
                      style: TextStyle(
                          fontSize: 13, color: AppTheme.textPrimaryOf(context))),
                ),
              ],
              if (!w.isCompleted) ...[
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showCompleteDialog(context, w);
                    },
                    child: const Text('Mark as Complete'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showCompleteDialog(BuildContext context, Workout w) {
    final notesCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Complete Workout'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mark "${w.title}" as complete?',
                style: TextStyle(
                    fontSize: 14, color: AppTheme.textSecondaryOf(context))),
            const SizedBox(height: 14),
            TextField(
              controller: notesCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Add notes (optional)...',
                labelText: 'Notes',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: TextStyle(color: AppTheme.textSecondaryOf(context))),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await WorkoutService().completeWorkout(
                w.id,
                userId,
                notesCtrl.text.isNotEmpty ? notesCtrl.text : null,
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Workout completed! 🎉'),
                    backgroundColor: AppTheme.primary,
                  ),
                );
                context.read<AuthProvider>().refreshUser();
              }
            },
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }
}
