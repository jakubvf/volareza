// This file contains the classes for parsing the JSON response from the API.

class Facility {
  final List<CalendarItem> calendar;
  final bool calLength;
  final bool info;
  final Day initialDay;
  final List<Eatery> eateries;

  Facility({
    required this.calendar,
    required this.calLength,
    required this.info,
    required this.initialDay,
    required this.eateries,
  });

  factory Facility.fromJson(Map<String, dynamic> json) {
    // response for getFacility also contains the first day
    final calendar = (json['calender'] as List)
        .map((item) => CalendarItem.fromJson(item))
        .toList();

    return Facility(
      calendar: calendar,
      calLength: json['calLength'],
      info: json['info'],
      initialDay: Day.fromJson(json, calendar.first.date),
      eateries: (json['eateries'] as List)
          .map((item) => Eatery.fromJson(item))
          .toList(),
    );
  }
}

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

class Meals {
  final List<Meal> breakfast;
  final List<Meal> lunch;
  final List<Meal> dinner;

  Meals({
    required this.breakfast,
    required this.lunch,
    required this.dinner,
  });

  factory Meals.fromJson(Map<String, dynamic> json) {
    return Meals(
      breakfast: (json['breakfast'] as List)
          .map((item) => Meal.fromJson(item))
          .toList(),
      lunch: (json['lunch'] as List)
          .map((item) => Meal.fromJson(item))
          .toList(),
      dinner: (json['dinner'] as List)
          .map((item) => Meal.fromJson(item))
          .toList(),
    );
  }
}

class Meal {
  final String id;
  final String menuId;
  final String code;
  final String name;
  final String alergens;
  /// -1 => not available, 0 => available, 2 => ordered
  final int status;
  final int group;

  Meal({
    required this.id,
    required this.menuId,
    required this.code,
    required this.name,
    required this.alergens,
    required this.status,
    required this.group,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'],
      menuId: json['menuId'],
      code: json['code'],
      name: json['name'],
      alergens: json['alergens'],
      status: json['status'],
      group: json['group'],
    );
  }
}

class Prices {
  final List<dynamic> breakfast;
  final List<dynamic> lunch;
  final List<dynamic> dinner;

  Prices({
    required this.breakfast,
    required this.lunch,
    required this.dinner,
  });

  factory Prices.fromJson(Map<String, dynamic> json) {
    return Prices(
      breakfast: json['breakfast'],
      lunch: json['lunch'],
      dinner: json['dinner'],
    );
  }
}

class CalendarItem {
  final String date;
  final List<Order>? orders;

  CalendarItem({
    required this.date,
    this.orders,
  });

  factory CalendarItem.fromJson(Map<String, dynamic> json) {
    if (json['orders'] == null) {
      return CalendarItem(
        date: json['date'],
        orders: null,
      );
    } else {
      return CalendarItem(
        date: json['date'],
        orders: (json['orders'] as List)
            .map((order) => Order.fromJson(order))
            .toList(),
      );
    }
  }
}

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

class Eatery {
  final String id;
  final String name;

  Eatery({
    required this.id,
    required this.name,
  });

  factory Eatery.fromJson(Map<String, dynamic> json) {
    return Eatery(
      id: json['id'],
      name: json['name'],
    );
  }
}

class Day {
  final Capacity capacity;
  final Meals meals;
  final Prices prices;
  String eatery;
  final String date;

  Day({
    required this.capacity,
    required this.meals,
    required this.prices,
    required this.eatery,
    required this.date,
  });

  factory Day.fromJson(Map<String, dynamic> json, String date) {
    return Day(
      capacity: Capacity.fromJson(json['capacity']),
      meals: Meals.fromJson(json['meals']),
      prices: Prices.fromJson(json['prices']),
      eatery: json['eatery'].toString(),
      date: date,
    );
  }
}

class Login {
  final bool loggedIn;
  final String userNm;
  final String fullName;
  final String facId;
  final String facNm;
  final String lang;
  final String credit;

  Login({
    required this.loggedIn,
    required this.userNm,
    required this.fullName,
    required this.facId,
    required this.facNm,
    required this.lang,
    required this.credit,
  });

  factory Login.fromJson(Map<String, dynamic> json) {
    return Login(
      loggedIn: json['loggedIn'],
      userNm: json['userNm'],
      fullName: json['fullName'],
      facId: json['facId'],
      facNm: json['facNm'],
      lang: json['lang'],
      credit: json['credit'],
    );
  }
}