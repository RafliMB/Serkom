import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/product_model.dart';
import '../../../data/services/firestore_service.dart';

class ProductDetailController extends GetxController {
  // Menangkap argument dari navigasi Home
  late ProductModel product;
  
  // State lokal untuk pilihan ukuran dan loading
  var selectedSize = 'S'.obs; 
  var isAddingToCart = false.obs;
  
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void onInit() {
    super.onInit();
    product = Get.arguments as ProductModel;
  }

  Future<void> addToCart() async {
    try {
      isAddingToCart.value = true;
      
      // Susun data sesuai skema Firestore sub-koleksi carts
      final cartItem = {
        'product_id': product.id,
        'title': product.title,
        'price': product.price,
        'image': product.image,
        'qty': 1, // Default kuantitas awal
        'size': selectedSize.value,
      };

      await _firestoreService.addToCart(cartItem);
      
      Get.snackbar(
        'Sukses', 
        'Produk ditambahkan ke keranjang!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
      );
      
    } catch (e) {
      Get.snackbar(
        'Error', 
        'Gagal menambahkan ke keranjang: $e',
        backgroundColor: const Color(0xFFFF6951),
        colorText: Colors.white,
      );
    } finally {
      isAddingToCart.value = false;
    }
  }
}