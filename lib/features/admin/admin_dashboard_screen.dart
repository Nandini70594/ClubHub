import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/router/app_router.dart';
import '../../models/app_user.dart';
import '../../models/club_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_scaffold.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {

  static const _primary   = Color(0xFF3B5BDB);
  static const _bg        = Color(0xFFF4F6FB);
  static const _textMain  = Color(0xFF1A1F36);
  static const _textSub   = Color(0xFF6B7280);

  late final TabController _tabController;

  // ── Club form ────────────────────────────────────────────────────────────
  final _clubNameCtrl = TextEditingController();
  final _clubCodeCtrl = TextEditingController();
  final _departmentController = TextEditingController();
  bool  _clubLoading  = false;
  String? _clubError;
  String? _clubSuccess;

  // ── User form ────────────────────────────────────────────────────────────
  final _authIdCtrl  = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _nameCtrl    = TextEditingController();
  String  _role           = 'club_lead';
  String? _selectedClubId;
  bool    _userLoading    = false;
  String? _userError;
  String? _userSuccess;

  // ── Data ─────────────────────────────────────────────────────────────────
  int _reloadKey = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _clubNameCtrl.dispose();
    _clubCodeCtrl.dispose();
    _authIdCtrl.dispose();
    _emailCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _createClub() async {
    if (_clubNameCtrl.text.trim().isEmpty || _clubCodeCtrl.text.trim().isEmpty) {
      setState(() { _clubError = 'Club name and code are required.'; _clubSuccess = null; });
      return;
    }
    setState(() { _clubLoading = true; _clubError = null; _clubSuccess = null; });
    try {
      await ref.read(adminServiceProvider).createClub(
        clubName: _clubNameCtrl.text.trim(),
        clubCode: _clubCodeCtrl.text.trim(),
      );
      _clubNameCtrl.clear();
      _clubCodeCtrl.clear();
      setState(() { _clubSuccess = 'Club created successfully!'; _reloadKey++; });
    } catch (e) {
      setState(() => _clubError = e.toString());
    } finally {
      setState(() => _clubLoading = false);
    }
  }

  Future<void> _createUser(List<ClubModel> clubs) async {
    if (_authIdCtrl.text.trim().isEmpty || _emailCtrl.text.trim().isEmpty || _nameCtrl.text.trim().isEmpty) {
      setState(() { _userError = 'Auth ID, email and name are required.'; _userSuccess = null; });
      return;
    }
    final needsClub = _role == 'club_lead' || _role == 'proposal_approver';
    if (needsClub && _selectedClubId == null) {
      setState(() { _userError = 'Please select a club for this role.'; _userSuccess = null; });
      return;
    }
    setState(() { _userLoading = true; _userError = null; _userSuccess = null; });
    try {
      await ref.read(adminServiceProvider).createUserProfile(
        authUserId: _authIdCtrl.text.trim(),
        email:      _emailCtrl.text.trim(),
        role:       _role,
        fullName:   _nameCtrl.text.trim(),
        clubId:     needsClub ? _selectedClubId : null,
      );
      _authIdCtrl.clear();
      _emailCtrl.clear();
      _nameCtrl.clear();
      setState(() {
        _selectedClubId = null;
        _role = 'club_lead';
        _userSuccess = 'User profile created successfully!';
        _reloadKey++;
      });
    } catch (e) {
      setState(() => _userError = e.toString());
    } finally {
      setState(() => _userLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Admin',
      currentRoute: AppRoutes.admin,
      child: Column(
        children: [
          // Tab bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: _primary,
              unselectedLabelColor: _textSub,
              labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              unselectedLabelStyle: const TextStyle(fontSize: 13),
              indicatorColor: _primary,
              indicatorWeight: 2.5,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Add Club'),
                Tab(text: 'Add User'),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade200),

          Expanded(
            child: FutureBuilder(
              key: ValueKey(_reloadKey),
              future: Future.wait([
                ref.read(adminServiceProvider).getClubs(),
                ref.read(adminServiceProvider).getUsers(),
              ]),
              builder: (context, snapshot) {
                final clubs = snapshot.data?[0] as List<ClubModel>? ?? [];
                final users = snapshot.data?[1] as List<AppUser>?  ?? [];
                final loading = !snapshot.hasData;

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _OverviewTab(clubs: clubs, users: users, loading: loading),
                    _AddClubTab(
                      nameCtrl:    _clubNameCtrl,
                      codeCtrl:    _clubCodeCtrl,
                      loading:     _clubLoading,
                      error:       _clubError,
                      success:     _clubSuccess,
                      onSubmit:    _createClub,
                    ),
                    _AddUserTab(
                      authIdCtrl:     _authIdCtrl,
                      emailCtrl:      _emailCtrl,
                      nameCtrl:       _nameCtrl,
                      role:           _role,
                      selectedClubId: _selectedClubId,
                      clubs:          clubs,
                      loading:        _userLoading,
                      error:          _userError,
                      success:        _userSuccess,
                      onRoleChanged:  (v) => setState(() { _role = v!; _selectedClubId = null; }),
                      onClubChanged:  (v) => setState(() => _selectedClubId = v),
                      onSubmit:       () => _createUser(clubs),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Overview tab ──────────────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  final List<ClubModel> clubs;
  final List<AppUser>   users;
  final bool loading;

  const _OverviewTab({required this.clubs, required this.users, required this.loading});

  static const _primary  = Color(0xFF3B5BDB);
  static const _textMain = Color(0xFF1A1F36);
  static const _textSub  = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator(color: _primary));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Stats row
        Row(
          children: [
            _StatCard(label: 'Total Clubs', value: '${clubs.length}', icon: Icons.business_outlined, color: _primary),
            const SizedBox(width: 12),
            _StatCard(label: 'Total Users', value: '${users.length}', icon: Icons.people_outlined, color: const Color(0xFF0891B2)),
          ],
        ),
        const SizedBox(height: 20),

        // Clubs list
        _SectionHeader(title: 'Clubs (${clubs.length})'),
        const SizedBox(height: 8),
        ...clubs.map((c) => _ClubTile(club: c)),
        const SizedBox(height: 20),

        // Users list
        _SectionHeader(title: 'Users (${users.length})'),
        const SizedBox(height: 8),
        ...users.map((u) => _UserTile(user: u)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: color)),
                Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ClubTile extends StatelessWidget {
  final ClubModel club;
  const _ClubTile({required this.club});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.business_outlined, color: Color(0xFF3B5BDB), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(club.clubName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1F36))),
                Text(club.clubCode, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  final AppUser user;
  const _UserTile({required this.user});

  Color _roleColor(String role) {
    switch (role) {
      case 'admin':            return const Color(0xFF7C3AED);
      case 'club_lead':        return const Color(0xFF3B5BDB);
      case 'proposal_approver':return const Color(0xFF0891B2);
      case 'budget_approver':  return const Color(0xFF059669);
      case 'resource_incharge':return const Color(0xFFD97706);
      case 'director':         return const Color(0xFFDC2626);
      default:                 return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _roleColor(user.role);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withOpacity(0.12),
            child: Text(
              (user.fullName ?? user.email).substring(0, 1).toUpperCase(),
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.fullName ?? 'No Name', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1F36))),
                Text(user.email, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
            child: Text(user.role.replaceAll('_', ' '), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
          ),
        ],
      ),
    );
  }
}

// ── Add Club tab ──────────────────────────────────────────────────────────────

class _AddClubTab extends StatelessWidget {
  final TextEditingController nameCtrl, codeCtrl;
  final bool loading;
  final String? error, success;
  final VoidCallback onSubmit;

  const _AddClubTab({
    required this.nameCtrl, required this.codeCtrl,
    required this.loading, required this.error, required this.success,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const _SectionHeader(title: 'Create a new club'),
        const SizedBox(height: 16),
        _Field(controller: nameCtrl, label: 'Club Name', hint: 'e.g. Robotics Club', icon: Icons.business_outlined),
        const SizedBox(height: 14),
        _Field(controller: codeCtrl, label: 'Club Code', hint: 'e.g. RC001', icon: Icons.tag_outlined),
        if (error   != null) ...[const SizedBox(height: 14), _Banner(message: error!,   isError: true)],
        if (success != null) ...[const SizedBox(height: 14), _Banner(message: success!, isError: false)],
        const SizedBox(height: 20),
        _SubmitButton(label: 'Create Club', loading: loading, onPressed: onSubmit),
      ],
    );
  }
}

// ── Add User tab ──────────────────────────────────────────────────────────────

class _AddUserTab extends StatelessWidget {
  final TextEditingController authIdCtrl, emailCtrl, nameCtrl;
  final String role;
  final String? selectedClubId;
  final List<ClubModel> clubs;
  final bool loading;
  final String? error, success;
  final ValueChanged<String?> onRoleChanged;
  final ValueChanged<String?> onClubChanged;
  final VoidCallback onSubmit;

  const _AddUserTab({
    required this.authIdCtrl, required this.emailCtrl, required this.nameCtrl,
    required this.role, required this.selectedClubId, required this.clubs,
    required this.loading, required this.error, required this.success,
    required this.onRoleChanged, required this.onClubChanged, required this.onSubmit,
  });

  static const _roles = [
    ('club_lead',          'Club Lead'),
    ('proposal_approver',  'Proposal Approver'),
    ('budget_approver',    'Budget Approver'),
    ('resource_incharge',  'Resource Incharge'),
    ('vertical_coordinator','Vertical Coordinator'),
    ('director',           'Director'),
    ('admin',              'Admin'),
  ];

  bool get _needsClub => role == 'club_lead' || role == 'proposal_approver';

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const _SectionHeader(title: 'Create a new user profile'),
        const SizedBox(height: 4),
        Text('Note: the Auth User ID must match the Supabase Auth UID for this user.',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
        const SizedBox(height: 16),
        _Field(controller: authIdCtrl, label: 'Auth User ID (Supabase UID)', hint: 'uuid from Supabase Auth', icon: Icons.key_outlined),
        const SizedBox(height: 14),
        _Field(controller: emailCtrl,  label: 'Email',     hint: 'user@institution.edu', icon: Icons.mail_outline,    keyboard: TextInputType.emailAddress),
        const SizedBox(height: 14),
        _Field(controller: nameCtrl,   label: 'Full Name', hint: 'Prof. John Doe',        icon: Icons.person_outline),
        const SizedBox(height: 14),

        // Role dropdown
        _DropdownLabel(label: 'Role'),
        const SizedBox(height: 6),
        _StyledDropdown<String>(
          value: role,
          items: _roles.map((r) => DropdownMenuItem(value: r.$1, child: Text(r.$2))).toList(),
          onChanged: onRoleChanged,
          hint: 'Select role',
        ),

        // Club dropdown (only for club_lead and proposal_approver)
        if (_needsClub) ...[
          const SizedBox(height: 14),
          _DropdownLabel(label: 'Assign Club'),
          const SizedBox(height: 6),
          _StyledDropdown<String>(
            value: selectedClubId,
            items: clubs.map((c) => DropdownMenuItem(
              value: c.id,
              child: Text('${c.clubName} (${c.clubCode})'),
            )).toList(),
            onChanged: onClubChanged,
            hint: 'Select club',
          ),
        ],

        if (error   != null) ...[const SizedBox(height: 14), _Banner(message: error!,   isError: true)],
        if (success != null) ...[const SizedBox(height: 14), _Banner(message: success!, isError: false)],
        const SizedBox(height: 20),
        _SubmitButton(label: 'Create User Profile', loading: loading, onPressed: onSubmit),
      ],
    );
  }
}

// ── Shared small widgets ──────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});
  @override
  Widget build(BuildContext context) => Text(title,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1A1F36)));
}

class _DropdownLabel extends StatelessWidget {
  final String label;
  const _DropdownLabel({required this.label});
  @override
  Widget build(BuildContext context) => Text(label,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1F36)));
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label, hint;
  final IconData icon;
  final TextInputType? keyboard;
  const _Field({required this.controller, required this.label, required this.hint, required this.icon, this.keyboard});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1F36))),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboard,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            filled: true,
            fillColor: const Color(0xFFF4F6FB),
            prefixIcon: Icon(icon, size: 18, color: const Color(0xFF6B7280)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF3B5BDB), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _StyledDropdown<T> extends StatelessWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String hint;
  const _StyledDropdown({required this.value, required this.items, required this.onChanged, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6FB),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(hint, style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
          isExpanded: true,
          style: const TextStyle(fontSize: 14, color: Color(0xFF1A1F36)),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback onPressed;
  const _SubmitButton({required this.label, required this.loading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, height: 48,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3B5BDB),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: loading
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
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
      child: Row(children: [
        Icon(isError ? Icons.error_outline : Icons.check_circle_outline,
            size: 16, color: isError ? const Color(0xFFDC2626) : const Color(0xFF16A34A)),
        const SizedBox(width: 8),
        Expanded(child: Text(message, style: TextStyle(
            fontSize: 12, color: isError ? const Color(0xFFDC2626) : const Color(0xFF16A34A)))),
      ]),
    );
  }
}