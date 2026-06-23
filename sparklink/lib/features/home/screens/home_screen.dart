import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../opportunities/providers/opportunity_provider.dart';
import '../../applications/screens/applications_screen.dart';
import '../../explore/screens/explore_screen.dart';
import '../../profile/screens/profile_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
  const HomeFeed(),
  const ExploreScreen(),
  const ApplicationsScreen(),
  const ProfileScreen(),
];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.deepPurple,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: "Explore"),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "Applications"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

// Extracted Feed Widget
class HomeFeed extends ConsumerWidget {
  const HomeFeed({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final opportunitiesAsync = ref.watch(opportunitiesProvider);

    final userName = userAsync.value?.name ?? "Amina";

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Hello, $userName 👋", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("Find meaningful ways to contribute."),
          const SizedBox(height: 24),

          // Search bar
          TextField(
            decoration: InputDecoration(
              hintText: "Search opportunities...",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 24),

          // Recommended Section (Gradient Cards)
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Recommended", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text("See all", style: TextStyle(color: Colors.deepPurple)),
            ],
          ),
          const SizedBox(height: 12),

          opportunitiesAsync.when(
            data: (opps) => SizedBox(
              height: 190,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: opps.take(5).length,
                itemBuilder: (context, index) {
                  final opp = opps[index];
                  return GestureDetector(
                    onTap: () => context.push('/opportunity/${opp.id}'),
                    child: Container(
                      width: 260,
                      margin: const EdgeInsets.only(right: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6B46C1), Color(0xFF9F7AEA)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(opp.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                          const Spacer(),
                          Chip(label: Text(opp.type), backgroundColor: Colors.white.withValues(alpha: 0.3), labelStyle: const TextStyle(color: Colors.white)),
                          const SizedBox(height: 8),
                          Text(opp.startupName, style: const TextStyle(color: Colors.white70)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text("Error: $e"),
          ),

          const SizedBox(height: 32),
          const Text("Recent Opportunities", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          // You can add a vertical list here similarly
        ],
      ),
    );
  }
}