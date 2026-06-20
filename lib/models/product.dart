class Product {
  String? uid;
  final String idCategory;
  final String name;

  Product({this.uid, required this.idCategory, required this.name});

  Map<String, dynamic> toMap() {
    return {"idCategory": idCategory, "name": name};
  }

  factory Product.fromMap(Map<String, dynamic> map, String id) {
    return Product(uid: id, idCategory: map["idCategory"], name: map["name"]);
  }

  @override
  String toString() => name;
}
