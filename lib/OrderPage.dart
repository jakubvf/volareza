import 'dart:convert';
import 'dart:core';

import 'package:flutter/material.dart';
import 'ApiClient.dart';
import 'json_parsing.dart';

class OrderPage extends StatefulWidget {
  OrderPage({super.key, required this.login});

  final Login login;

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  late final Login _login;
  final Map<String, bool> _mealTapped = {};
  final Map<String, Day> _loadedDays = {};

  Facility? _facility;
  String? _error;
  late PageController _pageController;

  // static because we want to keep the index even when the user leaves to settings/profile pages
  static int _persistentPageIndex = 0;
  late int _currentPageIndex;

  @override
  void initState() {
    super.initState();

    // keeping 0 here, until persistent index works
    _pageController = PageController(initialPage: 0);
    _currentPageIndex = _persistentPageIndex;

    _login = widget.login;

    _fetchFacilityData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          isDarkTheme ? 'assets/volareza-dark.png' : 'assets/volareza.png',
          height: 40,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Text(
                'Credit: ${_login.credit} Kč',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
        ],
      ),
      drawer: _buildCalendarDrawer(),
      body: _buildContent(),
    );
  }

  Future<void> _fetchFacilityData() async {
    if (!mounted) return;

    try {
      final facility = await ApiClient.instance.getFacility();

      if (!mounted) return;
      setState(() {
        _facility = facility;
        _loadedDays[facility.initialDay.date] = facility.initialDay;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    }
  }

  Future<void> _fetchDayData(String eateryId, String date) async {
    if (!mounted) return;

    try {
      final day = await ApiClient.instance.getDay(eateryId, date);

      if (!mounted) return;
      setState(() {
        _loadedDays[date] = day;
      });
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar(e.toString());
      setState(() {
        _error = e.toString();
      });
    }
  }

  Future<void> _handleOrder(Day currentDay, Meal meal) async {
    try {
      await ApiClient.instance
          .order(currentDay.date, currentDay.eatery, meal.id, meal.menuId);

      if (!mounted) return;
      _refreshData(currentDay);
    } catch (e) {
      _showErrorSnackBar(e.toString());
    }
    finally {
      if (mounted) {
        setState(() {
          _mealTapped[meal.id] = false;
        });
      }
    }
  }

  Future<void> _handleCancelOrder(Day currentDay, Meal meal) async {
    try {
      await ApiClient.instance.cancelOrder(currentDay.date, currentDay.eatery);

      if (!mounted) return;
      _refreshData(currentDay);
    } catch (e){
      _showErrorSnackBar(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _mealTapped[meal.id] = false;
        });
      }
    }
  }

  Future<void> _refreshData(Day currentDay) async {
    await _fetchDayData(currentDay.eatery, currentDay.date);
    await _fetchFacilityData();
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildContent() {
    return Stack(
      children: [
        if (_error != null)
          CustomErrorWidget(_error!)
        else if (_facility != null)
          _buildPageView()
        else
          const EmptyStateWidget(),
      ],
    );
  }

  Widget _buildPageView() {
    if (_facility == null || _facility!.calendar.isEmpty) {
      return const EmptyStateWidget();
    }

    return PageView.builder(
      controller: _pageController,
      onPageChanged: _handlePageChange,
      itemCount: _facility!.calendar.length,
      itemBuilder: (context, index) {
        final calendarItem = _facility!.calendar[index];
        final currentDay = _loadedDays[calendarItem.date];

        if (currentDay != null) {
          return _buildDayContent(currentDay);
        }

        return const EmptyStateWidget();
      },
    );
  }

  Widget _buildDayContent(Day currentDay) {
    final meals = currentDay.meals;

    return Column(
      children: [
        const Padding(padding: EdgeInsets.only(top: 16)),
        Expanded(
          child: meals.lunch.isEmpty
              ? Text(
                  "No meals available",
                  style: Theme.of(context).textTheme.titleMedium,
                )
              : ListView(
                  children: meals.lunch
                      .map((meal) => _buildMealCard(meal, currentDay))
                      .toList(),
                ),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Text(
                  '${_getDayName(_parseDateTime(currentDay.date))} ${currentDay.date}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              _buildEateriesDropdown(currentDay),
            ],
          ),
        ),
        const Padding(padding: EdgeInsets.only(bottom: 12)),
      ],
    );
  }

  Widget _buildMealCard(Meal meal, Day currentDay) {
    final isTapped = _mealTapped[meal.id] ?? false;
    final color = isTapped
        ? Theme.of(context).colorScheme.errorContainer
        : _getMealStatusColor(meal.status);

    return Card(
      elevation: 0.0,
      color: color,
      child: ListTile(
        title: Text(meal.name),
        subtitle: Text(meal.code),
        trailing: _buildMealTrailingIcon(meal, isTapped),
        onTap:
            meal.status != -1 ? () => _handleMealTap(meal, currentDay) : null,
      ),
    );
  }

  Widget? _buildMealTrailingIcon(Meal meal, bool isTapped) {
    if (!isTapped && meal.status != 2) return null;

    return Icon(
      isTapped ? Icons.check_outlined : Icons.check,
      color: isTapped ? Colors.white : Colors.black,
    );
  }

  void _handleMealTap(Meal meal, Day currentDay) {
    final isTapped = _mealTapped[meal.id] ?? false;

    if (isTapped) {
      if (meal.status == 2) {
        _handleCancelOrder(currentDay, meal);
      } else {
        _handleOrder(currentDay, meal);
      }
    } else {
      setState(() {
        _mealTapped.clear();
        _mealTapped[meal.id] = true;
      });
    }
  }

  Color _getMealStatusColor(int status) => switch (status) {
        -1 => Theme.of(context).colorScheme.surfaceContainerLowest,
        0 => Theme.of(context).colorScheme.surfaceContainerHighest,
        2 => Theme.of(context).colorScheme.primaryContainer,
        _ => throw UnimplementedError(),
      };

  Widget _buildEateriesDropdown(Day currentDay) {
    if (_facility == null || _facility!.eateries.isEmpty) {
      return const SizedBox.shrink();
    }

    final currentEatery =
        _facility!.eateries.firstWhere((e) => e.id == currentDay.eatery);

    return DropdownButton<String>(
      value: currentEatery.name,
      hint: const Text('Select eatery'),
      items: _facility!.eateries
          .map((eatery) => DropdownMenuItem<String>(
                value: eatery.name,
                child: Text(eatery.name),
              ))
          .toList(),
      onChanged: (String? newValue) {
        if (newValue == null) return;

        final newEatery = _facility!.eateries
            .firstWhere((eatery) => eatery.name == newValue)
            .id;

        setState(() {
          _mealTapped.clear();
          currentDay.eatery = newEatery;
        });

        _fetchDayData(newEatery, currentDay.date);
      },
    );
  }

  Widget _buildCalendarDrawer() {
    if (_facility == null || _facility!.calendar.isEmpty) {
      return const Drawer(
        child: Center(child: Text('No calendar entries available')),
      );
    }

    return Drawer(
      child: ListView.builder(
        itemCount: _facility!.calendar.length,
        itemBuilder: (context, index) =>
            _buildCalendarTile(_facility!.calendar[index]),
      ),
    );
  }

  Widget? _buildCalendarTile(CalendarItem item) {
    final date = _parseDateTime(item.date);
    // Students likely don't have lunch on weekends
    // if (date.weekday >= 6) return null;

    final hasOrders = item.orders?.isNotEmpty ?? false;
    final color = _getCalendarTileColor(date.weekday, hasOrders);
    final index = _facility!.calendar.indexOf(item);

    return ListTile(
      title: Text("${item.date} - ${_getDayName(date)}"),
      tileColor: color,
      subtitle: Text(
          item.orders?.map((order) => order.name).join(', ') ?? 'No orders'),
      onTap: () {
        Navigator.pop(context);
        _pageController.jumpToPage(index);
      },
    );
  }

  void _handlePageChange(int index) {
    if (!mounted) return;
    if (index >= _facility!.calendar.length) return;

    final calendarItem = _facility!.calendar[index];
    String eateryId = _facility!.eateries.first.id;

    // Only fetch if we haven't loaded this day yet
    if (!_loadedDays.containsKey(calendarItem.date)) {
      // Try to use the same eatery as the previous day
      if (_currentPageIndex < _facility!.calendar.length) {
        final previousDate = _facility!.calendar[_currentPageIndex].date;
        final previousDay = _loadedDays[previousDate];
        if (previousDay != null) {
          eateryId = previousDay.eatery;
        }
      }

      _fetchDayData(eateryId, calendarItem.date);

      setState(() {
        _currentPageIndex = index;
        _persistentPageIndex = index;
        _mealTapped.clear();
      });
    }

    // Let's also check the next day
    if (index + 1 < _facility!.calendar.length &&
        !_loadedDays.containsKey(_facility!.calendar[index + 1].date)) {
      final nextDate = _facility!.calendar[index + 1].date;
      _fetchDayData(eateryId, nextDate);
    }
  }

  Color _getCalendarTileColor(int weekday, bool hasOrders) {
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

DateTime _parseDateTime(String date) {
  final match = RegExp(r'(\d{1,2})\.(\d{1,2})\.(\d{4})').firstMatch(date);
  if (match == null) {
    throw FormatException('Invalid date format: $date');
  }

  return DateTime(
    int.parse(match.group(3)!),
    int.parse(match.group(2)!),
    int.parse(match.group(1)!),
  );
}

String _getDayName(DateTime date) => switch (date.weekday) {
      1 => 'Monday',
      2 => 'Tuesday',
      3 => 'Wednesday',
      4 => 'Thursday',
      5 => 'Friday',
      6 => 'Saturday',
      7 => 'Sunday',
      _ => throw UnimplementedError(),
    };

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({super.key});

  @override
  Widget build(BuildContext context) =>
      const Center(child: Icon(Icons.downloading, size: 64));
}

class CustomErrorWidget extends StatelessWidget {
  final String error;

  const CustomErrorWidget(this.error, {super.key});

  @override
  @override
  Widget build(BuildContext context) => Text('Error: $error');
}
