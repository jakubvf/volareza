import 'meal.dart';
import '../json_parsing.dart';

class Menu {
  final String date;
  final String eatery;
  final Capacity capacity;
  final Meals meals;
  final Map<String, dynamic> prices;

  Menu({
    required this.date,
    required this.eatery,
    required this.capacity,
    required this.meals,
    required this.prices,
  });

  factory Menu.fromJson(Map<String, dynamic> json, String date) {
    return Menu(
      date: date,
      eatery: json['eatery'].toString() ?? '',
      capacity: Capacity.fromJson(json['capacity'] ?? {}),
      meals: Meals.fromJson(json['meals'] ?? {}, json['prices'] ?? {}),
      prices: json['prices'] ?? {},
    );
  }
}

// Type alias so OrderPage can use Day instead of Menu
typedef Day = Menu;