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
      id: obj.containsKey('id') ? obj['id'] : 'no-id',
      name: obj.containsKey('name') ? obj['name'] : 'no-name',
      quantity: obj.containsKey('quantity') ? obj['quantity'] : 'no-quantity',
    );
  }
}
