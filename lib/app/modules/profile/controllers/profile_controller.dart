import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Data Dummy Sesuai Permintaan
  final String dummyName = "Rafli Miftahul Bachtiar";
  final String dummyEmail = "rafli@ecommerce.com";
  final String dummyPhone = "+62 812-3456-7890";
  
  void logout() async {
    await _auth.signOut();
    Get.offAllNamed('/login');
  }
}