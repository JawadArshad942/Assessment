import '../../domain/entities/product.dart';

class ProductModel {
  ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.thumbnail,
    required this.images,
    this.discountPercentage,
    this.rating,
    this.stock,
    this.minimumOrderQuantity,
    this.createdAt,
  });

  final int id;
  final String title;
  final String description;
  final num price;
  final String thumbnail;
  final List<String> images;
  final num? discountPercentage;
  final num? rating;
  final int? stock;
  final int? minimumOrderQuantity;
  final DateTime? createdAt;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    DateTime? created;
    final Map<String, dynamic>? meta = (json['meta'] as Map?)?.cast<String, dynamic>();
    if (meta != null) {
      created = DateTime.tryParse(meta['createdAt'] as String? ?? '');
    }
    return ProductModel(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      price: json['price'] as num,
      thumbnail: json['thumbnail'] as String? ?? '',
      images: (json['images'] as List<dynamic>? ?? <dynamic>[]).map((dynamic e) => e as String).toList(),
      discountPercentage: json['discountPercentage'] as num?,
      rating: json['rating'] as num?,
      stock: json['stock'] as int?,
      minimumOrderQuantity: json['minimumOrderQuantity'] as int?,
      createdAt: created,
    );
  }

  ProductEntity toEntity() => ProductEntity(
        id: id,
        title: title,
        description: description,
        price: price,
        thumbnail: thumbnail,
        images: images,
        discountPercentage: discountPercentage,
        rating: rating,
        stock: stock,
        minimumOrderQuantity: minimumOrderQuantity,
        createdAt: createdAt,
      );
}
