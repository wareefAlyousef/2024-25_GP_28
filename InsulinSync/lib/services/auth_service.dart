import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<bool> isEmailRegistered(String email) async {
    String normalizedEmail = email.trim().toLowerCase();
    try {
      print('Checking if email is registered: $normalizedEmail');
      List<String> signInMethods =
          await _auth.fetchSignInMethodsForEmail(normalizedEmail);
      print('Sign-in methods for $normalizedEmail: $signInMethods');

      // If the list is not empty, it means the email is registered
      if (signInMethods.isNotEmpty) {
        return true;
      } else {
        print('No sign-in methods found for $normalizedEmail');
        return false;
      }
    } catch (e) {
      print('Error checking email: ${e.toString()}');
      return false;
    }
  }


  // Sign up and store user in Firestore
  Future<User?> signUpWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required double weight,
    required double height,
    required DateTime dateOfBirth,
    required double dailyBasal,
    required double dailyBolus,
    required bool gender, 
    double? carbRatio,
    double? correctionRatio,
  }) async {
    try {
      
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      await _firestore.collection('users').doc(user?.uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'weight': weight,
        'height': height,
        'dateOfBirth': dateOfBirth.toIso8601String(),
        'gender':
            gender ? 'Male' : 'Female', 
        'dailyBasal': dailyBasal,
        'dailyBolus': dailyBolus,
        'carbRatio': carbRatio,
        'correctionRatio': correctionRatio,
        'createdAt': Timestamp.now(),
      });

      return user;
    } catch (e) {
      print('Error during sign up: $e');
      throw e;
    }
  }

  Future<User?> loginWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print('Error: $e');
      throw e;
    }
  }

  Future<void> signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print('Error: $e');
      throw e;
    }
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print('Password reset email sent');
    } catch (e) {
      print('Error sending password reset email: ${e.toString()}');
      throw e;
    }
  }
}
