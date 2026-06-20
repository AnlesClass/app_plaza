import 'package:app_plaza_flutter/models/models.dart';

class LocalProductWithDetails {
  final LocalProduct localProduct;
  final Product product;

  LocalProductWithDetails({required this.localProduct, required this.product});

  String get id => localProduct.uid ?? '';
  String get name => product.name;
  String get idCategory => product.idCategory;
  double get price => localProduct.prize;
  bool get isBlocked => localProduct.isBlocked;
  DateTime get blockLimit => localProduct.blockLimit;
}
