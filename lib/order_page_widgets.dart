import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'AnimatedCreditLabel.dart';
import 'json_parsing.dart';

class CreditDisplay extends StatelessWidget {
  final double previousCredit;
  final double currentCredit;

  const CreditDisplay({
    super.key,
    required this.previousCredit,
    required this.currentCredit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Kredit: ',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            AnimatedCreditLabel(
              startValue: previousCredit,
              endValue: currentCredit,
              suffix: ' Kč',
              textStyle: Theme.of(context).textTheme.titleMedium,
              duration: const Duration(milliseconds: 800),
              decimals: 0,
            ),
          ],
        ),
      ),
    );
  }
}

class DayInfoRow extends StatelessWidget {
  final String date;
  final VoidCallback onPreviousDay;
  final VoidCallback onNextDay;

  const DayInfoRow({
    super.key,
    required this.date,
    required this.onPreviousDay,
    required this.onNextDay,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: onPreviousDay,
            icon: const Icon(Icons.arrow_back),
          ),
          Expanded(
            child: Center(
              child: Text(
                '${DateFormat('EEEE').format(_parseDateTime(date))} $date',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          IconButton(
            onPressed: onNextDay,
            icon: const Icon(Icons.arrow_forward),
          ),
        ],
      ),
    );
  }
}

class MealCard extends StatelessWidget {
  final Meal meal;
  final bool isTapped;
  final int status;
  final VoidCallback? onTap;

  const MealCard({
    super.key,
    required this.meal,
    required this.isTapped,
    required this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isTapped
        ? Theme.of(context).colorScheme.errorContainer
        : _getMealStatusColor(context, status);

    return Card(
      elevation: 0.0,
      color: color,
      child: ListTile(
        title: Text(meal.name),
        subtitle: Text(meal.code),
        trailing: _buildTrailingIcon(),
        onTap: status != -1 ? onTap : null,
      ),
    );
  }

  Widget? _buildTrailingIcon() {
    if (!isTapped && status != 2) return null;

    return Icon(
      isTapped ? Icons.check_outlined : Icons.check,
      color: isTapped ? Colors.white : Colors.black,
    );
  }

  Color _getMealStatusColor(BuildContext context, int status) {
    return switch (status) {
      -1 => Theme.of(context).colorScheme.surfaceContainerLowest,
      0 => Theme.of(context).colorScheme.surfaceContainerHighest,
      2 => Theme.of(context).colorScheme.primaryContainer,
      3 => Theme.of(context).colorScheme.tertiaryContainer,
      4 => Theme.of(context).colorScheme.tertiaryContainer,
      _ => throw UnimplementedError(),
    };
  }
}

class EateriesDropdown extends StatelessWidget {
  final List<Eatery> eateries;
  final String currentEateryId;
  final ValueChanged<String?> onChanged;

  const EateriesDropdown({
    super.key,
    required this.eateries,
    required this.currentEateryId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (eateries.isEmpty) {
      return const SizedBox.shrink();
    }

    final currentEatery = eateries.firstWhere((e) => e.id == currentEateryId);

    return DropdownButton<String>(
      value: currentEatery.name,
      hint: const Text('Zvolit jídelnu'),
      items: eateries
          .map((eatery) => DropdownMenuItem<String>(
                value: eatery.name,
                child: Text(eatery.name),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }
}

class CalendarDrawer extends StatelessWidget {
  final List<CalendarItem> calendarItems;
  final Function(int) onTilePressed;

  const CalendarDrawer({
    super.key,
    required this.calendarItems,
    required this.onTilePressed,
  });

  @override
  Widget build(BuildContext context) {
    if (calendarItems.isEmpty) {
      return const Drawer(
        child: Center(child: Text('Nepodařilo se načíst kalendář')),
      );
    }

    return Drawer(
      child: ListView.builder(
        itemCount: calendarItems.length,
        itemBuilder: (context, index) => CalendarTile(
          item: calendarItems[index],
          onTap: () => onTilePressed(index),
        ),
      ),
    );
  }
}

class CalendarTile extends StatelessWidget {
  final CalendarItem item;
  final VoidCallback onTap;

  const CalendarTile({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final date = _parseDateTime(item.date);
    final hasOrders = item.orders?.isNotEmpty ?? false;
    final color = _getCalendarTileColor(context, date.weekday, hasOrders);

    return ListTile(
      title: Text("${item.date} - ${DateFormat('EEEE').format(date)}"),
      tileColor: color,
      subtitle: Text(item.orders?.map((order) => order.name).join(', ') ??
          'Žádné objednávky'),
      onTap: onTap,
    );
  }

  Color _getCalendarTileColor(BuildContext context, int weekday, bool hasOrders) {
    if (weekday >= 6) {
      return Theme.of(context).colorScheme.surfaceDim.withAlpha(255);
    }
    if (hasOrders) {
      return Theme.of(context)
          .colorScheme
          .surfaceContainerHighest
          .withAlpha(100);
    }
    return Theme.of(context).colorScheme.errorContainer.withAlpha(200);
  }
}

class DayContent extends StatelessWidget {
  final Day currentDay;
  final Map<String, bool> mealTapped;
  final Function(Meal, Day) onMealTap;
  final List<Eatery> eateries;
  final ValueChanged<String?> onEateryChanged;
  final VoidCallback onPreviousDay;
  final VoidCallback onNextDay;

  const DayContent({
    super.key,
    required this.currentDay,
    required this.mealTapped,
    required this.onMealTap,
    required this.eateries,
    required this.onEateryChanged,
    required this.onPreviousDay,
    required this.onNextDay,
  });

  @override
  Widget build(BuildContext context) {
    final meals = currentDay.meals;

    return Column(
      children: [
        const Padding(padding: EdgeInsets.only(top: 16)),
        DayInfoRow(
          date: currentDay.date,
          onPreviousDay: onPreviousDay,
          onNextDay: onNextDay,
        ),
        Expanded(
          child: meals.lunch.isEmpty
              ? Center(
                  child: Text(
                    "Žádná jídla k dispozici",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                )
              : ListView.builder(
                  itemCount: meals.lunch.length,
                  itemBuilder: (context, index) {
                    final meal = meals.lunch[index];
                    return MealCard(
                      meal: meal,
                      isTapped: mealTapped[meal.id] ?? false,
                      status: meal.status,
                      onTap: () => onMealTap(meal, currentDay),
                    );
                  },
                ),
        ),
        const Divider(),
        EateriesDropdown(
          eateries: eateries,
          currentEateryId: currentDay.eatery,
          onChanged: onEateryChanged,
        ),
        const Padding(padding: EdgeInsets.only(bottom: 12)),
      ],
    );
  }
}

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class ErrorDisplay extends StatelessWidget {
  final String error;

  const ErrorDisplay({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Chyba: $error',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      ),
    );
  }
}

DateTime _parseDateTime(String date) {
  try {
    return DateFormat('dd.MM.yyyy').parse(date);
  } catch (e) {
    throw FormatException('Invalid date format: $date');
  }
}