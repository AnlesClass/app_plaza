class User {
  String? uid;
  final String idRol;
  final String idLocal;
  final String username;
  final String name;
  final String lastname;
  final String email;
  final bool isActive;

  User({
    this.uid,
    required this.idRol,
    required this.idLocal,
    required this.username,
    required this.name,
    required this.lastname,
    required this.email,
    required this.isActive,
  });

  Map<String, dynamic> toMap() {
    return {
      "idRol": idRol,
      "idLocal": idLocal,
      "username": username,
      "name": name,
      "lastname": lastname,
      "email": email,
      "isActive": isActive,
    };
  }

  factory User.fromMap(Map<String, dynamic> map, String id) {
    return User(
      uid: id,
      idRol: map["idRol"],
      idLocal: map["idLocal"],
      username: map["username"],
      name: map["name"],
      lastname: map["lastname"],
      email: map["email"],
      isActive: map["isActive"],
    );
  }
}
