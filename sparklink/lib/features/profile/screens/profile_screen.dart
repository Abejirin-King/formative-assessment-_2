import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final authRepo = ref.read(authRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Profile"), actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () async {
            await authRepo.signOut();
            // Router will handle redirect in real app
          },
        )
      ]),
      body: userAsync.when(
        data: (user) => user == null
            ? const Center(child: Text("Not logged in"))
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const CircleAvatar(radius: 50, backgroundColor: Colors.deepPurple),
                    const SizedBox(height: 16),
                    Text(user.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    Text(user.email),
                    const SizedBox(height: 8),
                    Chip(label: Text(user.role.toUpperCase())),
                    const SizedBox(height: 24),
                    const Text("Skills", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Wrap(
                      children: user.skills.isNotEmpty
                          ? user.skills.map((s) => Chip(label: Text(s))).toList()
                          : [const Text("No skills added yet")],
                    ),
                    const Spacer(),
                    ListTile(
                      leading: const Icon(Icons.edit),
                      title: const Text("Edit Profile"),
                      onTap: () {},
                    ),
                    ListTile(
                      leading: const Icon(Icons.settings),
                      title: const Text("Settings"),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text("Error loading profile")),
      ),
    );
  }
}