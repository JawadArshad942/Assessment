import 'package:equatable/equatable.dart';

import 'product.dart';

class ProductDetailEntity extends Equatable {
  const ProductDetailEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.thumbnail,
    required this.images,
    this.category,
    this.discountPercentage,
    this.rating,
    this.stock,
    this.tags = const <String>[],
    this.brand,
    this.sku,
    this.weight,
    this.dimensions,
    this.warrantyInformation,
    this.shippingInformation,
    this.availabilityStatus,
    this.reviews = const <ReviewEntity>[],
    this.returnPolicy,
    this.minimumOrderQuantity,
    this.meta,
  });

  final int id;
  final String title;
  final String description;
  final num price;
  final String thumbnail;
  final List<String> images;
  final String? category;
  final num? discountPercentage;
  final num? rating;
  final int? stock;
  final List<String> tags;
  final String? brand;
  final String? sku;
  final num? weight;
  final DimensionsEntity? dimensions;
  final String? warrantyInformation;
  final String? shippingInformation;
  final String? availabilityStatus;
  final List<ReviewEntity> reviews;
  final String? returnPolicy;
  final int? minimumOrderQuantity;
  final MetaEntity? meta;

  ProductEntity toProductSummary() => ProductEntity(
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
      );

  @override
  List<Object?> get props => <Object?>[id, title, price, thumbnail];
}

class DimensionsEntity extends Equatable {
  const DimensionsEntity({required this.width, required this.height, required this.depth});

  final num width;
  final num height;
  final num depth;

  @override
  List<Object?> get props => <Object?>[width, height, depth];
}

class ReviewEntity extends Equatable {
  const ReviewEntity({
    required this.rating,
    required this.comment,
    required this.date,
    required this.reviewerName,
    required this.reviewerEmail,
  });

  final num rating;
  final String comment;
  final DateTime date;
  final String reviewerName;
  final String reviewerEmail;

  @override
  List<Object?> get props => <Object?>[rating, comment, reviewerEmail];
}

class MetaEntity extends Equatable {
  const MetaEntity({this.createdAt, this.updatedAt, this.barcode, this.qrCode});

  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? barcode;
  final String? qrCode;

  @override
  List<Object?> get props => <Object?>[createdAt, updatedAt, barcode, qrCode];
}
