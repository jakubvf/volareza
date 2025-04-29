
// Even though we're only using the lunch field, I'm leaving this here for future reference.
class Meals {
  final List<Meal> breakfast;
  final List<Meal> lunch;
  final List<Meal> dinner;

  Meals({
    required this.breakfast,
    required this.lunch,
    required this.dinner,
  });

  factory Meals.fromJson(Map<String, dynamic> meals, Map<String, dynamic> prices) {
    return Meals(
      breakfast: (meals['breakfast'] as List)
          .map((item) => Meal.fromJson(item, _figureOutPriceForAMeal(item['code'], prices)))
          .toList(),
      lunch: (meals['lunch'] as List)
          .map((item) => Meal.fromJson(item, _figureOutPriceForAMeal(item['code'], prices)))
          .toList(),
      dinner: (meals['dinner'] as List)
          .map((item) => Meal.fromJson(item, _figureOutPriceForAMeal(item['code'], prices)))
          .toList(),
    );
  }

  static double _figureOutPriceForAMeal(String mealCode, Map<String, dynamic> prices) {
    // I know this is stupid, but I don't know how to do it better
    if (mealCode.contains("5")) {
      return double.parse(prices['lunch'][1]['price']);
    } else {
      return double.parse(prices['lunch'][0]['price']);
    }
  }

}

/// -1 => not available, 0 => available, 2 => ordered, 3 => my meal in exchange, 4 => someone else's food in exchange
enum MealStatus {
  notAvailable,
  available,
  ordered,
  sellingOnExchange,
  availableInExchange,
}

class Meal {
  final String id;
  final String menuId;
  final String code;
  final String name;
  final String alergens;
  final MealStatus status;
  final int group;
  // TODO: Prices should be represented as fixed point numbers.
  final double price;

  Meal({
    required this.id,
    required this.menuId,
    required this.code,
    required this.name,
    required this.alergens,
    required this.status,
    required this.group,
    required this.price,
  });

  factory Meal.fromJson(Map<String, dynamic> meal, double price) {
    return Meal(
      id: meal['id'],
      menuId: meal['menuId'],
      code: meal['code'],
      name: meal['name'],
      alergens: meal['alergens'],
      status: switch(meal['status'] as int) {
        -1 => MealStatus.notAvailable,
        0 => MealStatus.available,
        2 => MealStatus.ordered,
        3 => MealStatus.sellingOnExchange,
        4 => MealStatus.availableInExchange,
        _ => MealStatus.notAvailable,
      },
      group: meal['group'],
      price: price,
    );
  }
}