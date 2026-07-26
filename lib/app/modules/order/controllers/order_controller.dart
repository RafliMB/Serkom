import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

class OrderController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Stream untuk merepresentasikan data Order secara realtime
  Stream<QuerySnapshot> getOrdersStream() {
    return _db
        .collection('orders')
        .where('user_uid', isEqualTo: _auth.currentUser!.uid)
        .snapshots();
  }
}