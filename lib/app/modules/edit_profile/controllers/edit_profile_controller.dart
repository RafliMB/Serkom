import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../profile/controllers/profile_controller.dart';

class EditProfileController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  
  // Controller untuk fitur ubah password
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  
  var isLoading = false.obs;
  var isChangingPassword = false.obs; // Loading state khusus untuk ubah password
  var selectedAvatar = 'assets/images/default_profile.png'.obs;
  var isGoogleLogin = false.obs;

  // State untuk hide/show password
  var isObscureCurrent = true.obs;
  var isObscureNew = true.obs;
  var isObscureConfirm = true.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Daftar pilihan avatar lokal
  final List<String> availableAvatars = [
    'assets/images/default_profile.png',
    'assets/images/Avatar-1.jpg',
    'assets/images/Avatar-2.jpg',
    'assets/images/Avatar-3.jpg',
    'assets/images/Avatar-4.jpg',
  ];

  @override
  void onInit() {
    super.onInit();

    User? user = _auth.currentUser;
    if (user != null) {
      isGoogleLogin.value = user.providerData.any((provider) => provider.providerId == 'google.com');
    }    
    
    // Mengambil data dari ProfileController saat halaman dibuka
    if (Get.isRegistered<ProfileController>()) {
      final profileCtrl = Get.find<ProfileController>();
      nameController.text = profileCtrl.userName.value;
      emailController.text = profileCtrl.userEmail.value;
      selectedAvatar.value = profileCtrl.userAvatar.value;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  Future<void> saveProfile() async {
    String newName = nameController.text.trim();
    String newEmail = emailController.text.trim();

    if (newName.isEmpty || newEmail.isEmpty) {
      Get.snackbar('Error', 'Nama dan Email tidak boleh kosong!', backgroundColor: const Color(0xFFFF6951), colorText: Colors.white);
      return;
    }

    if (!GetUtils.isEmail(newEmail)) {
      Get.snackbar('Error', 'Format email tidak valid! Pastikan menggunakan format yang benar (contoh: nama@email.com).', backgroundColor: const Color(0xFFFF6951), colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;
      User? user = _auth.currentUser;
      
      if (user != null) {
        if (user.email != newEmail) {
          try {
            await user.verifyBeforeUpdateEmail(newEmail);
            Get.snackbar('Info', 'Link verifikasi perubahan email telah dikirim ke email baru Anda.', backgroundColor: Colors.blue, colorText: Colors.white);
          } on FirebaseAuthException catch (e) {
            if (e.code == 'requires-recent-login') {
              Get.snackbar(
                'Sesi Berakhir',
                'Silakan logout dan login kembali untuk memperbarui email.',
                backgroundColor: const Color(0xFFFF6951),
                colorText: Colors.white,
                duration: const Duration(seconds: 4),
              );
              return;
            } else if (e.code == 'email-already-in-use') {
              Get.snackbar('Error', 'Email sudah digunakan oleh pengguna lain.', backgroundColor: const Color(0xFFFF6951), colorText: Colors.white);
              return;
            } else {
              Get.snackbar('Error', e.message ?? 'Terjadi kesalahan saat memperbarui email: ${e.message}', backgroundColor: const Color(0xFFFF6951), colorText: Colors.white);
              return;
            }
          }
        }

        await _db.collection('users').doc(user.uid).set({
          'name': newName,
          'email': newEmail,
          'avatar': selectedAvatar.value,
        }, SetOptions(merge: true));

        if (Get.isRegistered<ProfileController>()) {
          final profileCtrl = Get.find<ProfileController>();
          profileCtrl.userName.value = newName;
          profileCtrl.userEmail.value = newEmail;
          profileCtrl.userAvatar.value = selectedAvatar.value;
        }

        Get.back();
        Get.snackbar('Sukses', 'Profil berhasil diperbarui!', backgroundColor: Colors.green, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Gagal Menyimpan', e.toString(), backgroundColor: const Color(0xFFFF6951), colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // ==== FUNGSI UBAH PASSWORD ====
  Future<void> updateUserPassword() async {
    String currentPassword = currentPasswordController.text;
    String newPassword = newPasswordController.text;
    String confirmPassword = confirmPasswordController.text;

    if (currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      Get.snackbar('Error', 'Semua kolom password harus diisi!', backgroundColor: const Color(0xFFFF6951), colorText: Colors.white);
      return;
    }

    if (newPassword != confirmPassword) {
      Get.snackbar('Error', 'Password baru dan konfirmasi tidak cocok!', backgroundColor: const Color(0xFFFF6951), colorText: Colors.white);
      return;
    }

    if (newPassword.length < 6) {
      Get.snackbar('Error', 'Password baru minimal harus 6 karakter!', backgroundColor: const Color(0xFFFF6951), colorText: Colors.white);
      return;
    }

    try {
      isChangingPassword.value = true;
      User? user = _auth.currentUser;

      if (user != null && user.email != null) {
        // 1. Re-autentikasi user dengan password lama
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );
        
        await user.reauthenticateWithCredential(credential);

        // 2. Jika re-autentikasi berhasil, update password
        await user.updatePassword(newPassword);

        // Tutup bottom sheet
        Get.back();
        
        // Bersihkan form
        currentPasswordController.clear();
        newPasswordController.clear();
        confirmPasswordController.clear();

        Get.snackbar('Sukses', 'Password berhasil diperbarui!', backgroundColor: Colors.green, colorText: Colors.white);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        Get.snackbar('Error', 'Password saat ini salah.', backgroundColor: const Color(0xFFFF6951), colorText: Colors.white);
      } else {
        Get.snackbar('Error', e.message ?? 'Gagal memperbarui password.', backgroundColor: const Color(0xFFFF6951), colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan sistem.', backgroundColor: const Color(0xFFFF6951), colorText: Colors.white);
    } finally {
      isChangingPassword.value = false;
    }
  }
}