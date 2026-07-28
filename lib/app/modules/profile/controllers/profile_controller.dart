import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../data/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class ProfileController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Reactive observables for real user data
  var userName = ''.obs;
  var userEmail = ''.obs;
  var userPhone = ''.obs;
  var userAvatar = 'assets/images/default_profile.png'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      userEmail.value = user.email ?? '';
      try {
        final doc = await _db.collection('users').doc(user.uid).get();
        if (doc.exists) {
          userName.value = doc.get('name') ?? '';
          if (doc.data()!.containsKey('phone')) {
            userPhone.value = doc.get('phone') ?? '';
          }
          if (doc.data()!.containsKey('avatar')) {
            userAvatar.value = doc.get('avatar') ?? 'assets/images/default_profile.png';
          }
        }
      } catch (e) {
        debugPrint('Error loading profile data: $e');
      }
    }
  }

  // --- FUNGSI AKSI TOMBOL MENU --- //

  void showPersonalDetails() {
    Get.defaultDialog(
      title: 'Personal Details',
      titleStyle: AppTextStyles.appBarTitle,
      backgroundColor: AppColors.background,
      content: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.person, color: AppColors.primary),
            title: Text('Name', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary, fontSize: 12)),
            subtitle: Text(userName.value.isNotEmpty ? userName.value : '-', style: AppTextStyles.productTitle),
          ),
          ListTile(
            leading: const Icon(Icons.email, color: AppColors.primary),
            title: Text('Email', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary, fontSize: 12)),
            subtitle: Text(userEmail.value.isNotEmpty ? userEmail.value : '-', style: AppTextStyles.productTitle),
          ),
        ],
      ),
      confirm: ElevatedButton(
        onPressed: () => Get.back(),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text('Tutup', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  void goToPersonalDetails() {
    Get.toNamed('/edit-profile');
  }

  // --- FUNGSI LOGOUT --- //

  void logout() async {
    await AuthService().signOut();
    Get.offAllNamed('/login');
  }
}