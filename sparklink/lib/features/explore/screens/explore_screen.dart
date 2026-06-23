import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../opportunities/providers/opportunity_provider.dart';
import '../../opportunities/screens/opportunity_detail_screen.dart';

class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final opportunitiesAsync = ref.watch(opportunitiesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Explore")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search by role or skill...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (value) {
                // Add filtering logic later
              },
            ),
          ),
          Expanded(
            child: opportunitiesAsync.when(
              data: (opps) => ListView.builder(
                itemCount: opps.length,
                itemBuilder: (context, index) {
                  final opp = opps[index];
                  return ListTile(
                    title: Text(opp.title),
                    subtitle: Text("${opp.startupName} • ${opp.type}"),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OpportunityDetailScreen(opportunityId: opp.id),
                      ),
                    ),
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text("Error"),
            ),
          ),
        ],
      ),
    );
  }
}