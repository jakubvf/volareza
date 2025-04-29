class Order {
  final String eatery;
  final String eateryName;
  final String mealTp;
  final String mealId;
  final String menuId;
  final String code;
  final String name;
  final bool exchange;

  Order({
    required this.eatery,
    required this.eateryName,
    required this.mealTp,
    required this.mealId,
    required this.menuId,
    required this.code,
    required this.name,
    required this.exchange,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      eatery: json['eatery'].toString(),
      eateryName: json['eateryNm'],
      mealTp: json['mealTp'],
      mealId: json['mealId'].toString(),
      menuId: json['menuId'].toString(),
      code: json['code'],
      name: json['name'],
      exchange: json['exchange'],
    );
  }
}