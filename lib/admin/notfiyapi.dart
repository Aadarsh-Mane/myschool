import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseApi {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final CollectionReference _fcmTokensCollection = FirebaseFirestore.instance
      .collection('fcmtokens'); // Firestore collection reference

  Future<void> initNotification() async {
    try {
      // Request permissions
      await _firebaseMessaging.requestPermission();

      // Get the initial token
      String? fcmToken = await _firebaseMessaging.getToken();
      if (fcmToken != null) {
        print('Initial FCM Token: $fcmToken');
        await _saveTokenToFirestore(fcmToken);
      }

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) async {
        print('Refreshed FCM Token: $newToken');
        await _saveTokenToFirestore(newToken);
      });
    } catch (e) {
      print('Error initializing notification: $e');
    }
  }

  Future<void> _saveTokenToFirestore(String token) async {
    try {
      await _fcmTokensCollection.doc(token).set({
        'token': token,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('Token saved to Firestore');
    } catch (e) {
      print('Error saving token to Firestore: $e');
    }
  }
}
