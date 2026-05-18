class Role {
  String? uid;
  final String code;
  final String name;
  final String description;

  Role({
    this.uid,
    required this.code,
    required this.name,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {"code": code, "name": name, "description": description};
  }

  factory Role.fromXD(Map<String, dynamic> map, String id) {
    return Role(
      uid: id,
      code: map["code"],
      name: map["name"],
      description: map["description"],
    );
  }
}
