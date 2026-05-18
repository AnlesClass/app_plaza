class Category {
  String? uid;
  final String name;
  final String description;

  Category({this.uid, required this.name, required this.description});

  Map<String, dynamic> toMap() {
    return {"name": name, "description": description};
  }

  factory Category.fromMap(Map<String, dynamic> map, String id) {
    return Category(
      uid: id,
      name: map["name"],
      description: map["description"],
    );
  }
}
