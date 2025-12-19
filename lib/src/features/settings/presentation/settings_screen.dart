import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/data/auth_repository.dart';
import '../../onboarding/data/user_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _buildUserInfo(userAsync),
          const Divider(),
          _buildLogoutTile(context, ref),
          // Future: Add other settings like notifications, theme, etc.
        ],
      ),
    );
  }

  Widget _buildUserInfo(AsyncValue userAsync) {
    return userAsync.when(
      data: (user) => ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFF8BA894), // Sage
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: Text(user?.name ?? 'User'),
        subtitle: Text('Phase: ${user?.stage.displayName ?? 'Unknown'}'),
      ),
      loading: () => const ListTile(title: Text('Loading profile...')),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildLogoutTile(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(Icons.logout, color: Colors.redAccent),
      title: const Text('Log Out', style: TextStyle(color: Colors.redAccent)),
      onTap: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Log Out'),
            content: const Text('Are you sure you want to log out?'),
            actions: [
              TextButton(
                onPressed: () => context.pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => context.pop(true),
                child: const Text('Log Out'),
              ),
            ],
          ),
        );

        if (confirmed == true) {
          await ref.read(authRepositoryProvider).signOut();
          // The AppRouter redirect will handle sending them to /login
        }
      },
    );
  }
}
