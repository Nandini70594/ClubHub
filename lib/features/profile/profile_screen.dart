import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../providers/auth_provider.dart';
import '../../providers/club_provider.dart';
import '../../widgets/app_scaffold.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  static const _primary = Color(0xFF3B5BDB);

  // Change-password form
  final _currentPwCtrl = TextEditingController();
  final _newPwCtrl = TextEditingController();
  final _confirmPwCtrl = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _pwLoading = false;
  String? _pwError;
  String? _pwSuccess;

  @override
  void dispose() {
    _currentPwCtrl.dispose();
    _newPwCtrl.dispose();
    _confirmPwCtrl.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    setState(() {
      _pwError = null;
      _pwSuccess = null;
    });

    final newPw = _newPwCtrl.text.trim();
    final confirmPw = _confirmPwCtrl.text.trim();

    if (newPw.isEmpty || _currentPwCtrl.text.isEmpty) {
      setState(() => _pwError = 'Please fill in all fields.');
      return;
    }
    if (newPw.length < 8) {
      setState(() => _pwError = 'New password must be at least 8 characters.');
      return;
    }
    if (newPw != confirmPw) {
      setState(() => _pwError = 'Passwords do not match.');
      return;
    }

    setState(() => _pwLoading = true);

    try {
      // Supabase doesn't expose "verify current password" on client SDK directly.
      // The safest approach without edge functions: re-authenticate by signing in
      // again with the current password, then update.
      final userEmail = Supabase.instance.client.auth.currentUser?.email ?? '';

      await Supabase.instance.client.auth.signInWithPassword(
        email: userEmail,
        password: _currentPwCtrl.text.trim(),
      );

      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: newPw),
      );

      _currentPwCtrl.clear();
      _newPwCtrl.clear();
      _confirmPwCtrl.clear();

      setState(() => _pwSuccess = 'Password updated successfully!');
    } on AuthException catch (e) {
      setState(() => _pwError = e.message);
    } catch (e) {
      setState(() => _pwError = 'Something went wrong. Please try again.');
    } finally {
      setState(() => _pwLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProfileProvider);
    final clubAsync = ref.watch(currentClubProvider);

    return userAsync.when(
      loading: () => const AppScaffold(
        currentRoute: '/profile',
        child: Center(child: CircularProgressIndicator(color: _primary)),
      ),
      error: (e, _) => AppScaffold(
        currentRoute: '/profile',
        child: Center(child: Text('Error: $e')),
      ),
      data: (user) {
        if (user == null) {
          return const AppScaffold(
            currentRoute: '/profile',
            child: Center(child: Text('No user found')),
          );
        }

        return AppScaffold(
          title: 'Profile',
          currentRoute: '/profile',
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // ── Avatar + name card ──────────────────────────────────
              _ProfileCard(user: user, clubAsync: clubAsync),
              const SizedBox(height: 20),

              // ── Change password ─────────────────────────────────────
              _SectionHeader(title: 'Change password'),
              const SizedBox(height: 12),
              _PasswordField(
                controller: _currentPwCtrl,
                label: 'Current password',
                obscure: _obscureCurrent,
                onToggle: () => setState(() => _obscureCurrent = !_obscureCurrent),
              ),
              const SizedBox(height: 12),
              _PasswordField(
                controller: _newPwCtrl,
                label: 'New password',
                obscure: _obscureNew,
                onToggle: () => setState(() => _obscureNew = !_obscureNew),
              ),
              const SizedBox(height: 12),
              _PasswordField(
                controller: _confirmPwCtrl,
                label: 'Confirm new password',
                obscure: _obscureConfirm,
                onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
              ),
              const SizedBox(height: 16),

              // Error / success messages
              if (_pwError != null)
                _MessageBanner(message: _pwError!, isError: true),
              if (_pwSuccess != null)
                _MessageBanner(message: _pwSuccess!, isError: false),
              if (_pwError != null || _pwSuccess != null)
                const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _pwLoading ? null : _changePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _pwLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          'Update password',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  final dynamic user; // AppUser
  final AsyncValue clubAsync;

  const _ProfileCard({required this.user, required this.clubAsync});

  static const _primary = Color(0xFF3B5BDB);

  @override
  Widget build(BuildContext context) {
    final clubName = clubAsync.whenOrNull(data: (c) => c?.clubName) as String?;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          // Avatar circle
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                (user.fullName ?? user.email).substring(0, 1).toUpperCase(),
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: _primary),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName ?? 'No name set',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1F36)),
                ),
                const SizedBox(height: 2),
                Text(
                  user.email,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 6),
                // Role badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    user.role,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _primary),
                  ),
                ),
                // Club name for club_lead
                if (clubName != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    clubName,
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1A1F36)),
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscure;
  final VoidCallback onToggle;

  const _PasswordField({
    required this.controller,
    required this.label,
    required this.obscure,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 14, color: Colors.grey.shade500),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xFF3B5BDB), width: 1.5),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: Colors.grey.shade400,
            size: 20,
          ),
          onPressed: onToggle,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

class _MessageBanner extends StatelessWidget {
  final String message;
  final bool isError;
  const _MessageBanner({required this.message, required this.isError});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isError
            ? const Color(0xFFFEF2F2)
            : const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isError
              ? const Color(0xFFFECACA)
              : const Color(0xFFBBF7D0),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            size: 16,
            color: isError
                ? const Color(0xFFDC2626)
                : const Color(0xFF16A34A),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 13,
                color: isError
                    ? const Color(0xFFDC2626)
                    : const Color(0xFF16A34A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
