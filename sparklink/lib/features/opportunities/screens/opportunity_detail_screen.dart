import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/opportunity_provider.dart';

class OpportunityDetailScreen extends ConsumerWidget {
  final String opportunityId;

  const OpportunityDetailScreen({super.key, required this.opportunityId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final opportunities = ref.watch(opportunitiesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Opportunity Details")),
      body: opportunities.when(
        data: (opps) {
          final opp = opps.firstWhere((o) => o.id == opportunityId, orElse: () => opps.first);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gradient Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF6B46C1), Color(0xFF9F7AEA)]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(opp.title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 8),
                      Text(opp.startupName, style: const TextStyle(fontSize: 18, color: Colors.white70)),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                const Text("About", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(opp.description, style: const TextStyle(fontSize: 16, height: 1.5)),

                const SizedBox(height: 24),
                const Text("Type", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Chip(label: Text(opp.type)),

                const SizedBox(height: 24),
                const Text("Skills Required", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Wrap(
                  spacing: 8,
                  children: opp.skillsRequired.map((skill) => Chip(label: Text(skill))).toList(),
                ),

                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () async {
                      final repo = ref.read(opportunityRepositoryProvider);
                      await repo.applyToOpportunity(opp.id, "I am excited to contribute to this opportunity!");
                      
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("✅ Application submitted successfully!")),
                        );
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Apply Now", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text("Failed to load opportunity")),
      ),
    );
  }
}