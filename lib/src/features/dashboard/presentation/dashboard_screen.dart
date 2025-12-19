import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../onboarding/data/user_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/chat'),
        backgroundColor: const Color(0xFFD4A5A5), // Dusty Rose
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
      ),
      appBar: AppBar(
        title: const Text('MenoAdvice'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildWelcomeCard(ref),
            const SizedBox(height: 24),
            _buildActionGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(WidgetRef ref) {
    final userAsync = ref.watch(userProfileStreamProvider);

    return Card(
      color: const Color(0xFF8BA894), // Sage Green
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             userAsync.when(
              data: (user) => Text(
                'Good Morning, ${user?.name ?? 'Friend'}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              loading: () => const Text('Loading...', style: TextStyle(color: Colors.white)),
              error: (_,__) => const Text('Hi there', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 8),
            const Text(
              'Day -- of Cycle', // Placeholder for Cycle Logic later
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildActionCard(
          icon: Icons.calendar_today,
          label: 'Log Symptoms',
          onTap: () => context.go('/tracker'),
        ),
        _buildActionCard(
          icon: Icons.article_outlined,
          label: 'Advice Hub',
          onTap: () => context.go('/education'),
        ),
        _buildActionCard(
          icon: Icons.auto_awesome,
          label: 'AI Insights',
          onTap: () => context.go('/insights'),
        ),
        _buildActionCard(
          icon: Icons.settings_outlined,
          label: 'Settings',
          onTap: () => context.go('/settings'),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: const Color(0xFFD4A5A5)), // Dusty Rose
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
