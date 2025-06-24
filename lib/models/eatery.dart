class Eatery {
  final String id;
  final String name;

  Eatery({
    required this.id,
    required this.name,
  });

  factory Eatery.fromJson(Map<String, dynamic> json) {
    return Eatery(
      id: json['id'].toString(),
      name: json['name'],
    );
  }
}