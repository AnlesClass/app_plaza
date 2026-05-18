class Local {
  String? uid;
  final String name;
  final String description;

  Local({this.uid, required this.name, required this.description});

  Map<String, dynamic> toMap() {
    return {"name": name, "description": description};
  }

  factory Local.fromMap(Map<String, dynamic> map, String id) {
    return Local(uid: id, name: map["name"], description: map["description"]);
  }
}
