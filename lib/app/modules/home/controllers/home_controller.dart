import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../data/models/product_model.dart';
import '../../../data/services/api_service.dart';
import '../../../data/services/firestore_service.dart';

class HomeController extends GetxController {
  var isLoading = true.obs;
  var products = <ProductModel>[].obs;
  final ApiService _apiService = ApiService();
  final FirestoreService _firestoreService = FirestoreService();

  // Variabel untuk Bottom Nav Bar
  var currentIndex = 0.obs;
  var favoriteIds = <int>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
    favoriteIds.bindStream(_firestoreService.getFavoritesStream());
  }

  Future<void> fetchProducts() async {
    try {
      isLoading.value = true;
      var fetchedData = await _apiService.fetchClothingProducts();
      products.assignAll(fetchedData);
    } catch (e) {
      Get.snackbar(
        'Error', 
        'Gagal mengambil data produk: ${e.toString()}',
        backgroundColor: const Color(0xFFFF6951),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void changePage(int index) {
    if (index == 0) return;
    
    String route = '';
    if (index == 1) route = '/cart';
    if (index == 2) route = '/order';
    if (index == 3) route = '/profile';
    
    if (route.isNotEmpty) {
      Get.toNamed(route);
    }
  }

  void toggleFavorite(int productId) async {
    try {
      await _firestoreService.toggleFavorite(productId);
    } catch (e) {
      Get.snackbar(
        'Error', 
        'Gagal memperbarui favorit: $e',
        backgroundColor: const Color(0xFFFF6951),
        colorText: Colors.white,
      );
    }
  }
}