class LocalProduct {
  String? uid;
  final String idLocal;
  final String idProduct;
  final double prize;
  final bool isBlocked;
  final DateTime blockLimit;

  LocalProduct({
    this.uid,
    required this.idLocal,
    required this.idProduct,
    required this.prize,
    required this.isBlocked,
    required this.blockLimit,
  });

  Map<String, dynamic> toMap() {
    return {
      "idLocal": idLocal,
      "idProduct": idProduct,
      "prize": prize,
      "isBlocked": isBlocked,
      "blockLimit": blockLimit,
    };
  }

  factory LocalProduct.fromMap(Map<String, dynamic> map, String id) {
    return LocalProduct(
      uid: id,
      idLocal: map["idLocal"],
      idProduct: map["idProduct"],
      prize: map["prize"],
      isBlocked: map["isBlocked"],
      blockLimit: map["blockLimit"],
    );
  }
}
