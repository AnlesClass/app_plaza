class Role {
  String? uid;
  final String name;
  final String description;

  Role({this.uid, required this.name, required this.description});

  Map<String, dynamic> toMap() {
    return {"name": name, "description": description};
  }

  factory Role.fromMap(Map<String, dynamic> map, String id) {
    return Role(uid: id, name: map["name"], description: map["description"]);
  }

  @override
  String toString() {
    return name;
  }
}
