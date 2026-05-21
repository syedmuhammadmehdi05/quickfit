import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_theme.dart';
import '../../services/auth_provider.dart';
import '../../services/theme_provider.dart';
import '../../widgets/common_widgets.dart';
import 'student_workouts_screen.dart';
import 'student_challenges_screen.dart';
import 'student_progress_screen.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  int _tab = 0;

  void _goToTab(int i) => setState(() => _tab = i);

  List<Widget> get _screens => [
        _StudentDashboard(onTabChange: _goToTab),
        const StudentWorkoutsScreen(),
        const StudentChallengesScreen(),
        const StudentProgressScreen(),
      ];

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser!;
    final themeP = context.read<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: _tab == 0
            ? Row(children: [
                UserAvatar(name: user.name),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hey, ${user.name.split(' ').first}! 👋',
                        style: const TextStyle(fontSize: 16)),
                    Text('Ready to train?',
                        style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondaryOf(context),
                            fontWeight: FontWeight.w400)),
                  ],
                ),
              ])
            : Text(['Dashboard', 'Workouts', 'Challenges', 'Progress'][_tab]),
        actions: [
          ThemeToggleButton(onToggle: themeP.toggle),
          IconButton(
            icon: const Icon(Icons.logout_outlined, size: 20),
            onPressed: () => context.read<AuthProvider>().signOut(),
          ),
        ],
      ),
      body: _screens[_tab],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        onTap: (i) {
          _goToTab(i);
          context.read<AuthProvider>().refreshUser();
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center_outlined),
              activeIcon: Icon(Icons.fitness_center),
              label: 'Workouts'),
          BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events_outlined),
              activeIcon: Icon(Icons.emoji_events),
              label: 'Challenges'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: 'Progress'),
        ],
      ),
    );
  }
}

class _StudentDashboard extends StatelessWidget {
  final ValueChanged<int> onTabChange;
  const _StudentDashboard({required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser!;
    final stats = user.studentStats;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.3,
            children: [
              StatCard(
                label: 'Workouts Done',
                value: '${stats?.workoutsCompleted ?? 0}',
                icon: Icons.fitness_center,
                color: AppTheme.primary,
              ),
              StatCard(
                label: 'Challenges Joined',
                value: '${stats?.challengesJoined ?? 0}',
                icon: Icons.emoji_events,
                color: AppTheme.accent,
              ),
              StatCard(
                label: 'Challenges Won',
                value: '${stats?.challengesWon ?? 0}',
                icon: Icons.military_tech,
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

          // Motivation banner
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primary, AppTheme.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Keep going! 💪',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                      SizedBox(height: 4),
                      Text('Check your workouts and stay consistent.',
                          style: TextStyle(
                              fontSize: 12, color: Colors.white70)),
                    ],
                  ),
                ),
                const Icon(Icons.bolt, color: Colors.white, size: 40),
              ],
            ),
          ),

          SectionHeader(title: 'Quick Actions'),
          Row(
            children: [
              _QuickAction(
                icon: Icons.fitness_center_outlined,
                label: 'My Workouts',
                onTap: () => onTabChange(1),
                color: AppTheme.primary,
              ),
              const SizedBox(width: 10),
              _QuickAction(
                icon: Icons.emoji_events_outlined,
                label: 'Challenges',
                onTap: () => onTabChange(2),
                color: AppTheme.accent,
              ),
              const SizedBox(width: 10),
              _QuickAction(
                icon: Icons.bar_chart_outlined,
                label: 'Progress',
                onTap: () => onTabChange(3),
                color: AppTheme.purple,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Weekly progress strip
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardBgOf(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderOf(context)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Weekly Completion',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimaryOf(context))),
                    const Spacer(),
                    Text(
                      '${((stats?.weeklyCompletionRate ?? 0) * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: stats?.weeklyCompletionRate ?? 0,
                    backgroundColor: AppTheme.borderOf(context),
                    color: AppTheme.primary,
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 6),
                Text('Based on workouts this week',
                    style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textHintOf(context))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 6),
              Text(label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
