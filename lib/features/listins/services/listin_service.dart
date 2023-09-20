import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_firebase_firestore_second/features/listins/models/listin.dart';

class ListinService {
  String uid = FirebaseAuth.instance.currentUser!.uid;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> addListin({required Listin listin}) async {
    return firestore.collection(uid).doc(listin.id).set(listin.toMap());
  }

  Future<List<Listin>> readListins() async {
    List<Listin> temp = []; 

    QuerySnapshot<Map<String, dynamic>> snapshot =
        await firestore.collection(uid).get();

    for (var doc in snapshot.docs) {
      temp.add(Listin.fromMap(doc.data()));
    }
    return temp;
  }

  Future<void> removeListin({required Listin listin}) async {
    return firestore.collection(uid).doc(listin.id).delete();
  }
}
