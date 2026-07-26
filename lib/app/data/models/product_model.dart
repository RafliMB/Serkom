class ProductModel {
  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String image;
  final double rating;

  ProductModel({
    required this.id, required this.title, required this.price,
    required this.description, required this.category,
    required this.image, required this.rating,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      image: json['image'] ?? '',
      // PERBAIKAN DI SINI: Pastikan aman dan dikonversi ke double
      rating: json['rating'] != null && json['rating']['rate'] != null 
          ? (json['rating']['rate'] as num).toDouble() 
          : 0.0,
    );
  }
}