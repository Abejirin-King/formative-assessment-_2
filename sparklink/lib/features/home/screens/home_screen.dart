import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/auth_provider.dart';
import '../../opportunities/providers/opportunity_provider.dart';
import '../../explore/screens/explore_screen.dart';
import '../../applications/screens/applications_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../opportunities/screens/post_opportunity_screen.dart';
import '../../opportunities/screens/opportunity_detail_screen.dart';
import '../../../models/opportunity_model.dart';

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
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      data: (user) {
        if (user == null) return const Scaffold(body: Center(child: Text("Please log in")));

        return Scaffold(
          body: _screens[_currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            selectedItemColor: Colors.deepPurple,
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
              BottomNavigationBarItem(icon: Icon(Icons.explore), label: "Explore"),
              BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "Applications"),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
            ],
          ),
          floatingActionButton: user.role == 'startup'
              ? FloatingActionButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PostOpportunityScreen())),
                  child: const Icon(Icons.add),
                )
              : null,
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, __) => const Scaffold(body: Center(child: Text("Error loading user"))),
    );
  }
}

// Beautiful Home Feed
class HomeFeed extends ConsumerWidget {
  const HomeFeed({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;
    final opportunitiesAsync = ref.watch(opportunitiesProvider);

    // Auto seed demo data
    WidgetsBinding.instance.addPostFrameCallback((_) => _seedDemoData(ref));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Hello, ${user?.name ?? 'Student'} 👋", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const Text("Find meaningful ways to contribute."),
          const SizedBox(height: 24),

          TextField(
            decoration: InputDecoration(
              hintText: "Search opportunities...",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              filled: true,
              fillColor: Colors.grey[100],
            ),
          ),
          const SizedBox(height: 28),

          const Text("Recommended", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          opportunitiesAsync.when(
            data: (opps) => SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: opps.length,
                itemBuilder: (context, index) {
                  final opp = opps[index];
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => OpportunityDetailScreen(opportunityId: opp.id)),
                    ),
                    child: Container(
                      width: 290,
                      margin: const EdgeInsets.only(right: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF6B46C1), Color(0xFF9F7AEA)]),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [BoxShadow(color: Colors.deepPurple.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(opp.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                          const Spacer(),
                          Text(opp.startupName, style: const TextStyle(color: Colors.white70)),
                          const SizedBox(height: 8),
                          Chip(label: Text(opp.type), backgroundColor: Colors.white.withValues(alpha: 0.25), labelStyle: const TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            loading: () => const CircularProgressIndicator(),
            error: (_, __) => const Text("Failed to load"),
          ),
        ],
      ),
    );
  }

  Future<void> _seedDemoData(WidgetRef ref) async {
    final firestore = ref.read(firestoreProvider);
    if ((await firestore.collection('opportunities').limit(1).get()).docs.isNotEmpty) return;

    final repo = ref.read(opportunityRepositoryProvider);

    final List<Map<String, dynamic>> demos = [
      {"title": "UX Research Volunteer", "startupName": "EduBridge", "type": "Remote", "skills": ["UX Research", "Figma"]},
      {"title": "Flutter Developer", "startupName": "Learnify", "type": "Part-time", "skills": ["Flutter", "Dart"]},
      {"title": "Social Media Assistant", "startupName": "CampusVoice", "type": "On-campus", "skills": ["Content Creation", "Canva"]},
    ];

    for (var d in demos) {
      await repo.postOpportunity(Opportunity(
        id: '',
        title: d['title'],
        description: "Exciting opportunity for ALU students!",
        startupName: d['startupName'],
        startupId: 'demo',
        type: d['type'],
        skillsRequired: List<String>.from(d['skills']),
        postedDate: DateTime.now(),
      ));
    }
  }
}