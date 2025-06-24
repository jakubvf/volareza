import 'eatery.dart';
import 'menu.dart';
import 'calendar.dart' as cal;

class Facility {
  final List<cal.Day> calendar;
  final Menu initialDay;
  final List<Eatery> eateries;

  Facility({
    required this.calendar,
    required this.initialDay,
    required this.eateries,
  });

  factory Facility.fromJson(Map<String, dynamic> json) {
    // response for getFacility also contains the first day
    final calendarItems = (json['calender'] as List)
        .map((item) => cal.Day.fromJson(item))
        .toList();

    return Facility(
      calendar: calendarItems,
      initialDay: Menu.fromJson(json, calendarItems.first.date),
      eateries: (json['eateries'] as List)
          .map((item) => Eatery.fromJson(item))
          .toList(),
    );
  }
}
