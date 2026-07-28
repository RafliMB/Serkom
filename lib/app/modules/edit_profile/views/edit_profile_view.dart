import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/edit_profile_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Edit Profile', style: AppTextStyles.appBarTitle),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Avatar Selector
            Center(
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.surfaceVariant),
                    child: Obx(() => CircleAvatar(
                      radius: 60,
                      backgroundImage: AssetImage(controller.selectedAvatar.value),
                      backgroundColor: AppColors.surface,
                    )),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => _showAvatarPicker(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                        child: const Icon(Icons.edit, color: Colors.white, size: 20),
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Name Field
            _buildTextField(controller.nameController, 'Full Name', Icons.person_outline),
            const SizedBox(height: 16),
            
            // Email Field - Reactive check against isGoogleLogin
            Obx(() => _buildTextField(
              controller.emailController, 
              'Email Address', 
              Icons.email_outlined, 
              isEmail: true,
              isReadOnly: controller.isGoogleLogin.value,
            )),
            
            // Tombol Ubah Password (Hanya muncul jika bukan user Google OAuth)
            Obx(() {
              if (controller.isGoogleLogin.value) {
                return const SizedBox(height: 40);
              } else {
                return Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 24),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => _showChangePasswordSheet(),
                      icon: const Icon(Icons.lock_reset, color: AppColors.primary),
                      label: Text(
                        'Ubah Password',
                        style: AppTextStyles.body.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                );
              }
            }),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: Obx(() => ElevatedButton(
                onPressed: controller.isLoading.value ? null : () => controller.saveProfile(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: controller.isLoading.value
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String hint, IconData icon, {bool isEmail = false, bool isReadOnly = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      readOnly: isReadOnly,
      style: AppTextStyles.body.copyWith(
        color: isReadOnly ? AppColors.textSecondary : AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        prefixIcon: Icon(icon, color: AppColors.textSecondary),
        filled: true,
        fillColor: isReadOnly ? AppColors.surfaceVariant : AppColors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }

  // Widget Helper Khusus untuk Password Field
  Widget _buildPasswordField(TextEditingController ctrl, String hint, RxBool isObscure) {
    return Obx(() => TextField(
      controller: ctrl,
      obscureText: isObscure.value,
      style: AppTextStyles.body,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textSecondary),
        suffixIcon: IconButton(
          icon: Icon(
            isObscure.value ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: AppColors.textSecondary,
          ),
          onPressed: () => isObscure.value = !isObscure.value,
        ),
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    ));
  }

  // Bottom Sheet untuk Ubah Password
  void _showChangePasswordSheet() {
    // Bersihkan field jika user membuka ulang sheet
    controller.currentPasswordController.clear();
    controller.newPasswordController.clear();
    controller.confirmPasswordController.clear();
    
    Get.bottomSheet(
      isScrollControlled: true, // Agar sheet naik saat keyboard muncul
      Padding(
        padding: EdgeInsets.only(bottom: Get.mediaQuery.viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ubah Password', style: AppTextStyles.productTitle),
              const SizedBox(height: 24),
              
              _buildPasswordField(controller.currentPasswordController, 'Password Saat Ini', controller.isObscureCurrent),
              const SizedBox(height: 16),
              
              _buildPasswordField(controller.newPasswordController, 'Password Baru', controller.isObscureNew),
              const SizedBox(height: 16),
              
              _buildPasswordField(controller.confirmPasswordController, 'Konfirmasi Password Baru', controller.isObscureConfirm),
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                height: 54,
                child: Obx(() => ElevatedButton(
                  onPressed: controller.isChangingPassword.value ? null : () => controller.updateUserPassword(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: controller.isChangingPassword.value
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Simpan Password Baru', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAvatarPicker() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pilih Avatar', style: AppTextStyles.productTitle),
            const SizedBox(height: 16),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: controller.availableAvatars.length,
                itemBuilder: (context, index) {
                  final avatarPath = controller.availableAvatars[index];
                  return GestureDetector(
                    onTap: () {
                      controller.selectedAvatar.value = avatarPath;
                      Get.back();
                    },
                    child: Obx(() {
                      bool isSelected = controller.selectedAvatar.value == avatarPath;
                      return Container(
                        margin: const EdgeInsets.only(right: 16),
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent, width: 3),
                        ),
                        child: CircleAvatar(
                          radius: 36,
                          backgroundImage: AssetImage(avatarPath),
                        ),
                      );
                    }),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}