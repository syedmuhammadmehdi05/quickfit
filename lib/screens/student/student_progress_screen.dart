import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/app_theme.dart';
import '../../models/workout.dart';
import '../../services/auth_provider.dart';
import '../../services/workout_service.dart';
import '../../widgets/common_widgets.dart';

class StudentProgressScreen extends StatelessWidget {
  const StudentProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser!;
    final stats = user.studentStats;

    return StreamBuilder<List<Workout>>(
      stream: WorkoutService().studentWorkouts(user.uid),
      builder: (context, snap) {
        final workouts = snap.data ?? [];
        final completed = workouts.where((w) => w.isCompleted).toList();
        final pending = workouts.where((w) => !w.isCompleted).toList();

        // Build weekly data (last 4 weeks)
        final weeklyData = _buildWeeklyData(completed);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary cards
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.3,
                children: [
                  StatCard(
                    label: 'Total Completed',
                    value: '${stats?.workoutsCompleted ?? 0}',
                    icon: Icons.check_circle_outline,
                    color: AppTheme.primary,
                  ),
                  StatCard(
                    label: 'Pending',
                    value: '${pending.length}',
                    icon: Icons.pending_outlined,
                    color: AppTheme.accent,
                  ),
                  StatCard(
                    label: 'Challenges Won',
                    value: '${stats?.challengesWon ?? 0}',
                    icon: Icons.military_tech_outlined,
                    color: AppTheme.coral,
                  ),
                  StatCard(
                    label: 'Weekly Rate',
                    value:
                        '${((stats?.weeklyCompletionRate ?? 0) * 100).toStringAsFixed(0)}%',
                    icon: Icons.trending_up,
                    color: AppTheme.purple,
                    progress: stats?.weeklyCompletionRate ?? 0,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Weekly completion chart
              const SectionHeader(title: 'Weekly Completions'),
              Container(
                height: 200,
                padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
                decoration: BoxDecoration(
                  color: AppTheme.cardBgOf(context),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderOf(context)),
                ),
                child: weeklyData.every((v) => v == 0)
                    ? Center(
                        child: Text('Complete workouts to see your chart',
                            style: TextStyle(
                                color: AppTheme.textHintOf(context), fontSize: 13)))
                    : BarChart(
                        BarChartData(
                          backgroundColor: Colors.transparent,
                          alignment: BarChartAlignment.spaceAround,
                          maxY: (weeklyData.reduce((a, b) => a > b ? a : b) + 2)
                              .toDouble(),
                          barTouchData: BarTouchData(enabled: false),
                          titlesData: FlTitlesData(
                            leftTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (val, _) {
                                  final labels = ['3w ago', '2w ago', 'Last wk', 'This wk'];
                                  return Text(
                                    labels[val.toInt()],
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: AppTheme.textHintOf(context)),
                                  );
                                },
                              ),
                            ),
                          ),
                          gridData: const FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                          barGroups: List.generate(4, (i) {
                            return BarChartGroupData(
                              x: i,
                              barRods: [
                                BarChartRodData(
                                  toY: weeklyData[i].toDouble(),
                                  color: i == 3
                                      ? AppTheme.primary
                                      : AppTheme.primary.withOpacity(0.4),
                                  width: 28,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
              ),
              const SizedBox(height: 8),

              // Recent completions
              if (completed.isNotEmpty) ...[
                const SectionHeader(title: 'Recent Completions'),
                ...completed.take(5).map((w) => WorkoutCard(workout: w)),
              ],
            ],
          ),
        );
      },
    );
  }

  List<int> _buildWeeklyData(List<Workout> completed) {
    final now = DateTime.now();
    return List.generate(4, (i) {
      final weekStart =
          now.subtract(Duration(days: now.weekday - 1 + (3 - i) * 7));
      final weekEnd = weekStart.add(const Duration(days: 7));
      return completed
          .where((w) =>
              w.completedAt != null &&
              w.completedAt!.isAfter(weekStart) &&
              w.completedAt!.isBefore(weekEnd))
          .length;
    });
  }
}
