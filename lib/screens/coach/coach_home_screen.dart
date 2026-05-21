import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_theme.dart';
import '../../services/auth_provider.dart';
import '../../services/theme_provider.dart';
import '../../widgets/common_widgets.dart';
import 'coach_students_screen.dart';
import 'coach_workouts_screen.dart';
import 'coach_challenges_screen.dart';

class CoachHomeScreen extends StatefulWidget {
  const CoachHomeScreen({super.key});

  @override
  State<CoachHomeScreen> createState() => _CoachHomeScreenState();
}

class _CoachHomeScreenState extends State<CoachHomeScreen> {
  int _tab = 0;

  final _screens = const [
    _CoachDashboard(),
    CoachStudentsScreen(),
    CoachWorkoutsScreen(),
    CoachChallengesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser!;
    final themeP = context.read<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: _tab == 0
            ? Row(children: [
                UserAvatar(name: user.name, isCoach: true),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Coach ${user.name.split(' ').first}',
                        style: const TextStyle(fontSize: 16)),
                    Text('Your dashboard',
                        style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondaryOf(context),
                            fontWeight: FontWeight.w400)),
                  ],
                ),
              ])
            : Text(['Dashboard', 'Students', 'Workouts', 'Challenges'][_tab]),
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
          setState(() => _tab = i);
          context.read<AuthProvider>().refreshUser();
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              activeIcon: Icon(Icons.people),
              label: 'Students'),
          BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center_outlined),
              activeIcon: Icon(Icons.fitness_center),
              label: 'Workouts'),
          BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events_outlined),
              activeIcon: Icon(Icons.emoji_events),
              label: 'Challenges'),
        ],
      ),
    );
  }
}

class _CoachDashboard extends StatelessWidget {
  const _CoachDashboard();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser!;
    final stats = user.coachStats;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.3,
            children: [
              StatCard(
                label: 'Students Trained',
                value: '${stats?.totalStudentsTrained ?? 0}',
                icon: Icons.people_outline,
                color: AppTheme.purple,
              ),
              StatCard(
                label: 'Rating',
                value: stats?.rating != null && stats!.rating > 0
                    ? stats.rating.toStringAsFixed(1)
                    : '-',
                icon: Icons.star_outline,
                color: AppTheme.accent,
              ),
              StatCard(
                label: 'Workouts Created',
                value: '${stats?.totalWorkoutsCreated ?? 0}',
                icon: Icons.fitness_center_outlined,
                color: AppTheme.primary,
              ),
              StatCard(
                label: 'Active Role',
                value: 'Coach',
                icon: Icons.verified_outlined,
                color: AppTheme.coral,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Motivational banner
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.purple, Color(0xFF5952B0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.purple.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Manage your students',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                      SizedBox(height: 4),
                      Text('Assign workouts & track progress.',
                          style: TextStyle(
                              fontSize: 12, color: Colors.white70)),
                    ],
                  ),
                ),
                Icon(Icons.school, color: Colors.white, size: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
