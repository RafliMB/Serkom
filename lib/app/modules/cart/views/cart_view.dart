import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import '../controllers/cart_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class CartView extends GetView<CartController> {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('My Cart', style: AppTextStyles.appBarTitle),
        centerTitle: true,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.surface, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
            child: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (controller.cartItems.isEmpty) {
            return Center(child: Text('Keranjang Anda kosong.', style: AppTextStyles.productTitle));}

          double totalAmount = controller.cartItems.fold(0, (totalSum, doc) {
            var data = doc.data() as Map<String, dynamic>;
            return totalSum + (data['price'] * data['qty']);
          });

          return Stack(
            children: [
              ListView.builder(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 120),
                itemCount: controller.cartItems.length,
                itemBuilder: (context, index) {
                  var doc = controller.cartItems[index];
                  var data = doc.data() as Map<String, dynamic>;
                  String docId = doc.id;
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      children: [
                        // Gambar Produk (Kiri)
                        Container(
                          width: 80, 
                          height: 80,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant, 
                            borderRadius: BorderRadius.circular(16)
                          ),
                          child: Image.network(data['image'], fit: BoxFit.contain),
                        ),
                        const SizedBox(width: 12),
                        
                        // Detail Produk (Tengah)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(data['title'], style: AppTextStyles.productTitle.copyWith(fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                              Text('Size: ${data['size']}', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary, fontSize: 12)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text('£${(data['price'] * 1.2).toStringAsFixed(2)}', style: AppTextStyles.priceStrikethrough), // Dummy Harga coret
                                  const SizedBox(width: 8),
                                  Text('£${data['price']}', style: AppTextStyles.priceActive.copyWith(fontSize: 16)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        // Kontrol Qty dan Hapus (Kanan)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: AppColors.primary),
                              onPressed: () => controller.removeItem(docId),
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                InkWell(
                                  onTap: () => controller.decreaseQty(docId, data['qty']),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(border: Border.all(color: AppColors.textSecondary), borderRadius: BorderRadius.circular(8)),
                                    child: const Icon(Icons.remove, size: 16, color: AppColors.textPrimary),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(data['qty'].toString(), style: AppTextStyles.productTitle),
                                const SizedBox(width: 12),
                                InkWell(
                                  onTap: () => controller.increaseQty(docId, data['qty']),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
                                    child: const Icon(Icons.add, size: 16, color: Colors.white),
                                  ),
                                ),
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                  );
                },
              ),
              
              // Container Bawah (Ringkasan Total & CTA)
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: SafeArea(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
                            Text('£${totalAmount.toStringAsFixed(2)}', style: AppTextStyles.priceActive.copyWith(fontSize: 22)),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () => controller.goToCheckout(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          child: const Text('Checkout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        )
                      ],
                    ),
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}