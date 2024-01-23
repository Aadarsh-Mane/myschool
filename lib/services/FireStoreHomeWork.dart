import 'package:cloud_firestore/cloud_firestore.dart';

class FireStoreService1 {
  final CollectionReference notes =
      FirebaseFirestore.instance.collection('homework');

  Future<void> addNote(String note) {
    return notes.add({'title': note, 'timestamp': Timestamp.now()});
  }

  Stream<QuerySnapshot> getNotesStream() {
    final notesStream =
        notes.orderBy('timestamp', descending: true).snapshots();
    return notesStream;
  }

  Future<void> updateNote(String docId, String newNote) {
    return notes
        .doc(docId)
        .update({'note': newNote, 'timestamp': Timestamp.now()});
  }

  Future<void> deleteNote(String docID) {
    return notes.doc(docID).delete();
  }
}
