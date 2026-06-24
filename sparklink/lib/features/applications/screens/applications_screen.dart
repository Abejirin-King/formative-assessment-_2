import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparklink/features/opportunities/providers/opportunity_provider.dart';

class ApplicationsScreen extends ConsumerWidget {
  const ApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicationsAsync = ref.watch(myApplicationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("My Applications")),
      body: applicationsAsync.when(
        data: (apps) {
          if (apps.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_outlined, size: 90, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("No applications yet", style: TextStyle(fontSize: 22)),
                  Text("Your submitted applications will appear here"),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: apps.length,
            itemBuilder: (context, index) {
              final app = apps[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                child: ListTile(
                  leading: const Icon(Icons.work_outline, color: Colors.deepPurple, size: 40),
                  title: Text(app['opportunityId'] ?? 'Unknown Opportunity'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Status: ${app['status'] ?? 'Applied'}"),
                      if (app['timestamp'] != null)
                        Text("Applied: ${ (app['timestamp'] as Timestamp).toDate().toString().substring(0,10)}"),
                    ],
                  ),
                  trailing: Chip(
                    label: Text(app['status'] ?? 'Applied'),
                    backgroundColor: (app['status'] == 'Accepted') ? Colors.green : Colors.deepPurple,
                    labelStyle: const TextStyle(color: Colors.white),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 16),
              Text("Error: ${error.toString()}"),
              const SizedBox(height: 8),
              const Text("Try refreshing or applying to an opportunity first"),
            ],
          ),
        ),
      ),
    );
  }
}