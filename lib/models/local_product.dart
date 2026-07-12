import 'package:cloud_firestore/cloud_firestore.dart';

class LocalProduct {
  final String? uid;
  final String idLocal;
  final String idProduct;
  final String idCategory;
  final String productName;
  final String categoryName;
  final double price;
  final bool isBlocked;
  final DateTime blockLimit;

  LocalProduct({
    this.uid,
    required this.idLocal,
    required this.idProduct,
    required this.idCategory,
    required this.productName,
    required this.categoryName,
    required this.price,
    required this.isBlocked,
    required this.blockLimit,
  });

  Map<String, dynamic> toMap() {
    return {
      "idLocal": idLocal,
      "idProduct": idProduct,
      "idCategory": idCategory,
      "productName": productName,
      "categoryName": categoryName,
      "price": price,
      "isBlocked": isBlocked,
      "blockLimit": blockLimit,
    };
  }

  factory LocalProduct.fromMap(Map<String, dynamic> map, String id) {
    // Convertir Timestamp a DateTime
    final blockLimitRaw = map["blockLimit"];
    final DateTime blockLimitDateTime;

    if (blockLimitRaw is Timestamp) {
      blockLimitDateTime = blockLimitRaw.toDate();
    } else if (blockLimitRaw is DateTime) {
      blockLimitDateTime = blockLimitRaw;
    } else {
      blockLimitDateTime = DateTime.now();
    }

    return LocalProduct(
      uid: id,
      idLocal: map["idLocal"] ?? '',
      idProduct: map["idProduct"] ?? '',
      idCategory: map["idCategory"] ?? '',
      productName: map["productName"] ?? '',
      categoryName: map["categoryName"] ?? '',
      price: (map["price"] as num? ?? 0.0).toDouble(),
      isBlocked: map["isBlocked"] ?? false,
      blockLimit: blockLimitDateTime,
    );
  }
}
