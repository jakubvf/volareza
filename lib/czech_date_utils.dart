import 'package:intl/intl.dart';

class CzechDateUtils {
  static String formatDateCzech(DateTime date) {
    final weekdays = ['Pondělí', 'Úterý', 'Středa', 'Čtvrtek', 'Pátek', 'Sobota', 'Neděle'];
    final months = ['ledna', 'února', 'března', 'dubna', 'května', 'června',
                   'července', 'srpna', 'září', 'října', 'listopadu', 'prosince'];
    
    return '${weekdays[date.weekday - 1]}, ${date.day}. ${months[date.month - 1]} ${date.year}';
  }

  static DateTime parseDateTime(String date) {
    try {
      return DateFormat('dd.MM.yyyy').parse(date);
    } catch (e) {
      throw FormatException('Invalid date format: $date');
    }
  }
}