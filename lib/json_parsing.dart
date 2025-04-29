// This file contains the classes for parsing the JSON response from the API.


class Capacity {
  final EateryCapacity breakfast;
  final EateryCapacity lunch;
  final EateryCapacity dinner;

  Capacity({
    required this.breakfast,
    required this.lunch,
    required this.dinner,
  });

  factory Capacity.fromJson(Map<String, dynamic> json) {
    return Capacity(
      breakfast: EateryCapacity.fromJson(json['breakfast']),
      lunch: EateryCapacity.fromJson(json['lunch']),
      dinner: EateryCapacity.fromJson(json['dinner']),
    );
  }
}

class EateryCapacity {
  final String avail;
  final String used;

  EateryCapacity({
    required this.avail,
    required this.used,
  });

  factory EateryCapacity.fromJson(Map<String, dynamic> json) {
    return EateryCapacity(
      avail: json['avail'],
      used: json['used'],
    );
  }
}









