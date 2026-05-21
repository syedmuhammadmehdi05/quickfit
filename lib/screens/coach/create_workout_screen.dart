import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_theme.dart';
import '../../models/app_user.dart';
import '../../services/auth_provider.dart';
import '../../services/user_service.dart';
import '../../services/workout_service.dart';

// ── Workout Template Model ────────────────────────────────────────────────────
class _WorkoutTemplate {
  final String category;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const _WorkoutTemplate({
    required this.category,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

const List<_WorkoutTemplate> _templates = [
  // ── Upper Body ────────────────────────────────────────────────────────────
  _WorkoutTemplate(
    category: 'Upper Body',
    icon: Icons.fitness_center,
    color: AppTheme.primary,
    title: 'Push Day',
    description:
        '4×8 Bench Press\n3×10 Incline Dumbbell Press\n3×12 Lateral Raises\n3×12 Overhead Shoulder Press\n3×15 Tricep Pushdowns\n\nRest 60–90 sec between sets.\nFocus on controlled eccentric (lowering) phase.',
  ),
  _WorkoutTemplate(
    category: 'Upper Body',
    icon: Icons.fitness_center,
    color: AppTheme.primary,
    title: 'Pull Day',
    description:
        '4×8 Barbell Rows\n3×10 Lat Pulldowns\n3×12 Seated Cable Rows\n3×12 Face Pulls\n3×15 Bicep Curls\n\nRest 60–90 sec between sets.\nKeep core braced throughout all pulling movements.',
  ),
  // ── Lower Body ────────────────────────────────────────────────────────────
  _WorkoutTemplate(
    category: 'Lower Body',
    icon: Icons.directions_run,
    color: AppTheme.coral,
    title: 'Leg Strength Day',
    description:
        '4×6 Back Squats\n3×10 Romanian Deadlifts\n3×12 Leg Press\n3×12 Walking Lunges (each leg)\n3×15 Leg Curls\n\nRest 90–120 sec between sets.\nWarm up with 2 light sets before working weight.',
  ),
  _WorkoutTemplate(
    category: 'Lower Body',
    icon: Icons.directions_run,
    color: AppTheme.coral,
    title: 'Glute & Hamstring',
    description:
        '3×12 Hip Thrusts\n3×10 Romanian Deadlifts\n3×12 Sumo Squats\n3×15 Cable Kickbacks (each leg)\n3×15 Lying Leg Curls\n\nRest 60 sec between sets.\nFocus on mind-muscle connection in glutes.',
  ),
  // ── Core ──────────────────────────────────────────────────────────────────
  _WorkoutTemplate(
    category: 'Core',
    icon: Icons.self_improvement,
    color: AppTheme.accent,
    title: 'Core Stability',
    description:
        '3×30s Plank Hold\n3×20 Bicycle Crunches\n3×15 Hanging Knee Raises\n3×12 Ab Wheel Rollouts\n3×20 Russian Twists\n\nRest 45 sec between sets.\nBreathe out on exertion, brace core throughout.',
  ),
  _WorkoutTemplate(
    category: 'Core',
    icon: Icons.self_improvement,
    color: AppTheme.accent,
    title: 'Abs & Obliques',
    description:
        '3×20 Crunches\n3×15 Side Plank (each side)\n3×12 Leg Raises\n3×20 Woodchoppers (each side)\n3×30s Dead Bug\n\nRest 45 sec between sets.\nKeep lower back pressed to floor during floor work.',
  ),
  // ── Cardio ────────────────────────────────────────────────────────────────
  _WorkoutTemplate(
    category: 'Cardio',
    icon: Icons.directions_bike,
    color: AppTheme.purple,
    title: 'Steady State Cardio',
    description:
        '5 min warm-up walk\n30 min moderate-pace jog (Zone 2 — can hold a conversation)\n5 min cool-down walk\n\nTarget heart rate: 60–70% of max HR.\nStay hydrated. Aim for 3× per week.',
  ),
  _WorkoutTemplate(
    category: 'Cardio',
    icon: Icons.directions_bike,
    color: AppTheme.purple,
    title: 'Interval Running',
    description:
        '5 min warm-up jog\n8 rounds: 30 sec sprint → 90 sec walk\n5 min cool-down walk\n\nTotal: ~25 min.\nPush to 85–90% effort during sprints.\nFocus on recovery breathing in rest periods.',
  ),
  // ── Full Body ─────────────────────────────────────────────────────────────
  _WorkoutTemplate(
    category: 'Full Body',
    icon: Icons.sports_gymnastics,
    color: AppTheme.primaryDark,
    title: 'Full Body Strength',
    description:
        '3×8 Deadlifts\n3×10 Bench Press\n3×10 Pull-Ups (or Lat Pulldowns)\n3×12 Overhead Press\n3×12 Goblet Squats\n3×15 Core Plank\n\nRest 90 sec between sets.\nGreat for 3×/week training frequency.',
  ),
  _WorkoutTemplate(
    category: 'Full Body',
    icon: Icons.sports_gymnastics,
    color: AppTheme.primaryDark,
    title: 'Beginner Full Body',
    description:
        '3×10 Bodyweight Squats\n3×10 Push-Ups\n3×10 Dumbbell Rows (each arm)\n3×12 Dumbbell Lunges\n3×12 Dumbbell Shoulder Press\n3×30s Plank\n\nRest 60 sec between exercises.\nPerfect starting point — focus on form!',
  ),
  // ── HIIT ──────────────────────────────────────────────────────────────────
  _WorkoutTemplate(
    category: 'HIIT',
    icon: Icons.local_fire_department,
    color: AppTheme.coral,
    title: '20-Min HIIT Blast',
    description:
        '4 rounds of:\n• 40 sec Burpees → 20 sec rest\n• 40 sec Jump Squats → 20 sec rest\n• 40 sec Mountain Climbers → 20 sec rest\n• 40 sec High Knees → 20 sec rest\n\nRest 90 sec between rounds.\nKeep intensity high during work periods!',
  ),
  _WorkoutTemplate(
    category: 'HIIT',
    icon: Icons.local_fire_department,
    color: AppTheme.coral,
    title: 'Tabata Circuit',
    description:
        '8 rounds of (20 sec on / 10 sec off) for each exercise:\n1. Jump Squats\n2. Push-Ups\n3. Box Jumps\n4. Plank to Downward Dog\n\nComplete all 8 rounds before moving to next exercise.\nTotal: ~16 min of intense work.',
  ),
  // ── Flexibility ───────────────────────────────────────────────────────────
  _WorkoutTemplate(
    category: 'Flexibility',
    icon: Icons.spa,
    color: AppTheme.purple,
    title: 'Recovery Stretch',
    description:
        'Hold each stretch 30–45 seconds:\n• Hamstring stretch (seated)\n• Hip flexor lunge stretch\n• Chest and shoulder stretch\n• Thoracic spine rotation\n• Pigeon pose (each side)\n• Child\'s pose\n\nBreath deeply throughout. No bouncing.',
  ),
];

// ── Screen ────────────────────────────────────────────────────────────────────
class CreateWorkoutScreen extends StatefulWidget {
  final AppUser? student;
  const CreateWorkoutScreen({super.key, this.student});

  @override
  State<CreateWorkoutScreen> createState() => _CreateWorkoutScreenState();
}

class _CreateWorkoutScreenState extends State<CreateWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  AppUser? _selectedStudent;
  bool _loading = false;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedStudent = widget.student;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  // ── Template browser ─────────────────────────────────────────────────────
  void _openTemplateBrowser() {
    final categories =
        _templates.map((t) => t.category).toSet().toList();
    String activeCategory = _selectedCategory ?? categories.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardBgOf(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, ctrl) => Column(
            children: [
              // Handle
              const SizedBox(height: 12),
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
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text('Workout Templates',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimaryOf(context))),
                    const Spacer(),
                    Text('${_templates.length} plans',
                        style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textHintOf(context))),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Category tabs
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final cat = categories[i];
                    final active = cat == activeCategory;
                    return GestureDetector(
                      onTap: () => setSheet(() => activeCategory = cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: active
                              ? AppTheme.primary
                              : AppTheme.surfaceOf(context),
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(
                              color: active
                                  ? AppTheme.primary
                                  : AppTheme.borderOf(context)),
                        ),
                        child: Text(cat,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: active
                                    ? Colors.white
                                    : AppTheme.textSecondaryOf(context))),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              // Template list
              Expanded(
                child: ListView(
                  controller: ctrl,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: _templates
                      .where((t) => t.category == activeCategory)
                      .map((t) => _TemplateCard(
                            template: t,
                            onSelect: () {
                              setState(() {
                                _titleCtrl.text = t.title;
                                _descCtrl.text = t.description;
                                _selectedCategory = t.category;
                              });
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      '✅ "${t.title}" template loaded'),
                                  backgroundColor: AppTheme.primary,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedStudent == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a student.'),
          backgroundColor: AppTheme.coral,
        ),
      );
      return;
    }
    setState(() => _loading = true);
    final coach = context.read<AuthProvider>().currentUser!;
    try {
      await WorkoutService().createWorkout(
        coachId: coach.uid,
        studentId: _selectedStudent!.uid,
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
      );
      if (mounted) {
        context.read<AuthProvider>().refreshUser();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Workout assigned! ✅'),
            backgroundColor: AppTheme.primary,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.coral,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign Workout'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Template browser button
          TextButton.icon(
            onPressed: _openTemplateBrowser,
            icon: const Icon(Icons.library_books_outlined, size: 18),
            label: const Text('Templates'),
            style: TextButton.styleFrom(foregroundColor: AppTheme.primary),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Student picker ───────────────────────────────────────────
              Text('Student',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimaryOf(context))),
              const SizedBox(height: 8),
              if (widget.student != null)
                _StudentTile(student: widget.student!)
              else
                StreamBuilder<List<AppUser>>(
                  stream: UserService().getAllStudents(),
                  builder: (context, snap) {
                    final students = snap.data ?? [];
                    return DropdownButtonFormField<AppUser>(
                      value: _selectedStudent,
                      decoration: const InputDecoration(
                          hintText: 'Select a student'),
                      items: students
                          .map((s) => DropdownMenuItem(
                                value: s,
                                child: Text(s.name,
                                    style:
                                        const TextStyle(fontSize: 14)),
                              ))
                          .toList(),
                      onChanged: (s) =>
                          setState(() => _selectedStudent = s),
                      validator: (_) => _selectedStudent == null
                          ? 'Select a student'
                          : null,
                    );
                  },
                ),
              const SizedBox(height: 24),

              // ── Template hint banner ─────────────────────────────────────
              GestureDetector(
                onTap: _openTemplateBrowser,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppTheme.primary.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.auto_awesome,
                          color: AppTheme.primary, size: 18),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Use a ready-made workout template — or write your own below.',
                          style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios,
                          color: AppTheme.primary, size: 14),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Title ────────────────────────────────────────────────────
              Text('Workout Title',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimaryOf(context))),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleCtrl,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: 'e.g. Upper Body Strength Day',
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // ── Instructions ─────────────────────────────────────────────
              Text('Instructions',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimaryOf(context))),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descCtrl,
                maxLines: 9,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText:
                      'e.g. 3×10 Push-Ups\n3×12 Dumbbell Rows\nRest 60 sec between sets…',
                  alignLabelWithHint: true,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Enter workout instructions';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('Assign Workout'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Template Card ─────────────────────────────────────────────────────────────
class _TemplateCard extends StatelessWidget {
  final _WorkoutTemplate template;
  final VoidCallback onSelect;

  const _TemplateCard({required this.template, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceOf(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderOf(context)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: template.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(template.icon, color: template.color, size: 20),
          ),
          title: Text(template.title,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryOf(context))),
          childrenPadding:
              const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(template.description,
                  style: TextStyle(
                      fontSize: 13,
                      height: 1.7,
                      color: AppTheme.textSecondaryOf(context))),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onSelect,
                style: ElevatedButton.styleFrom(
                  backgroundColor: template.color,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: const Text('Use This Template'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Student Tile ──────────────────────────────────────────────────────────────
class _StudentTile extends StatelessWidget {
  final AppUser student;
  const _StudentTile({required this.student});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppTheme.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.person, color: AppTheme.primary, size: 18),
          const SizedBox(width: 8),
          Text(student.name,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.primary)),
        ],
      ),
    );
  }
}
