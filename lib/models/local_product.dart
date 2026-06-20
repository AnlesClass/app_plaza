import 'package:cloud_firestore/cloud_firestore.dart';

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
    // Convertir Timestamp a DateTime
    final blockLimitRaw = map["blockLimit"];
    final DateTime blockLimitDateTime;

    if (blockLimitRaw is Timestamp) {
      blockLimitDateTime = blockLimitRaw.toDate();
    } else if (blockLimitRaw is DateTime) {
      blockLimitDateTime = blockLimitRaw;
    } else {
      blockLimitDateTime = DateTime.now(); // Valor por defecto si hay error
    }

    return LocalProduct(
      uid: id,
      idLocal: map["idLocal"],
      idProduct: map["idProduct"],
      prize: (map["prize"] as num).toDouble(), // Asegurar que sea double
      isBlocked: map["isBlocked"] ?? false,
      blockLimit: blockLimitDateTime,
    );
  }
}
