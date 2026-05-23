class Local {
  String? uid;
  final String name;
  final String address;
  final String ruc;

  Local({
    this.uid,
    required this.name,
    required this.address,
    required this.ruc,
  });

  Map<String, dynamic> toMap() {
    return {"name": name, "address": address, "ruc": ruc};
  }

  factory Local.fromMap(Map<String, dynamic> map, String id) {
    return Local(
      uid: id,
      name: map["name"],
      address: map["address"],
      ruc: map["ruc"],
    );
  }

  @override
  String toString() {
    return name;
  }
}
