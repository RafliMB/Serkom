import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/favorites_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../routes/app_pages.dart';
import '../../../data/models/product_model.dart'; // Import ProductModel

class FavoritesView extends GetView<FavoritesController> {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Produk Favorit', style: AppTextStyles.appBarTitle),
        centerTitle: true,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]
            ),
            child: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        if (controller.favoriteProducts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border, size: 80, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'Belum ada produk favorit',
                  style: AppTextStyles.body.copyWith(color: AppColors.textSecondary, fontSize: 16),
                ),
              ],
            ),
          );
        }

        // Menggunakan GridView yang persis dengan di HomeView
        return GridView.builder(
          padding: const EdgeInsets.all(16.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.65, // Mengatur tinggi card agar proporsional
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: controller.favoriteProducts.length,
          itemBuilder: (context, index) {
            final productMap = controller.favoriteProducts[index];
            
            // Konversi Map dari API ke ProductModel agar sesuai dengan yang diterima ProductDetailView
            final ProductModel product = ProductModel.fromJson(productMap);

            return GestureDetector(
              onTap: () => Get.toNamed(Routes.PRODUCT_DETAIL, arguments: product),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4))
                  ],
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
                              child: product.image.isNotEmpty
                                ? Image.network(product.image, fit: BoxFit.contain)
                                : const Icon(Icons.image, color: Colors.grey),
                            ),
                          ),
                          // Ikon hati melayang di pojok kanan atas
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () => controller.removeFromFavorites(product.id),
                              child: Container(
                                padding: const EdgeInsets.all(6.0),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.surface,
                                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                                ),
                                child: const Icon(
                                  Icons.favorite,
                                  color: AppColors.primary, // Hati selalu terisi karena ini halaman Favorit
                                  size: 18,
                                ),
                              ),
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
                            // Harga menggunakan Poundsterling sesuai HomeView
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
    );
  }
}