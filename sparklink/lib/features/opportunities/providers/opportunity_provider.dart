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
  final user = ref.watch(currentUserProvider);

  if (user.valueOrNull?.uid == null) return const Stream.empty();

  return firestore
      .collection('applications')
      .where('applicantUid', isEqualTo: user.valueOrNull!.uid)
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
    final firestore = ref.read(firestoreProvider);
    await firestore.collection('opportunities').add(opportunity.toMap());
  }

  Future<void> applyToOpportunity(String opportunityId, String coverLetter) async {
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
  }
}