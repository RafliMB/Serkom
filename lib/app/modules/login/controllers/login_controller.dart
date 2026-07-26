import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  
  var isLoading = false.obs;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<void> login() async {
    if (emailController.text.trim().isEmpty || passwordController.text.trim().isEmpty) {
      Get.snackbar(
        'Error', 
        'Email dan password tidak boleh kosong!',
        backgroundColor: const Color(0xFFFF6951),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    try {
      isLoading.value = true;
      await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      
      // Jika sukses, arahkan ke Home dan hapus semua riwayat rute sebelumnya
      Get.offAllNamed('/home'); 
      
    } on FirebaseAuthException catch (e) {
      String message = 'Terjadi kesalahan. Silakan coba lagi.';
      if (e.code == 'user-not-found') {
        message = 'Pengguna dengan email ini tidak ditemukan.';
      } else if (e.code == 'wrong-password') {
        message = 'Password yang Anda masukkan salah.';
      }
      
      Get.snackbar(
        'Gagal Login', 
        message,
        backgroundColor: const Color(0xFFFF6951),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      Get.snackbar(
        'Error', 
        e.toString(),
        backgroundColor: const Color(0xFFFF6951),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}