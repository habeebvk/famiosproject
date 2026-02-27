import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ---------------- REGISTER ----------------
  Future<void> registerUser({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _db.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
        'isApproved': role == 'Patient' ? true : false,
      });
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Registration failed');
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  // ---------------- LOGIN ----------------
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;

      final snapshot = await _db.collection('users').doc(uid).get();

      if (!snapshot.exists) {
        throw Exception('User document does not exist');
      }

      final data = snapshot.data();
      final role = data?['role'];

      if (role == null) {
        throw Exception('User role not found');
      }

      if (role != 'Patient' && role != 'Admin') {
        final isApproved = data?['isApproved'] ?? false;
        if (!isApproved) {
          await _auth.signOut();
          throw Exception('Your account is waiting for admin approval');
        }
      }

      return role;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('User not found');
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        throw Exception('Invalid credentials');
      }
      throw Exception(e.message ?? 'Login failed');
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Failed to send password reset email');
    } catch (e) {
      throw Exception('Failed to send password reset email: $e');
    }
  }

  // ---------------- CHANGE PASSWORD ----------------
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("No logged-in user");

    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Password change failed');
    } catch (e) {
      throw Exception('Password change failed: $e');
    }
  }

  // ---------------- GET CURRENT USER DATA ----------------
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final snapshot = await _db.collection('users').doc(user.uid).get();
      return snapshot.data();
    } catch (e) {
      throw Exception('Failed to fetch user data: $e');
    }
  }
}
