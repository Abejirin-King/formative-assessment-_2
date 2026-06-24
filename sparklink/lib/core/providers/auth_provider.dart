import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';

final authProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);
final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

final currentUserProvider = StreamProvider<AppUser?>((ref) {
  final auth = ref.watch(authProvider);
  final firestore = ref.watch(firestoreProvider);

  return auth.authStateChanges().asyncMap((firebaseUser) async {
    if (firebaseUser == null) return null;

    final doc = await firestore.collection('users').doc(firebaseUser.uid).get();

    if (doc.exists) {
      return AppUser.fromMap(doc.data()!);
    } else {
      // Auto-create user document if it doesn't exist
      final newUser = AppUser(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        name: firebaseUser.displayName ?? "Student",
        role: 'student',
      );
      await firestore.collection('users').doc(firebaseUser.uid).set(newUser.toMap());
      return newUser;
    }
  });
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref);
});

class AuthRepository {
  final Ref ref;
  AuthRepository(this.ref);

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    final auth = ref.read(authProvider);
    final firestore = ref.read(firestoreProvider);

    final userCredential = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = AppUser(
      uid: userCredential.user!.uid,
      email: email,
      name: name,
      role: role,
    );

    await firestore.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<void> signIn(String email, String password) async {
    await ref.read(authProvider).signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await ref.read(authProvider).signOut();
  }
}