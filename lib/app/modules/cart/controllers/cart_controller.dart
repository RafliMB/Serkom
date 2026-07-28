import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/services/firestore_service.dart';

class CartController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();

  var cartItems = <QueryDocumentSnapshot>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    cartItems.bindStream(_firestoreService.getCartStream().map((query) {
      isLoading.value = false;
      return query.docs;
    }));
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

  void goToCheckout() {
    if (cartItems.isEmpty) {
      Get.snackbar('Keranjang Kosong', 'Tambahkan produk ke keranjang terlebih dahulu.', backgroundColor: const Color(0xFFFF6951), colorText: const Color(0xFFFFFFFF));
      return;
    }

    double total = 0.0;
    List<Map<String, dynamic>> items = [];

    for (var doc in cartItems) {
      var data = doc.data() as Map<String, dynamic>;
      total += (data['price'] * data['qty']);
      items.add(data);
    }

    Get.toNamed('/checkout', arguments: {
      'items': items,
      'total': total,
    });
  }
}