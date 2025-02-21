import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'AnimatedCreditLabel.dart';
import 'ApiClient.dart';
import 'json_parsing.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key, required this.login});

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

  double _previousCredit = 0;
  double _currentCredit = 0;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _persistentPageIndex);
    _currentPageIndex = _persistentPageIndex;
    _login = widget.login;
    _currentCredit = double.parse(_login.credit);

    _fetchInitialData(); // Fetch initial data immediately
  }

  Future<void> _fetchInitialData() async {
    await _fetchFacilityData().then((_) {
      // After facility data is loaded, fetch the initial day's data
      if (_facility != null && _facility!.calendar.isNotEmpty) {
        final initialCalendarItem = _facility!.calendar[_persistentPageIndex];
        String eateryId = _facility!.eateries.first.id;

        //Ensure the eatery id exists, otherwise default to first.
        if (_facility!.eateries.isEmpty){
          eateryId = _facility!.eateries.first.id;
        }
        _fetchDayData(eateryId, initialCalendarItem.date).then((_) {
          setState(() {
            _isLoading = false; // Set loading to false after initial data is fetched
          });
        });
      } else {
        setState(() {
          _isLoading = false; // Set loading to false if there's no calendar data
        });
      }
    }).catchError((error) {
      _handleError(error);
      setState(() {
        _isLoading = false; // Ensure loading is set to false even if there's an error
      });
    });
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
            _buildCreditDisplay(context),
          ]),
      drawer: _buildCalendarDrawer(),
      body: _isLoading ? const LoadingIndicator() : _buildContent(), // Conditionally render content
    );
  }

  Widget _buildCreditDisplay(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Credit: ',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            AnimatedCreditLabel(
              startValue: _previousCredit,
              endValue: _currentCredit,
              suffix: ' Kč',
              textStyle: Theme.of(context).textTheme.titleMedium,
              duration: const Duration(milliseconds: 800),
              decimals: 2,
            ),
          ],
        ),
      ),
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
      return;
    } catch (e) {
      if (!mounted) return;
      _handleError(e);
      return;
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
      return;
    } catch (e) {
      if (!mounted) return;
      _handleError(e);
      return;
    }
  }

  double _figureOutPriceForAMeal(Day currentDay, Meal meal) {
    // I know this is stupid, but I don't know how to do it better
    if (meal.code.contains("5")) {
      return double.parse(currentDay.prices.lunch[1]['price']);
    } else {
      return double.parse(currentDay.prices.lunch[0]['price']);
    }
  }

  Future<void> _handleOrder(Day currentDay, Meal meal) async {
    _updateCredit(-_figureOutPriceForAMeal(currentDay, meal));

    try {
      await ApiClient.instance
          .order(currentDay.date, currentDay.eatery, meal.id, meal.menuId);

      if (!mounted) return;
      _refreshData(currentDay);
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> _handleCancelOrder(Day currentDay, Meal meal) async {
    _updateCredit(_figureOutPriceForAMeal(currentDay, meal));

    try {
      await ApiClient.instance.cancelOrder(currentDay.date, currentDay.eatery);

      if (!mounted) return;
      _refreshData(currentDay);
    } catch (e) {
      _handleError(e);
    }
  }

  void _updateCredit(double amount) {
    setState(() {
      _mealTapped.clear();
      _previousCredit = _currentCredit;
      _currentCredit += amount;
    });
  }

  Future<void> _refreshData(Day currentDay) async {
    await _fetchDayData(currentDay.eatery, currentDay.date);
    await _fetchFacilityData();
  }

  void _handleError(dynamic error) {
    final errorMessage = error.toString();
    _showErrorSnackBar(errorMessage);
    setState(() {
      _error = errorMessage;
    });
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
          ErrorDisplay(error: _error!) // Use a named parameter
        else if (_facility != null)
          _buildPageView()
        else
          const LoadingIndicator(), // More descriptive name
      ],
    );
  }

  Widget _buildPageView() {
    if (_facility == null || _facility!.calendar.isEmpty) {
      return const LoadingIndicator();
    }

    return PageView.builder(
      controller: _pageController,
      onPageChanged: _handlePageChange,
      itemCount: _facility!.calendar.length,
      itemBuilder: (context, index) {
        final calendarItem = _facility!.calendar[index];
        final currentDay = _loadedDays[calendarItem.date];

        return currentDay != null
            ? _buildDayContent(currentDay)
            : const LoadingIndicator(); // Consider showing loading here too
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
              ? Center(
            child: Text(
              "No meals available",
              style: Theme.of(context).textTheme.titleMedium,
            ),
          )
              : ListView.builder(
            itemCount: meals.lunch.length,
            itemBuilder: (context, index) =>
                _buildMealCard(meals.lunch[index], currentDay),
          ),
        ),
        const Divider(),
        _buildDayInfoRow(currentDay),
        const Padding(padding: EdgeInsets.only(bottom: 12)),
      ],
    );
  }

  Widget _buildDayInfoRow(Day currentDay) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Text(
              '${DateFormat('EEEE').format(_parseDateTime(currentDay.date))} ${currentDay.date}', // Use DateFormat
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          _buildEateriesDropdown(currentDay),
        ],
      ),
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
        trailing: _buildMealTrailingIcon(meal, isTapped, meal.status),
        onTap:
        meal.status != -1 ? () => _handleMealTap(meal, currentDay, meal) : null,
      ),
    );
  }

  Widget? _buildMealTrailingIcon(Meal meal, bool isTapped, int status) {
    if (!isTapped && status != 2) return null;

    return Icon(
      isTapped ? Icons.check_outlined : Icons.check,
      color: isTapped ? Colors.white : Colors.black,
    );
  }

  void _handleMealTap(Meal meal, Day currentDay, Meal tappedMeal) {
    final isTapped = _mealTapped[tappedMeal.id] ?? false;

    if (isTapped) {
      if (tappedMeal.status == 2) {
        _handleCancelOrder(currentDay, tappedMeal);
      } else {
        _handleOrder(currentDay, tappedMeal);
      }
    } else {
      setState(() {
        _mealTapped.clear();
        _mealTapped[tappedMeal.id] = true;
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
            _buildCalendarTile(_facility!.calendar[index], index),
      ),
    );
  }

  Widget _buildCalendarTile(CalendarItem item, int index) {
    final date = _parseDateTime(item.date);

    final hasOrders = item.orders?.isNotEmpty ?? false;
    final color = _getCalendarTileColor(date.weekday, hasOrders);

    return ListTile(
      title: Text("${item.date} - ${DateFormat('EEEE').format(date)}"),
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
    if (_facility == null || index >= _facility!.calendar.length) return;

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
  try {
    return DateFormat('dd.MM.yyyy').parse(date);
  } catch (e) {
    throw FormatException('Invalid date format: $date');
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

  const ErrorDisplay({super.key, required this.error}); // Use named parameter

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Error: $error',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      ),
    );
  }
}