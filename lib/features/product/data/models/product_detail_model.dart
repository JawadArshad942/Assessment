import '../../domain/entities/product_detail.dart';

class ProductDetailModel {
  ProductDetailModel({
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

  factory ProductDetailModel.fromJson(Map<String, dynamic> json) {
    DimensionsEntity? dims;
    if (json['dimensions'] != null) {
      final Map<String, dynamic> d = (json['dimensions'] as Map).cast<String, dynamic>();
      dims = DimensionsEntity(width: d['width'] as num, height: d['height'] as num, depth: d['depth'] as num);
    }
    final List<ReviewEntity> revs = (json['reviews'] as List<dynamic>? ?? <dynamic>[])
        .map((dynamic r) => (r as Map).cast<String, dynamic>())
        .map((Map<String, dynamic> r) => ReviewEntity(
              rating: r['rating'] as num,
              comment: r['comment'] as String? ?? '',
              date: DateTime.tryParse(r['date'] as String? ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
              reviewerName: r['reviewerName'] as String? ?? '',
              reviewerEmail: r['reviewerEmail'] as String? ?? '',
            ))
        .toList();
    MetaEntity? meta;
    if (json['meta'] != null) {
      final Map<String, dynamic> m = (json['meta'] as Map).cast<String, dynamic>();
      meta = MetaEntity(
        createdAt: DateTime.tryParse(m['createdAt'] as String? ?? ''),
        updatedAt: DateTime.tryParse(m['updatedAt'] as String? ?? ''),
        barcode: m['barcode'] as String?,
        qrCode: m['qrCode'] as String?,
      );
    }
    return ProductDetailModel(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      price: json['price'] as num,
      thumbnail: json['thumbnail'] as String? ?? '',
      images: (json['images'] as List<dynamic>? ?? <dynamic>[]).map((dynamic e) => e as String).toList(),
      category: json['category'] as String?,
      discountPercentage: json['discountPercentage'] as num?,
      rating: json['rating'] as num?,
      stock: json['stock'] as int?,
      tags: (json['tags'] as List<dynamic>? ?? <dynamic>[]).map((dynamic e) => e as String).toList(),
      brand: json['brand'] as String?,
      sku: json['sku'] as String?,
      weight: json['weight'] as num?,
      dimensions: dims,
      warrantyInformation: json['warrantyInformation'] as String?,
      shippingInformation: json['shippingInformation'] as String?,
      availabilityStatus: json['availabilityStatus'] as String?,
      reviews: revs,
      returnPolicy: json['returnPolicy'] as String?,
      minimumOrderQuantity: json['minimumOrderQuantity'] as int?,
      meta: meta,
    );
  }

  ProductDetailEntity toEntity() => ProductDetailEntity(
        id: id,
        title: title,
        description: description,
        price: price,
        thumbnail: thumbnail,
        images: images,
        category: category,
        discountPercentage: discountPercentage,
        rating: rating,
        stock: stock,
        tags: tags,
        brand: brand,
        sku: sku,
        weight: weight,
        dimensions: dimensions,
        warrantyInformation: warrantyInformation,
        shippingInformation: shippingInformation,
        availabilityStatus: availabilityStatus,
        reviews: reviews,
        returnPolicy: returnPolicy,
        minimumOrderQuantity: minimumOrderQuantity,
        meta: meta,
      );
}
