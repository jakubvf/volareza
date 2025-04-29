import 'eatery.dart';
import 'menu.dart';
import 'calendar.dart';

class Facility {
  final List<Day> calendar;
  final Menu initialDay;
  final List<Eatery> eateries;

  Facility({
    required this.calendar,
    required this.initialDay,
    required this.eateries,
  });

  factory Facility.fromJson(Map<String, dynamic> json) {
    // response for getFacility also contains the first day
    final calendar = (json['calender'] as List)
        .map((item) => Day.fromJson(item))
        .toList();

    return Facility(
      calendar: calendar,
      initialDay: Menu.fromJson(json, calendar.first.date),
      eateries: (json['eateries'] as List)
          .map((item) => Eatery.fromJson(item))
          .toList(),
    );
  }
}
