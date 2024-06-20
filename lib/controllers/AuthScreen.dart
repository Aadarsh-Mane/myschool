import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Check if the user is currently authenticated
  Future<bool> isUserAuthenticated() async {
    try {
      User? user = _auth.currentUser;
      return user != null;
    } catch (e) {
      print("Error checking authentication: $e");
      return false;
    }
  }

  // Sign up a new user with the provided details
  Future<String> signUpUSers(String email, String fullName, String phoneNumber,
      String password) async {
    try {
      if (email.isNotEmpty &&
          fullName.isNotEmpty &&
          phoneNumber.isNotEmpty &&
          password.isNotEmpty) {
        // Create the user with email and password
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);

        // Save additional user details to Firestore
        await _firestore.collection('buyers').doc(cred.user!.uid).set({
          'email': email,
          'fullName': fullName,
          'phoneNumber': phoneNumber,
          'buyerId': cred.user!.uid,
          'address': '', // Initially set as empty
        });

        return 'success';
      } else {
        return 'Please fill in all fields';
      }
    } catch (e) {
      print("Error signing up: $e");
      return 'Error occurred during sign up';
    }
  }

  // Log in a user with the provided email and password
  Future<String> loginUsers(String email, String password) async {
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        return 'success';
      } else {
        return 'Please fill in all fields';
      }
    } catch (e) {
      print("Error logging in: $e");
      return 'Error occurred during login';
    }
  }

  // Sign out the currently authenticated user
  Future<void> signOutUser() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print("Error signing out: $e");
    }
  }
}
