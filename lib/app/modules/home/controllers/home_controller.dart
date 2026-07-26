import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../data/models/product_model.dart';
import '../../../data/services/api_service.dart';

class HomeController extends GetxController {
  var isLoading = true.obs;
  var products = <ProductModel>[].obs;
  final ApiService _apiService = ApiService();

  // Variabel untuk Bottom Nav Bar
  var currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
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
    currentIndex.value = index;
    // Logika navigasi sederhana berdasarkan index
    if (index == 1) Get.toNamed('/cart');
    if (index == 2) Get.toNamed('/order');
    if (index == 3) Get.toNamed('/profile');
  }
}