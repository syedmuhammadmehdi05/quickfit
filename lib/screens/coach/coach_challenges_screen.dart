import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/app_theme.dart';
import '../../models/challenge.dart';
import '../../services/auth_provider.dart';
import '../../services/challenge_service.dart';
import '../../widgets/common_widgets.dart';

class CoachChallengesScreen extends StatelessWidget {
  const CoachChallengesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser!;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context, user.uid),
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Challenge',
            style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: StreamBuilder<List<Challenge>>(
        stream: ChallengeService().coachChallenges(user.uid),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const LoadingOverlay();
          }
          final challenges = snap.data ?? [];
          if (challenges.isEmpty) {
            return const EmptyState(
              icon: Icons.emoji_events_outlined,
              message: 'No challenges created yet',
              subMessage: 'Create a challenge to motivate your students!',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            itemCount: challenges.length,
            itemBuilder: (context, i) {
              final c = challenges[i];
              return ChallengeCard(
                challenge: c,
                currentUserId: user.uid,
              );
            },
          );
        },
      ),
    );
  }

  void _showCreateDialog(BuildContext context, String coachId) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    DateTime? startDate;
    DateTime? endDate;
    final formKey = GlobalKey<FormState>();
    bool loading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.border,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Create Challenge',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary)),
                const SizedBox(height: 20),

                TextFormField(
                  controller: titleCtrl,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Enter a title' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descCtrl,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  decoration:
                      const InputDecoration(labelText: 'Description'),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Enter a description'
                      : null,
                ),
                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: _DatePickerField(
                        label: 'Start Date',
                        date: startDate,
                        onPick: () async {
                          final d = await showDatePicker(
                            context: ctx,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now()
                                .add(const Duration(days: 365)),
                          );
                          if (d != null) {
                            setModalState(() => startDate = d);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DatePickerField(
                        label: 'End Date',
                        date: endDate,
                        onPick: () async {
                          final d = await showDatePicker(
                            context: ctx,
                            initialDate: startDate ??
                                DateTime.now()
                                    .add(const Duration(days: 7)),
                            firstDate: startDate ?? DateTime.now(),
                            lastDate: DateTime.now()
                                .add(const Duration(days: 365)),
                          );
                          if (d != null) {
                            setModalState(() => endDate = d);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: loading
                        ? null
                        : () async {
                            if (!formKey.currentState!.validate()) return;
                            if (startDate == null || endDate == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Select start and end dates.'),
                                  backgroundColor: AppTheme.coral,
                                ),
                              );
                              return;
                            }
                            setModalState(() => loading = true);
                            await ChallengeService().createChallenge(
                              coachId: coachId,
                              title: titleCtrl.text.trim(),
                              description: descCtrl.text.trim(),
                              startDate: startDate!,
                              endDate: endDate!,
                            );
                            if (ctx.mounted) {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Challenge created! 🏆'),
                                  backgroundColor: AppTheme.primary,
                                ),
                              );
                            }
                          },
                    child: loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text('Create Challenge'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onPick;

  const _DatePickerField({
    required this.label,
    required this.date,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPick,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined,
                size: 14, color: AppTheme.textHint),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                date != null
                    ? DateFormat('MMM d, y').format(date!)
                    : label,
                style: TextStyle(
                  fontSize: 13,
                  color: date != null
                      ? AppTheme.textPrimary
                      : AppTheme.textHint,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
