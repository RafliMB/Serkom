import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoritesController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GetConnect _connect = GetConnect(); // Untuk request API

  var isLoading = true.obs;
  // Menyimpan daftar produk favorit lengkap dari API
  var favoriteProducts = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchFavorites();
  }

  void fetchFavorites() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    try {
      isLoading.value = true;
      favoriteProducts.clear();

      // 1. Ambil data favorit dari Firestore (berisi product_id)
      QuerySnapshot snapshot = await _db
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .get();

      // Ekstrak list product_id (Asumsi tersimpan dengan tipe int/number)
      List<int> favoriteIds = snapshot.docs.map((doc) {
        // Sesuaikan nama field 'product_id' dengan yang ada di Firestore Anda
        return (doc.data() as Map<String, dynamic>)['product_id'] as int;
      }).toList();

      // 2. Fetch data detail dari API untuk setiap product_id
      for (int productId in favoriteIds) {
        var productData = await _fetchProductDetail(productId);
        if (productData != null) {
          favoriteProducts.add(productData);
        }
      }

    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat produk favorit: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<Map<String, dynamic>?> _fetchProductDetail(int productId) async {
    try {
      final response = await _connect.get('https://fakestoreapi.com/products/$productId');
      
      if (response.statusCode == 200) {
        var data = response.body;
        return {
          'product_id': productId,
          'title': data['title'] ?? 'Unknown Product',
          'price': (data['price'] as num).toDouble(),
          'image': data['image'] ?? '',
          'qty': data['qty'] ?? 1,
          'size': data['size'] ?? 'S',
        };
      }
    } catch (e) {
      print('Error fetching product $productId: $e');
    }
    return null;
  }

  void removeFromFavorites(int productId) async {
    User? user = _auth.currentUser;
    if (user == null) return;

    try {
      // Cari dokumen di Firestore yang memiliki product_id tersebut dan hapus
      var query = await _db
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .where('product_id', isEqualTo: productId)
          .get();

      for (var doc in query.docs) {
        await doc.reference.delete();
      }

      // Hapus dari state UI (secara lokal) agar tidak perlu fetch ulang
      favoriteProducts.removeWhere((item) => item['product_id'] == productId);
      
      Get.snackbar('Sukses', 'Produk dihapus dari favorit');
    } catch (e) {
      Get.snackbar('Error', 'Gagal menghapus favorit: $e');
    }
  }
}