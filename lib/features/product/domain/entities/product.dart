import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  const ProductEntity({
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

  @override
  List<Object?> get props => <Object?>[id, title, price, thumbnail, discountPercentage, rating, stock, minimumOrderQuantity, createdAt];
}
