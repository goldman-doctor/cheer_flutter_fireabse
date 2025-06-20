import 'package:cloud_firestore/cloud_firestore.dart';

class UserStatusService {
  final FirebaseFirestore _firestore;

  UserStatusService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> setUserOnline(String uid) async {
    try {
      await _firestore
          .collection('stage')
          .doc('cheer')
          .collection('user')
          .doc(uid)
          .update({
            'isOnline': true,
            'lastSignIn': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      print('setUserOnline error: $e');
    }
  }

  Future<void> setUserOffline(String uid) async {
    try {
      await _firestore
          .collection('stage')
          .doc('cheer')
          .collection('user')
          .doc(uid)
          .update({
            'isOnline': false,
            'lastSignIn': FieldValue.serverTimestamp(),
          });
      print('setUserOffline success for $uid');
    } catch (e) {
      print('setUserOffline error: $e');
    }
  }
}
