import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';
import 'dart:io';

import 'package:share_plus/share_plus.dart';

class UserAlreadyExistsException implements Exception {
  final String message;
  UserAlreadyExistsException(this.message);
}

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<bool> isUserAuthenticated() async {
    try {
      User? user = _auth.currentUser;
      return user != null;
    } catch (e) {
      print("Error checking authentication: $e");
      return false;
    }
  }

  Future<String> uploadImageToStorage(XFile image) async {
    try {
      String fileName = basename(image.path);
      Reference storageReference =
          _storage.ref().child('user_images/$fileName');
      UploadTask uploadTask = storageReference.putFile(File(image.path));
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadURL = await taskSnapshot.ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      print("Error uploading image: $e");
      return '';
    }
  }

  Future<String> signUpUsers(String email, String fullName, String phoneNumber,
      String password, String userType, String imageUrl) async {
    try {
      if (email.isNotEmpty &&
          fullName.isNotEmpty &&
          phoneNumber.isNotEmpty &&
          password.isNotEmpty) {
        final List<String> signInMethods =
            await _auth.fetchSignInMethodsForEmail(email);
        if (signInMethods.isNotEmpty) {
          throw UserAlreadyExistsException(
              'User with this email already exists.');
        }

        UserCredential cred = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);

        await _firestore.collection('users').doc(cred.user!.uid).set({
          'email': email,
          'fullName': fullName,
          'phoneNumber': phoneNumber,
          'userId': cred.user!.uid,
          'userType': userType,
          'imageUrl': imageUrl, // Save the image URL
          'address': '', // Initially set as empty
        });

        return 'success';
      } else {
        return 'Please fill in all fields';
      }
    } catch (e) {
      if (e is FirebaseAuthException) {
        print("Firebase error signing up: ${e.message}");
        return 'Firebase error occurred during sign up';
      } else if (e is UserAlreadyExistsException) {
        print(e.message);
        return e.message;
      } else {
        print("Error signing up: $e");
        return 'Error occurred during sign up';
      }
    }
  }

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

  Future<void> signOutUser() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print("Error signing out: $e");
    }
  }
}
