import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              
              // Header Texts
              Text('Welcome\nBack!', style: AppTextStyles.appBarTitle.copyWith(fontSize: 32)),
              const SizedBox(height: 8),
              Text('Sign in to continue.', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 40),

              // Email Field
              TextField(
                controller: controller.emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Email Address',
                  hintStyle: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
              const SizedBox(height: 16),

              // Password Field (Dengan fitur visibilitas)
              Obx(() => TextField(
                controller: controller.passwordController,
                obscureText: controller.isObscurePassword.value, // Reaktif terhadap state controller
                decoration: InputDecoration(
                  hintText: 'Password',
                  hintStyle: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  suffixIcon: IconButton(
                    icon: Icon(
                      // Ubah ikon berdasarkan state
                      controller.isObscurePassword.value ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () {
                      // Toggle state saat ditekan
                      controller.isObscurePassword.value = !controller.isObscurePassword.value;
                    },
                  ),
                ),
              )),
              const SizedBox(height: 40),

              // CTA Button Login (Email/Password)
              SizedBox(
                width: double.infinity,
                height: 54,
                child: Obx(() => ElevatedButton(
                  onPressed: controller.isLoading.value ? null : () => controller.login(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Sign In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                )),
              ),
              
              const SizedBox(height: 24),
              
              // Divider "OR"
              Row(
                children: [
                  const Expanded(child: Divider(color: AppColors.surfaceVariant, thickness: 1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('OR', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary, fontSize: 12)),
                  ),
                  const Expanded(child: Divider(color: AppColors.surfaceVariant, thickness: 1)),
                ],
              ),
              
              const SizedBox(height: 24),

              // CTA Button Google OAuth
              SizedBox(
                width: double.infinity,
                height: 54,
                child: Obx(() => OutlinedButton.icon(
                  onPressed: controller.isLoading.value ? null : () => controller.loginWithGoogle(),
                  icon: Image.network(
                    'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/120px-Google_%22G%22_logo.svg.png', 
                    height: 24,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.g_mobiledata, size: 32, color: Colors.blue),
                  ),
                  label: Text('Sign in with Google', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.surface,
                    side: const BorderSide(color: AppColors.surfaceVariant, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                )),
              ),

              const SizedBox(height: 40),
              
              // Navigasi ke Halaman Register
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account? ", style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
                  GestureDetector(
                    onTap: () => Get.toNamed('/register'),
                    child: Text('Sign Up', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}