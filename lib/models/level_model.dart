class Level {
  String id;
  String name;
  int quantity;

  Level({
    required this.id,
    required this.name,
    required this.quantity,
  });

  //Para retornar una nueva instancia de Level
  factory Level.fromMap(Map<String, dynamic> obj) {
    return Level(
      id: obj['id'],
      name: obj['name'],
      quantity: obj['quantity'],
    );
  }
}
