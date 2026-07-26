import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/product_detail_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class ProductDetailView extends GetView<ProductDetailController> {
  const ProductDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceVariant, // Latar belakang abu-abu terang / mint
      body: Stack(
        children: [
          // 1. Latar Belakang Gambar Produk (Di-stack di belakang)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: Get.height * 0.6,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Image.network(controller.product.image, fit: BoxFit.contain),
              ),
            ),
          ),
          
          // 2. Custom Back Button Melingkar
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 20,
            child: InkWell(
              onTap: () => Get.back(),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.surface, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                child: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              ),
            ),
          ),
          
          // 3. Bottom Sheet System
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: Get.height * 0.5, // Mengambil 50% layar dari bawah
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul dan Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          controller.product.title, 
                          style: AppTextStyles.appBarTitle, 
                          maxLines: 2, 
                          overflow: TextOverflow.ellipsis
                        ),
                      ),
                      const SizedBox(width: 16),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 22),
                          const SizedBox(width: 4),
                          Text(controller.product.rating.toString(), style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      )
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  Text('Description', style: AppTextStyles.productTitle.copyWith(fontSize: 14)),
                  const SizedBox(height: 8),
                  Text(
                    controller.product.description,
                    style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 24),
                  Text('Size', style: AppTextStyles.productTitle.copyWith(fontSize: 14)),
                  const SizedBox(height: 8),
                  
                  // Pilihan Ukuran (.obs lokal)
                  Obx(() => Row(
                    children: ['S', 'M', 'L', 'XL'].map((size) {
                      bool isSelected = controller.selectedSize.value == size;
                      return GestureDetector(
                        onTap: () => controller.selectedSize.value = size,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(size, style: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                            fontWeight: FontWeight.bold
                          )),
                        ),
                      );
                    }).toList(),
                  )),
                  
                  const Spacer(),
                  
                  // Bagian Harga dan Tombol Add to Cart
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Price', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
                          Text('£${controller.product.price}', style: AppTextStyles.priceActive.copyWith(fontSize: 24)),
                        ],
                      ),
                      
                      // CTA Button Add to Cart
                      Obx(() => ElevatedButton(
                        onPressed: controller.isAddingToCart.value ? null : () => controller.addToCart(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                          elevation: 0,
                        ),
                        child: controller.isAddingToCart.value
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Add to Cart', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      )),
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}