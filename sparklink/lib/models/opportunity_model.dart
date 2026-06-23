import 'package:cloud_firestore/cloud_firestore.dart';

class Opportunity {
  final String id;
  final String title;
  final String description;
  final String startupName;
  final String startupId;
  final String type; // 'Part-time', 'Remote', 'On-campus'
  final List<String> skillsRequired;
  final DateTime postedDate;
  final DateTime? deadline;

  Opportunity({
    required this.id,
    required this.title,
    required this.description,
    required this.startupName,
    required this.startupId,
    required this.type,
    required this.skillsRequired,
    required this.postedDate,
    this.deadline,
  });

  factory Opportunity.fromMap(Map<String, dynamic> map, String id) {
    return Opportunity(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      startupName: map['startupName'] ?? '',
      startupId: map['startupId'] ?? '',
      type: map['type'] ?? 'Part-time',
      skillsRequired: List<String>.from(map['skillsRequired'] ?? []),
      postedDate: (map['postedDate'] as Timestamp).toDate(),
      deadline: map['deadline'] != null ? (map['deadline'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'startupName': startupName,
      'startupId': startupId,
      'type': type,
      'skillsRequired': skillsRequired,
      'postedDate': FieldValue.serverTimestamp(),
      'deadline': deadline != null ? Timestamp.fromDate(deadline!) : null,
    };
  }
}