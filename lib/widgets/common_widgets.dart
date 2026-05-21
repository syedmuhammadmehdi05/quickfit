import 'package:flutter/material.dart';
import '../models/app_theme.dart';
import '../models/workout.dart';
import '../models/challenge.dart';
import 'package:intl/intl.dart';

// ─────────────────────────────────────────────
// StatCard  (theme-aware)
// ─────────────────────────────────────────────
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;
  final String? subtitle;
  final double? progress;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.color,
    this.subtitle,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.primary;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBgOf(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderOf(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: c.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, color: c, size: 17),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 10),
          Text(value,
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimaryOf(context))),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  fontSize: 12, color: AppTheme.textSecondaryOf(context))),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle!,
                style: TextStyle(
                    fontSize: 11, color: AppTheme.textHintOf(context))),
          ],
          if (progress != null) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppTheme.borderOf(context),
                color: c,
                minHeight: 5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// WorkoutCard  (theme-aware)
// ─────────────────────────────────────────────
class WorkoutCard extends StatelessWidget {
  final Workout workout;
  final String? coachName;
  final VoidCallback? onTap;
  final VoidCallback? onComplete;
  final VoidCallback? onDelete;

  const WorkoutCard({
    super.key,
    required this.workout,
    this.coachName,
    this.onTap,
    this.onComplete,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardBgOf(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: workout.isCompleted
                ? AppTheme.primary.withValues(alpha: 0.3)
                : AppTheme.borderOf(context),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: workout.isCompleted
                      ? AppTheme.primary
                      : AppTheme.borderOf(context),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(workout.title,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimaryOf(context))),
                  const SizedBox(height: 3),
                  Text(
                    workout.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondaryOf(context)),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (coachName != null)
                        _meta(context, Icons.person_outline, coachName!),
                      const SizedBox(width: 8),
                      _meta(
                        context,
                        Icons.calendar_today_outlined,
                        DateFormat('MMM d').format(workout.createdAt),
                      ),
                      if (workout.isCompleted &&
                          workout.completedAt != null) ...[
                        const SizedBox(width: 8),
                        _meta(
                          context,
                          Icons.check_circle_outline,
                          'Done ${DateFormat('MMM d').format(workout.completedAt!)}',
                          color: AppTheme.primary,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                _StatusChip(isCompleted: workout.isCompleted),
                if (onComplete != null && !workout.isCompleted) ...[
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: onComplete,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('Mark done',
                          style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w500)),
                    ),
                  ),
                ],
                if (onDelete != null) ...[
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: onDelete,
                    child: Icon(Icons.delete_outline,
                        size: 18, color: AppTheme.textHintOf(context)),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _meta(BuildContext ctx, IconData icon, String text,
      {Color? color}) {
    return Row(
      children: [
        Icon(icon,
            size: 11, color: color ?? AppTheme.textHintOf(ctx)),
        const SizedBox(width: 3),
        Text(text,
            style: TextStyle(
                fontSize: 11,
                color: color ?? AppTheme.textHintOf(ctx))),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final bool isCompleted;
  const _StatusChip({required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isCompleted ? AppTheme.primaryLight : AppTheme.accentLight,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        isCompleted ? 'Done' : 'Pending',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color:
              isCompleted ? AppTheme.primary : AppTheme.accent,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ChallengeCard  (theme-aware)
// ─────────────────────────────────────────────
class ChallengeCard extends StatelessWidget {
  final Challenge challenge;
  final String currentUserId;
  final VoidCallback? onJoin;
  final VoidCallback? onTap;

  const ChallengeCard({
    super.key,
    required this.challenge,
    required this.currentUserId,
    this.onJoin,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isJoined =
        challenge.participants.any((p) => p.userId == currentUserId);
    final sorted = [...challenge.participants]
      ..sort((a, b) => b.score.compareTo(a.score));

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardBgOf(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderOf(context)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(challenge.title,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimaryOf(context))),
                ),
                _statusBadge(challenge),
              ],
            ),
            const SizedBox(height: 4),
            Text(challenge.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondaryOf(context))),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 12, color: AppTheme.textHintOf(context)),
                const SizedBox(width: 4),
                Text(
                  '${DateFormat('MMM d').format(challenge.startDate)} – '
                  '${DateFormat('MMM d, y').format(challenge.endDate)}',
                  style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.textHintOf(context)),
                ),
                const Spacer(),
                Icon(Icons.people_outline,
                    size: 12, color: AppTheme.textHintOf(context)),
                const SizedBox(width: 4),
                Text('${challenge.participants.length} joined',
                    style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textHintOf(context))),
              ],
            ),
            if (sorted.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('Leaderboard',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondaryOf(context))),
              const SizedBox(height: 6),
              ...sorted.take(3).toList().asMap().entries.map((e) {
                final rank = e.key + 1;
                final p = e.value;
                final isMe = p.userId == currentUserId;
                return _LeaderboardRow(
                    rank: rank, participant: p, isMe: isMe);
              }),
            ],
            if (!isJoined && challenge.isActive && onJoin != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onJoin,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text('Join Challenge'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(Challenge c) {
    String label;
    Color bg;
    Color fg;
    if (c.isUpcoming) {
      label = 'Upcoming';
      bg = AppTheme.purpleLight;
      fg = AppTheme.purple;
    } else if (c.isActive) {
      label = 'Active';
      bg = AppTheme.primaryLight;
      fg = AppTheme.primary;
    } else {
      label = 'Ended';
      bg = const Color(0xFFE5E7EB);
      fg = AppTheme.textSecondary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(99)),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w500, color: fg)),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  final int rank;
  final ChallengeParticipant participant;
  final bool isMe;

  const _LeaderboardRow(
      {required this.rank,
      required this.participant,
      required this.isMe});

  @override
  Widget build(BuildContext context) {
    final medal =
        rank == 1 ? '🥇' : rank == 2 ? '🥈' : '🥉';
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isMe
            ? AppTheme.primaryLight
            : (rank == 1
                ? AppTheme.accentLight
                : AppTheme.surfaceOf(context)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(medal, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isMe ? '${participant.userName} (You)' : participant.userName,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                      isMe ? FontWeight.w600 : FontWeight.w400,
                  color: AppTheme.textPrimaryOf(context)),
            ),
          ),
          Text('${participant.score} pts',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: rank == 1 ? AppTheme.accent : AppTheme.primary)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SectionHeader
// ─────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? action;

  const SectionHeader({super.key, required this.title, this.action});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryOf(context))),
          const Spacer(),
          if (action != null) action!,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// LoadingOverlay
// ─────────────────────────────────────────────
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppTheme.primary),
    );
  }
}

// ─────────────────────────────────────────────
// EmptyState
// ─────────────────────────────────────────────
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? subMessage;

  const EmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.subMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.borderOf(context).withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(icon,
                  size: 40, color: AppTheme.textHintOf(context)),
            ),
            const SizedBox(height: 16),
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondaryOf(context))),
            if (subMessage != null) ...[
              const SizedBox(height: 6),
              Text(subMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textHintOf(context))),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// UserAvatar
// ─────────────────────────────────────────────
class UserAvatar extends StatelessWidget {
  final String name;
  final double size;
  final bool isCoach;

  const UserAvatar({
    super.key,
    required this.name,
    this.size = 40,
    this.isCoach = false,
  });

  @override
  Widget build(BuildContext context) {
    final initials = name
        .trim()
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isCoach ? AppTheme.purpleLight : AppTheme.primaryLight,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: size * 0.35,
            fontWeight: FontWeight.w600,
            color: isCoach ? AppTheme.purple : AppTheme.primary,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ThemeToggleButton  (reusable app bar action)
// ─────────────────────────────────────────────
// Import is in the file that uses this widget — coach/student home screens
// pass the toggle callback explicitly to keep common_widgets dependency-free.
class ThemeToggleButton extends StatelessWidget {
  final VoidCallback onToggle;
  const ThemeToggleButton({super.key, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return IconButton(
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, anim) => RotationTransition(
          turns: Tween(begin: 0.75, end: 1.0).animate(anim),
          child: FadeTransition(opacity: anim, child: child),
        ),
        child: Icon(
          isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
          key: ValueKey(isDark),
          size: 20,
        ),
      ),
      tooltip: isDark ? 'Light Mode' : 'Dark Mode',
      onPressed: onToggle,
    );
  }
}
