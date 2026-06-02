class Table {
  String? uid;
  final String idLocal;
  final String name;
  final int capacity;
  final DateTime creationDate;
  final bool isEnable; // true: habilitada, false: inhabilitada
  final bool isOccupied; // true: ocupada, false: libre

  Table({
    this.uid,
    required this.idLocal,
    required this.name,
    required this.capacity,
    required this.creationDate,
    required this.isEnable,
    required this.isOccupied,
  });

  Map<String, dynamic> toMap() {
    return {
      "idLocal": idLocal,
      "name": name,
      "capacity": capacity,
      "creationDate": creationDate.toIso8601String(),
      "isEnable": isEnable,
      "isOccupied": isOccupied,
    };
  }

  factory Table.fromMap(Map<String, dynamic> map, String id) {
    return Table(
      uid: id,
      idLocal: map["idLocal"],
      name: map["name"],
      capacity: map["capacity"],
      creationDate: DateTime.parse(map["creationDate"]),
      isEnable: map["isEnable"] ?? false,
      isOccupied: map["isOccupied"] ?? false,
    );
  }
}
