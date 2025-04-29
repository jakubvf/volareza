import 'order.dart';

class Day {
  final String date;
  final List<Order>? orders;

  Day({
    required this.date,
    this.orders,
  });

  factory Day.fromJson(Map<String, dynamic> json) {
    if (json['orders'] == null) {
      return Day(
        date: json['date'],
        orders: null,
      );
    } else {
      return Day(
        date: json['date'],
        orders: (json['orders'] as List)
            .map((order) => Order.fromJson(order))
            .toList(),
      );
    }
  }
}
