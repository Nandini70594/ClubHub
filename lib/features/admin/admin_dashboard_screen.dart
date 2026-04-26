import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/app_user.dart';
import '../../models/club_model.dart';
import '../../providers/auth_provider.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState
    extends ConsumerState<AdminDashboardScreen> {
  final _clubNameController = TextEditingController();
  final _clubCodeController = TextEditingController();

  final _userIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();

  String _role = 'club_lead';
  String? _selectedClubId;

  Future<void> _createClub() async {
    await ref.read(adminServiceProvider).createClub(
          clubName: _clubNameController.text.trim(),
          clubCode: _clubCodeController.text.trim(),
        );

    _clubNameController.clear();
    _clubCodeController.clear();
    setState(() {});
  }

  Future<void> _createUser() async {
  String? clubIdToSend;

  if (_role == 'club_lead' || _role == 'proposal_approver') {
    clubIdToSend = _selectedClubId;
  }

  await ref.read(adminServiceProvider).createUserProfile(
        authUserId: _userIdController.text.trim(),
        email: _emailController.text.trim(),
        role: _role,
        fullName: _nameController.text.trim(),
        clubId: clubIdToSend,
      );

  _userIdController.clear();
  _emailController.clear();
  _nameController.clear();
  setState(() {});
}

  @override
  Widget build(BuildContext context) {
    final adminService = ref.read(adminServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: FutureBuilder(
        future: Future.wait([
          adminService.getClubs(),
          adminService.getUsers(),
        ]),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final clubs = snapshot.data![0] as List<ClubModel>;
          final users = snapshot.data![1] as List<AppUser>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Create Club',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextField(
                  controller: _clubNameController,
                  decoration: const InputDecoration(labelText: 'Club Name'),
                ),
                TextField(
                  controller: _clubCodeController,
                  decoration: const InputDecoration(labelText: 'Club Code'),
                ),
                ElevatedButton(
                  onPressed: _createClub,
                  child: const Text('Add Club'),
                ),

                const SizedBox(height: 30),

                const Text(
                  'Create User Profile',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextField(
                  controller: _userIdController,
                  decoration:
                      const InputDecoration(labelText: 'Auth User ID'),
                ),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                ),

                DropdownButton<String>(
                  value: _role,
                  items: const [
                    DropdownMenuItem(
                        value: 'club_lead', child: Text('Club Lead')),
                    DropdownMenuItem(
                        value: 'proposal_approver',
                        child: Text('Faculty Mentor')),
                    DropdownMenuItem(
                        value: 'vertical_coordinator',
                        child: Text('Vertical Coordinator')),
                    DropdownMenuItem(
                        value: 'budget_approver',
                        child: Text('Budget Approver')),
                    DropdownMenuItem(
                        value: 'resource_incharge',
                        child: Text('Resource Incharge')),
                    DropdownMenuItem(
                        value: 'director', child: Text('Director')),
                  ],
                  onChanged: (val) {
                    setState(() {
                      _role = val!;
                    });
                  },
                ),

                DropdownButton<String>(
                  hint: const Text('Assign Club'),
                  value: _selectedClubId,
                  items: clubs
                      .map((c) => DropdownMenuItem(
                            value: c.id,
                            child: Text('${c.clubName} (${c.clubCode})'),
                          ))
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedClubId = val;
                    });
                  },
                ),

                ElevatedButton(
                  onPressed: _createUser,
                  child: const Text('Add User Profile'),
                ),

                const SizedBox(height: 30),

                const Text(
                  'Users',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                ...users.map((u) {
                  return ListTile(
                    title: Text(u.fullName ?? 'No Name'),
                    subtitle: Text('${u.email} • ${u.role}'),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}