import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_theme.dart';
import '../../models/app_user.dart';
import '../../services/auth_provider.dart';
import '../../services/user_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _empIdCtrl = TextEditingController();

  UserRole _role = UserRole.student;
  bool _obscure = true;

  AppUser? _selectedCoach;
  late Future<List<AppUser>> _coachesFuture;

  @override
  void initState() {
    super.initState();
    _coachesFuture = UserService().getAllCoaches();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _empIdCtrl.dispose();
    super.dispose();
  }

  void _onRoleChanged(UserRole role) {
    setState(() {
      _role = role;
      _selectedCoach = null;
      _empIdCtrl.clear();
      if (role == UserRole.student) {
        _coachesFuture = UserService().getAllCoaches();
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_role == UserRole.student && _selectedCoach == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a coach to continue.'),
          backgroundColor: AppTheme.coral,
        ),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final ok = await auth.signUp(
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
      name: _nameCtrl.text.trim(),
      role: _role,
      employeeId: _role == UserRole.coach ? _empIdCtrl.text.trim() : null,
      coachId: _role == UserRole.student ? _selectedCoach?.uid : null,
    );

    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Sign up failed'),
          backgroundColor: AppTheme.coral,
        ),
      );
    } else if (ok && mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Create Account',
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary)),
                const SizedBox(height: 6),
                const Text('Join QuickFit today',
                    style: TextStyle(fontSize: 15, color: AppTheme.textSecondary)),
                const SizedBox(height: 32),

                // Role selector
                const Text('I am a...',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _RoleOption(
                      label: 'Student',
                      icon: Icons.school_outlined,
                      selected: _role == UserRole.student,
                      onTap: () => _onRoleChanged(UserRole.student),
                    ),
                    const SizedBox(width: 12),
                    _RoleOption(
                      label: 'Coach',
                      icon: Icons.fitness_center_outlined,
                      selected: _role == UserRole.coach,
                      onTap: () => _onRoleChanged(UserRole.coach),
                      accentColor: AppTheme.purple,
                      accentLight: AppTheme.purpleLight,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Full Name
                TextFormField(
                  controller: _nameCtrl,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outline, size: 20),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Enter your name';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Email
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined, size: 20),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Enter your email';
                    if (!v.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Password
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter a password';
                    if (v.length < 6) return 'At least 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // ── Student: choose a coach ──────────────────────────────
                if (_role == UserRole.student) ...[
                  const Text('Select Your Coach',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary)),
                  const SizedBox(height: 8),
                  FutureBuilder<List<AppUser>>(
                    future: _coachesFuture,
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Center(
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  color: AppTheme.primary, strokeWidth: 2),
                            ),
                          ),
                        );
                      }
                      final coaches = snap.data ?? [];
                      if (coaches.isEmpty) {
                        return _InfoBanner(
                          icon: Icons.info_outline,
                          message:
                              'No coaches registered yet. Ask your coach to sign up first, then come back.',
                          color: AppTheme.accent,
                          bgColor: AppTheme.accentLight,
                        );
                      }
                      final validSelected = coaches.any(
                              (co) => co.uid == _selectedCoach?.uid)
                          ? _selectedCoach
                          : null;
                      return DropdownButtonFormField<AppUser>(
                        value: validSelected,
                        decoration: const InputDecoration(
                          hintText: 'Choose your coach',
                          prefixIcon:
                              Icon(Icons.fitness_center_outlined, size: 20),
                        ),
                        items: coaches
                            .map((co) => DropdownMenuItem(
                                  value: co,
                                  child: Text(co.name,
                                      style: const TextStyle(fontSize: 14)),
                                ))
                            .toList(),
                        onChanged: (co) => setState(() => _selectedCoach = co),
                        validator: (_) =>
                            _role == UserRole.student && _selectedCoach == null
                                ? 'Please select a coach'
                                : null,
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                ],

                // ── Coach: Employee ID gate ────────────────────────────────
                if (_role == UserRole.coach) ...[
                  _InfoBanner(
                    icon: Icons.badge_outlined,
                    message:
                        'A valid Employee ID is required to register as a coach. Contact your administrator if you don\'t have one.',
                    color: AppTheme.purple,
                    bgColor: AppTheme.purpleLight,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _empIdCtrl,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    decoration: const InputDecoration(
                      labelText: 'Employee ID',
                      prefixIcon: Icon(Icons.badge_outlined, size: 20),
                      hintText: 'e.g. EMP001',
                    ),
                    validator: (v) {
                      if (_role != UserRole.coach) return null;
                      if (v == null || v.trim().isEmpty) {
                        return 'Employee ID is required for coaches';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                ],

                // Submit
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: auth.isLoading ? null : _submit,
                    child: auth.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text('Create Account'),
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account? ',
                        style: TextStyle(color: AppTheme.textSecondary)),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text('Sign In',
                          style: TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Info Banner ───────────────────────────────────────────────────────────────
class _InfoBanner extends StatelessWidget {
  final IconData icon;
  final String message;
  final Color color;
  final Color bgColor;

  const _InfoBanner({
    required this.icon,
    required this.message,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message,
                style: TextStyle(fontSize: 13, color: color)),
          ),
        ],
      ),
    );
  }
}

// ── Role Option ───────────────────────────────────────────────────────────────
class _RoleOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final Color accentColor;
  final Color accentLight;

  const _RoleOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.accentColor = AppTheme.primary,
    this.accentLight = AppTheme.primaryLight,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: selected ? accentLight : AppTheme.cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? accentColor : AppTheme.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  color: selected ? accentColor : AppTheme.textHint, size: 26),
              const SizedBox(height: 6),
              Text(label,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: selected ? accentColor : AppTheme.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}
