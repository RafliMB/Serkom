import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart'; // 1. Tambahkan import ini
import 'app/routes/app_pages.dart';
// import 'firebase_options.dart'; // (Opsional) Buka komentar ini jika Anda menggunakan FlutterFire CLI

// 2. Ubah void main() menjadi Future<void> main() async
Future<void> main() async { 
  
  // 3. Tambahkan baris ini. Wajib ada sebelum inisialisasi Firebase
  WidgetsFlutterBinding.ensureInitialized(); 

  // 4. Nyalakan mesin Firebase
  await Firebase.initializeApp(
    // options: DefaultFirebaseOptions.currentPlatform, // Buka komentar ini jika Anda sudah men-generate firebase_options.dart
  );

  runApp(
    GetMaterialApp(
      title: "Application",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    ),
  );
}