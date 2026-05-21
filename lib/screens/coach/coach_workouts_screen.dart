import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_theme.dart';
import '../../models/workout.dart';
import '../../services/auth_provider.dart';
import '../../services/workout_service.dart';
import '../../widgets/common_widgets.dart';
import 'create_workout_screen.dart';

class CoachWorkoutsScreen extends StatelessWidget {
  const CoachWorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser!;
    final service = WorkoutService();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateWorkoutScreen()),
        ),
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Assign Workout',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: StreamBuilder<List<Workout>>(
        stream: service.coachWorkouts(user.uid),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const LoadingOverlay();
          }
          final workouts = snap.data ?? [];
          if (workouts.isEmpty) {
            return const EmptyState(
              icon: Icons.fitness_center_outlined,
              message: 'No workouts assigned yet',
              subMessage: 'Tap the button below to assign a workout to a student.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            itemCount: workouts.length,
            itemBuilder: (context, i) {
              final w = workouts[i];
              return WorkoutCard(
                workout: w,
                onDelete: () => _confirmDelete(context, w.id),
              );
            },
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, String workoutId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Workout'),
        content: const Text(
          'Are you sure you want to delete this workout?',
          style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await WorkoutService().deleteWorkout(workoutId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.coral),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
