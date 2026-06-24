import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../models/opportunity_model.dart';

final opportunitiesProvider = StreamProvider<List<Opportunity>>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection('opportunities')
      .orderBy('postedDate', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => Opportunity.fromMap(doc.data(), doc.id))
          .toList());
});

final myApplicationsProvider = StreamProvider<List<dynamic>>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final userAsync = ref.watch(currentUserProvider);

  final user = userAsync.valueOrNull;
  if (user == null || user.uid.isEmpty) {
    return const Stream.empty();
  }

  return firestore
      .collection('applications')
      .where('applicantUid', isEqualTo: user.uid)
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
});

final opportunityRepositoryProvider = Provider<OpportunityRepository>((ref) {
  return OpportunityRepository(ref);
});

class OpportunityRepository {
  final Ref ref;
  OpportunityRepository(this.ref);

  Future<void> postOpportunity(Opportunity opportunity) async {
    try {
      final firestore = ref.read(firestoreProvider);
      await firestore.collection('opportunities').add(opportunity.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> applyToOpportunity(String opportunityId, String coverLetter) async {
    try {
      final firestore = ref.read(firestoreProvider);
      final user = ref.read(currentUserProvider).valueOrNull;

      if (user == null) throw Exception("Not logged in");

      await firestore.collection('applications').add({
        'opportunityId': opportunityId,
        'applicantUid': user.uid,
        'applicantName': user.name,
        'coverLetter': coverLetter,
        'status': 'Applied',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }
}