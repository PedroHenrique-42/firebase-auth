import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_firebase_firestore_second/features/products/models/produto.dart';
import 'package:flutter_firebase_firestore_second/features/products/utils/enum_order.dart';

class ProductService {
  String uid = FirebaseAuth.instance.currentUser!.uid;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>> connectStream({
    required Function onChange,
    required String listinId,
    required OrdenacaoProdutos productsOrdenation,
    required bool descending,
  }) {
    return firestore
        .collection(uid)
        .doc(listinId)
        .collection("produtos")
        .orderBy(productsOrdenation.name, descending: descending)
        .snapshots()
        .listen((snapshot) {
      onChange(snapshot: snapshot);
    });
  }

  Future<List<Produto>> readProducts({
    required String listinId,
    required OrdenacaoProdutos productsOrdenation,
    required bool descending,
    QuerySnapshot<Map<String, dynamic>>? snapshot,
  }) async {
    List<Produto> temp = [];
    snapshot ??= await firestore
        .collection(uid)
        .doc(listinId)
        .collection("produtos")
        .orderBy(productsOrdenation.name, descending: descending)
        .get();

    for (var doc in snapshot.docs) {
      Produto produto = Produto.fromMap(doc.data());
      temp.add(produto);
    }

    return temp;
  }

  addProduct({required String listinId, required Produto product}) async {
    await firestore
        .collection(uid)
        .doc(listinId)
        .collection("produtos")
        .doc(product.id)
        .set(product.toMap());
  }

  Future<void> removeProduct(
      {required String listinId, required Produto product}) async {
    return await firestore
        .collection(uid)
        .doc(listinId)
        .collection("produtos")
        .doc(product.id)
        .delete();
  }

  updateProduct({
    required String listinId,
    required Produto product,
  }) async {
    product.isComprado = !product.isComprado;

    await firestore
        .collection(uid)
        .doc(listinId)
        .collection("produtos")
        .doc(product.id)
        .update({"isComprado": product.isComprado});
  }
}
