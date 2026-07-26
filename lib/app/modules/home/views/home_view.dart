import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      
      // Custom App Bar sesuai panduan
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Discover', style: AppTextStyles.appBarTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.surface),
                  child: IconButton(
                    icon: const Icon(Icons.shopping_bag_outlined, color: AppColors.textPrimary),
                    onPressed: () => Get.toNamed('/cart'),
                  ),
                ),
                // Badge notifikasi kecil di pojok ikon keranjang
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    constraints: const BoxConstraints(minWidth: 10, minHeight: 10),
                  ),
                )
              ],
            ),
          )
        ],
      ),
      
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        if (controller.products.isEmpty) {
          return Center(child: Text('Tidak ada produk tersedia.', style: AppTextStyles.body));
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.65, // Mengatur tinggi card agar proporsional
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: controller.products.length,
          itemBuilder: (context, index) {
            final product = controller.products[index];
            return GestureDetector(
              onTap: () => Get.toNamed('/product_detail', arguments: product),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Gambar mendominasi 70% card (flex: 7)
                    Expanded(
                      flex: 7,
                      child: Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              color: AppColors.surfaceVariant, // Latar pastel lembut
                              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Image.network(product.image, fit: BoxFit.contain),
                            ),
                          ),
                          // Ikon hati melayang di pojok kanan atas
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(6.0),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.surface,
                                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                              ),
                              child: const Icon(Icons.favorite_border, color: AppColors.primary, size: 18),
                            ),
                          )
                        ],
                      ),
                    ),
                    
                    // Detail produk mengambil sisa 30% area
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              product.title,
                              style: AppTextStyles.productTitle.copyWith(fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            // Harga menggunakan Poundsterling sesuai panduan
                            Text('£${product.price}', style: AppTextStyles.priceActive.copyWith(fontSize: 16)),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        );
      }),

      // Bottom Navigation Bar
      bottomNavigationBar: Obx(() => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BottomNavigationBar(
            currentIndex: controller.currentIndex.value,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textSecondary,
            showSelectedLabels: false, // Ikon tidak menggunakan label teks
            showUnselectedLabels: false,
            backgroundColor: AppColors.surface,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            onTap: controller.changePage,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: ''),
              BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), label: ''),
              BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), label: ''),
              BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ''),
            ],
          ),
        ),
      )),
    );
  }
}