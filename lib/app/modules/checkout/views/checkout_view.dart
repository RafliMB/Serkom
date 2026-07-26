import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/checkout_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class CheckoutView extends GetView<CheckoutController> {
  const CheckoutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.surface, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
            child: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          ),
          onPressed: () => Get.back(),
        ),
        title: Text('Checkout', style: AppTextStyles.appBarTitle),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TOMBOL AMBIL LOKASI (GEOLOCATOR)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: Obx(() => ElevatedButton.icon(
                onPressed: controller.isLoadingLocation.value ? null : () => controller.getLocation(),
                icon: controller.isLoadingLocation.value 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.my_location, color: Colors.white),
                label: Text(controller.isLoadingLocation.value ? 'Mencari...' : 'Gunakan Lokasi Saat Ini', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.textPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              )),
            ),
            const SizedBox(height: 24),
            
            // FORM ALAMAT (5 TextField Terpisah)
            Text('Shipping Address', style: AppTextStyles.productTitle),
            const SizedBox(height: 12),
            _buildTextField(controller.streetCtrl, 'Jalan / Detail Alamat'),
            _buildTextField(controller.districtCtrl, 'Kecamatan'),
            _buildTextField(controller.cityCtrl, 'Kota / Kabupaten'),
            Row(
              children: [
                Expanded(child: _buildTextField(controller.provinceCtrl, 'Provinsi')),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField(controller.postalCtrl, 'Kode Pos')),
              ],
            ),
            const SizedBox(height: 24),

            // DUMMY DROPDOWN PENGIRIMAN
            Text('Shipping Method', style: AppTextStyles.productTitle),
            const SizedBox(height: 12),
            Obx(() => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: controller.selectedShipping.value,
                  items: ['Reguler Delivery', 'Express Delivery', 'Next Day'].map((String value) {
                    return DropdownMenuItem<String>(value: value, child: Text(value, style: AppTextStyles.body));
                  }).toList(),
                  onChanged: (val) => controller.selectedShipping.value = val!,
                ),
              ),
            )),
            const SizedBox(height: 24),

            // PAYMENT METHOD (Baris dengan Logo, Nomor Disamarkan, Radio Button)
            Text('Payment Method', style: AppTextStyles.productTitle),
            const SizedBox(height: 12),
            _buildPaymentMethod('BCA Virtual Account', '**** **** 1234', Icons.account_balance),
            const SizedBox(height: 12),
            _buildPaymentMethod('Credit Card', '**** **** **** 8890', Icons.credit_card),
            
            const SizedBox(height: 100), // Spacing for bottom container
          ],
        ),
      ),
      
      // CONTAINER BAWAH: RINGKASAN HARGA & TOMBOL PLACE ORDER
      bottomSheet: Container(
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
                  Text('Total Price', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
                  Text('£${controller.totalAmount.toStringAsFixed(2)}', style: AppTextStyles.priceActive.copyWith(fontSize: 22)),
                ],
              ),
              Obx(() => ElevatedButton(
                onPressed: controller.isCheckingOut.value ? null : () => controller.placeOrder(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: controller.isCheckingOut.value 
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Place Order', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              )),
            ],
          ),
        ),
      ),
    );
  }

  // Widget Helper untuk Form
  Widget _buildTextField(TextEditingController ctrl, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  // Widget Helper untuk Payment Method
  Widget _buildPaymentMethod(String name, String number, IconData icon) {
    return Obx(() {
      bool isSelected = controller.selectedPayment.value == name;
      return GestureDetector(
        onTap: () => controller.selectedPayment.value = name,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent, width: 2),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: AppColors.textPrimary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: AppTextStyles.productTitle.copyWith(fontSize: 14)),
                    Text(number, style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
              // Radio Button Melingkar Warna Coral
              Container(
                width: 24, height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: isSelected ? AppColors.primary : AppColors.textSecondary, width: 2),
                ),
                child: isSelected ? Center(child: Container(width: 12, height: 12, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primary))) : null,
              )
            ],
          ),
        ),
      );
    });
  }
}