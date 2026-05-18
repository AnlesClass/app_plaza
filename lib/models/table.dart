class Table {
  String? uid;
  final String idLocal;
  final String name;
  final int capacity;
  final DateTime creationDate;
  final bool isEnable;

  Table({
    this.uid,
    required this.idLocal,
    required this.name,
    required this.capacity,
    required this.creationDate,
    required this.isEnable,
  });

  Map<String, dynamic> toMap() {
    return {
      "idLocal": idLocal,
      "name": name,
      "capacity": capacity,
      "creationDate": creationDate.toIso8601String(), // Fecha string estándar
      "isEnable": isEnable,
    };
  }

  factory Table.fromMap(Map<String, dynamic> map, String id) {
    return Table(
      uid: id,
      idLocal: map["idLocal"],
      name: map["name"],
      capacity: map["capacity"],
      creationDate: DateTime.parse(map["creationDate"]), // String a Datetime
      isEnable: map["isEnable"],
    );
  }
}
