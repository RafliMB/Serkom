import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/services/firestore_service.dart';

class CheckoutController extends GetxController {
  // TextField Controllers untuk Alamat
  final streetCtrl = TextEditingController();
  final districtCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final provinceCtrl = TextEditingController();
  final postalCtrl = TextEditingController();
  
  var isLoadingLocation = false.obs;
  var isCheckingOut = false.obs;
  
  // Dummy Dropdown & Radio State
  var selectedShipping = 'Reguler Delivery'.obs;
  var selectedPayment = 'BCA Virtual Account'.obs;

  // Data keranjang yang dikirim dari halaman Cart via arguments
  List<dynamic> cartItems = [];
  double totalAmount = 0.0;

  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();
    // Menangkap data dari Cart (asumsi dikirim via Get.toNamed('/checkout', arguments: {...}))
    if (Get.arguments != null) {
      cartItems = Get.arguments['items'] ?? [];
      totalAmount = Get.arguments['total'] ?? 0.0;
    }
  }

  @override
  void onClose() {
    streetCtrl.dispose();
    districtCtrl.dispose();
    cityCtrl.dispose();
    provinceCtrl.dispose();
    postalCtrl.dispose();
    super.onClose();
  }

  // LOGIKA LOKASI SANGAT PENTING
  Future<void> getLocation() async {
    try {
      isLoadingLocation.value = true;
      
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw 'Layanan lokasi tidak aktif. Aktifkan GPS Anda.';

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Izin lokasi ditolak.';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.defaultDialog(
          title: 'Izin Lokasi Dibutuhkan',
          middleText: 'Akses lokasi ditolak permanen. Buka pengaturan aplikasi untuk mengizinkan.',
          textConfirm: 'Buka Pengaturan',
          textCancel: 'Batal',
          confirmTextColor: Colors.white,
          buttonColor: const Color(0xFFFF6951),
          cancelTextColor: const Color(0xFF2C2F3E),
          onConfirm: () {
            Geolocator.openAppSettings();
            Get.back();
          }
        );
        return;
      }

      // Ambil Koordinat
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      
      // Inisialisasi object Geocoding
      final Geocoding geocoding = Geocoding();

      // Geocoding (Pecah Koordinat menjadi Alamat)
      List<Placemark> placemarks = await geocoding.placemarkFromCoordinates(
        position.latitude, 
        position.longitude
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        streetCtrl.text = place.street ?? '';
        districtCtrl.text = place.subLocality ?? '';
        cityCtrl.text = place.locality ?? '';
        provinceCtrl.text = place.administrativeArea ?? '';
        postalCtrl.text = place.postalCode ?? '';
        
        Get.snackbar('Sukses', 'Lokasi berhasil didapatkan!', backgroundColor: Colors.green, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error Lokasi', e.toString(), backgroundColor: const Color(0xFFFF6951), colorText: Colors.white);
    } finally {
      isLoadingLocation.value = false;
    }
  }

  Future<void> placeOrder() async {
    if (streetCtrl.text.isEmpty || cityCtrl.text.isEmpty) {
      Get.snackbar('Error', 'Harap lengkapi alamat pengiriman atau gunakan tombol Ambil Lokasi.', backgroundColor: const Color(0xFFFF6951), colorText: Colors.white);
      return;
    }

    try {
      isCheckingOut.value = true;
      
      final orderData = {
        'user_uid': _auth.currentUser!.uid,
        'items': cartItems,
        'address': {
          'street': streetCtrl.text,
          'district': districtCtrl.text,
          'city': cityCtrl.text,
          'province': provinceCtrl.text,
          'postal_code': postalCtrl.text,
        },
        'shipping_method': selectedShipping.value,
        'payment_method': selectedPayment.value,
        'total_amount': totalAmount,
        'created_at': DateTime.now().toIso8601String(),
      };

      await _firestoreService.createOrder(orderData);
      
      Get.offAllNamed('/home');
      Get.snackbar('Checkout Berhasil', 'Pesanan Anda sedang diproses!', backgroundColor: Colors.green, colorText: Colors.white);
      
    } catch (e) {
      Get.snackbar('Error Checkout', e.toString(), backgroundColor: const Color(0xFFFF6951), colorText: Colors.white);
    } finally {
      isCheckingOut.value = false;
    }
  }
}