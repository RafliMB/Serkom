import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/services/firestore_service.dart';

class RegisterController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  
  var isLoading = false.obs;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<void> register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Error', 
        'Semua kolom wajib diisi!',
        backgroundColor: const Color(0xFFFF6951),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    try {
      isLoading.value = true;
      
      // 1. Buat User di Firebase Auth
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // 2. Simpan Nama & Email ke Firestore Koleksi 'users'
      await _firestoreService.createUser(name, email);
      
      // 3. Jika sukses, arahkan langsung ke Home
      Get.offAllNamed('/home'); 
      
    } on FirebaseAuthException catch (e) {
      String message = 'Terjadi kesalahan. Silakan coba lagi.';
      if (e.code == 'weak-password') {
        message = 'Password terlalu lemah (minimal 6 karakter).';
      } else if (e.code == 'email-already-in-use') {
        message = 'Email sudah terdaftar pada akun lain.';
      }
      
      Get.snackbar(
        'Gagal Mendaftar', 
        message,
        backgroundColor: const Color(0xFFFF6951),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: const Color(0xFFFF6951), colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}