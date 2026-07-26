import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/services/firestore_service.dart';

class CartController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();

  // Membaca stream dari keranjang pengguna aktif
  Stream<QuerySnapshot> getCartStream() {
    return _firestoreService.getCartStream();
  }

  void increaseQty(String docId, int currentQty) {
    _firestoreService.updateCartQty(docId, currentQty + 1);
  }

  void decreaseQty(String docId, int currentQty) {
    if (currentQty > 1) {
      _firestoreService.updateCartQty(docId, currentQty - 1);
    }
  }

  void removeItem(String docId) {
    _firestoreService.removeCartItem(docId);
  }

  void goToCheckout(List<QueryDocumentSnapshot> cartDocs) {
    if (cartDocs.isEmpty) {
      Get.snackbar('Keranjang Kosong', 'Tambahkan produk ke keranjang terlebih dahulu.', backgroundColor: const Color(0xFFFF6951), colorText: const Color(0xFFFFFFFF));
      return;
    }

    double total = 0.0;
    List<Map<String, dynamic>> items = [];

    for (var doc in cartDocs) {
      var data = doc.data() as Map<String, dynamic>;
      total += (data['price'] * data['qty']);
      items.add(data);
    }

    // Arahkan ke Checkout dengan membawa payload
    Get.toNamed('/checkout', arguments: {
      'items': items,
      'total': total,
    });
  }
}