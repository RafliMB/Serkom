import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/firestore_service.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  
  var isLoading = false.obs;
  // State untuk visibilitas password (true = sembunyikan password, false = tampilkan)
  var isObscurePassword = true.obs; 

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();

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
      // Use the detailed message from Firebase if available, otherwise fallback to generic.
      String message = e.message ?? 'Terjadi kesalahan. Silakan coba lagi.';
      // Specific handling for common error codes.
      if (e.code == 'user-not-found') {
        message = 'Pengguna dengan email ini tidak ditemukan.';
      } else if (e.code == 'wrong-password') {
        message = 'Password yang Anda masukkan salah.';
      } else if (e.code == 'invalid-email') {
        message = 'Format email tidak valid.';
      } else if (e.code == 'network-request-failed') {
        message = 'Tidak ada koneksi internet. Pastikan perangkat terhubung.';
      }
      // Log the full exception to console for debugging.
      debugPrint('Login error: ${e.code} – ${e.message}');
      
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

  /// Google OAuth login
  Future<void> loginWithGoogle() async {
    try {
      isLoading.value = true;
      UserCredential credential = await _authService.signInWithGoogle();
      User? googleUser = credential.user;

      if (googleUser != null) {
        final FirebaseFirestore db = FirebaseFirestore.instance;
        final userDoc = await db.collection('users').doc(googleUser.uid).get();

        if (!userDoc.exists) {
          await FirestoreService().createUser(
            googleUser.displayName ?? 'Pengguna Google',
            googleUser.email ?? ''
          );

          await db.collection('users').doc(googleUser.uid).set({
            'avatar': 'assets/images/avatars/default_avatar.png'
          }, SetOptions(merge: true));
        }
      }

      Get.offAllNamed('/home');
    } on Exception catch (e) {
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