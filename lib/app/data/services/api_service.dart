import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';
import '../../core/utils/constants.dart';

class ApiService {
  Future<List<ProductModel>> fetchClothingProducts() async {
    try {
      final response = await http.get(Uri.parse(Constants.baseUrl));
      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        List<ProductModel> allProducts = data.map((json) => ProductModel.fromJson(json)).toList();
        
        // Filter spesifik kategori pakaian
        return allProducts.where((p) => 
          p.category == "men's clothing" || p.category == "women's clothing"
        ).toList();
      } else {
        throw Exception('Gagal memuat produk dari server.');
      }
    } catch (e) {
      rethrow;
    }
  }
}