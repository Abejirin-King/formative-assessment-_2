import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/auth_provider.dart';
import '../providers/opportunity_provider.dart';
import '../../../models/opportunity_model.dart';

class PostOpportunityScreen extends ConsumerStatefulWidget {
  const PostOpportunityScreen({super.key});

  @override
  ConsumerState<PostOpportunityScreen> createState() => _PostOpportunityScreenState();
}

class _PostOpportunityScreenState extends ConsumerState<PostOpportunityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _startupNameController = TextEditingController();

  String selectedType = 'Part-time';
  List<String> skillsRequired = [];

  final List<String> types = ['Part-time', 'Remote', 'On-campus', 'Full-time'];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).value;

    if (user?.role != 'startup') {
      return const Scaffold(
        body: Center(child: Text("Only startups can post opportunities")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Post Opportunity")),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Title *"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _startupNameController,
                decoration: const InputDecoration(labelText: "Startup Name *"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 6,
                decoration: const InputDecoration(labelText: "Description *"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedType,
                decoration: const InputDecoration(labelText: "Type"),
                items: types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setState(() => selectedType = v!),
              ),
              const SizedBox(height: 24),
              const Text("Required Skills"),
              Wrap(
                children: skillsRequired.map((skill) => Chip(
                  label: Text(skill),
                  onDeleted: () => setState(() => skillsRequired.remove(skill)),
                )).toList(),
              ),
              TextField(
                decoration: const InputDecoration(hintText: "Type skill and press Enter"),
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    setState(() => skillsRequired.add(value.trim()));
                  }
                },
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final repo = ref.read(opportunityRepositoryProvider);
                      final opp = Opportunity(
                        id: '',
                        title: _titleController.text,
                        description: _descriptionController.text,
                        startupName: _startupNameController.text,
                        startupId: user!.uid,
                        type: selectedType,
                        skillsRequired: skillsRequired,
                        postedDate: DateTime.now(),
                      );

                      await repo.postOpportunity(opp);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Opportunity posted successfully!")),
                        );
                        Navigator.pop(context);
                      }
                    }
                  },
                  child: const Text("Post Opportunity", style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}