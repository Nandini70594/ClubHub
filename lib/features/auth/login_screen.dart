import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/router/app_router.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  static const _primary = Color(0xFF3B5BDB);

  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading             = false;
  bool _obscurePassword     = true;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() { _loading = true; _error = null; });
    try {
      await ref.read(authServiceProvider).signIn(
        email:    _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      final profile = await ref.refresh(currentUserProfileProvider.future);
      if (!mounted) return;

      if (profile == null) {
        setState(() => _error = 'No matching profile found.');
        return;
      }

      final route = initialRouteForRole(profile.role);
      context.go(route);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showForgotPassword() {
    final emailCtrl    = TextEditingController(text: _emailController.text.trim());
    String? sheetError;
    String? sheetSuccess;
    bool    sheetLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) {
          Future<void> sendReset() async {
            final email = emailCtrl.text.trim();
            if (email.isEmpty) {
              setSheet(() => sheetError = 'Please enter your email.');
              return;
            }
            setSheet(() { sheetLoading = true; sheetError = null; sheetSuccess = null; });
            try {
              await Supabase.instance.client.auth.resetPasswordForEmail(email);
              setSheet(() => sheetSuccess = 'Reset link sent! Check your inbox.');
            } on AuthException catch (e) {
              setSheet(() => sheetError = e.message);
            } catch (_) {
              setSheet(() => sheetError = 'Something went wrong. Try again.');
            } finally {
              setSheet(() => sheetLoading = false);
            }
          }

          return Padding(
            padding: EdgeInsets.only(
              left: 24, right: 24, top: 24,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36, height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Text('Forgot password?',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1A1F36))),
                const SizedBox(height: 6),
                Text("Enter your registered email and we'll send a reset link.",
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                const SizedBox(height: 20),
                _InputField(
                  controller: emailCtrl,
                  hint: 'you@vit.edu',
                  icon: Icons.mail_outline,
                  keyboardType: TextInputType.emailAddress,
                ),
                if (sheetError   != null) ...[const SizedBox(height: 12), _Banner(message: sheetError!,   isError: true)],
                if (sheetSuccess != null) ...[const SizedBox(height: 12), _Banner(message: sheetSuccess!, isError: false)],
                const SizedBox(height: 20),
                _PrimaryButton(
                  label: 'Send reset link',
                  loading: sheetLoading,
                  onPressed: sendReset,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(color: _primary, borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.hub_outlined, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 16),
              const Text('ClubHub',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: Color(0xFF1A1F36), letterSpacing: -0.5)),
              const SizedBox(height: 4),
              Text('Sign in to your account',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
              const SizedBox(height: 36),

              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Email',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1F36))),
                    const SizedBox(height: 6),
                    _InputField(
                      controller: _emailController,
                      hint: 'you@vit.edu',
                      icon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Password',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1F36))),
                        GestureDetector(
                          onTap: _showForgotPassword,
                          child: const Text('Forgot password?',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _primary)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _InputField(
                      controller: _passwordController,
                      hint: '••••••••',
                      icon: Icons.lock_outline,
                      obscure: _obscurePassword,
                      onToggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    if (_error != null) ...[const SizedBox(height: 14), _Banner(message: _error!, isError: true)],
                    const SizedBox(height: 20),
                    _PrimaryButton(label: 'Sign In', loading: _loading, onPressed: _login),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text('Vishwakarma Institute of Technology',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
            ],
          ),
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscure;
  final VoidCallback? onToggleObscure;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.obscure = false,
    this.onToggleObscure,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFF4F6FB),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF3B5BDB), width: 1.5)),
        prefixIcon: Icon(icon, size: 18, color: const Color(0xFF6B7280)),
        suffixIcon: onToggleObscure != null
            ? IconButton(
                icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    size: 18, color: const Color(0xFF6B7280)),
                onPressed: onToggleObscure,
              )
            : null,
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback onPressed;

  const _PrimaryButton({required this.label, required this.loading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3B5BDB),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: loading
            ? const SizedBox(width: 18, height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  final String message;
  final bool isError;
  const _Banner({required this.message, required this.isError});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isError ? const Color(0xFFFEE2E2) : const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(isError ? Icons.error_outline : Icons.check_circle_outline,
              size: 16, color: isError ? const Color(0xFFDC2626) : const Color(0xFF16A34A)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message,
                style: TextStyle(fontSize: 12,
                    color: isError ? const Color(0xFFDC2626) : const Color(0xFF16A34A))),
          ),
        ],
      ),
    );
  }
}
