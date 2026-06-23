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
                      Text(opp.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 8),
                      Text(opp.startupName, style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text("About", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(opp.description),
                const SizedBox(height: 24),
                const Text("Skills Required", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Wrap(
                  spacing: 8,
                  children: opp.skillsRequired.map((skill) => Chip(label: Text(skill))).toList(),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () async {
                    final repo = ref.read(opportunityRepositoryProvider);
                    await repo.applyToOpportunity(opp.id, "I am very interested and have relevant skills.");
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Application submitted successfully!")),
                      );
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    minimumSize: const Size(double.infinity, 56),
                  ),
                  child: const Text("Apply Now", style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text("Failed to load")),
      ),
    );
  }
}