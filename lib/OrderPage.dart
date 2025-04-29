import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'AnimatedCreditLabel.dart';
import 'ApiClient.dart';
import 'json_parsing.dart';
import 'main.dart';

class OrderPage extends StatefulWidget {
  const OrderPage(
      {super.key, required this.login, required this.settingsNotifier});

  final Login login;
  final SettingsNotifier settingsNotifier;

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  /// Stores the user's login data. Used for credit.
  late final Login _login;

  /// Stores the tapped meals. Used for ordering.
  final Map<String, bool> _mealTapped = {};

  /// Stores the days that have been loaded. Duh.
  final Map<String, Day> _loadedDays = {};

  Facility? _facility;

  /// Stores the error message if an error occurs.
  String? _error;

  /// Contains each day's page.
  /// Has the ability to swipe between days.
  late PageController _pageController;

  /// static because we want to keep the index even when the user leaves to settings/profile pages
  /// although this doesn't work as expected because the page is rebuilt when the user returns
  static int _persistentPageIndex = 0;

  /// Used for animating the credit label.
  double _previousCredit = 0;

  /// Used for animating the credit label.
  /// This value is disconnected from Login.credit.
  /// I don't want to fetch the new login structure every time the user orders something.
  double _currentCredit = 0;

  /// Displays a loading indicator while doing work (mostly just waiting for network).
  bool _isLoading = true;

  /// Whether to skip weekends in the calendar.
  late final bool _showWeekends = widget.settingsNotifier.showWeekends;

  /// Filtered calendar items that exclude weekends
  List<CalendarItem> get _filteredCalendar =>
      !_showWeekends && _facility != null
          ? _facility!.calendar.where((item) {
        final date = _parseDateTime(item.date);
        return date.weekday < 6; // Monday to Friday
      }).toList()
          : _facility?.calendar ?? [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _getInitialPageIndex());
    _login = widget.login;
    _currentCredit = double.parse(_login.credit);

    _initializeData();
  }

  int _getInitialPageIndex() {
    if (_facility == null || _facility!.calendar.isEmpty) return 0;

    if (_showWeekends) {
      return _persistentPageIndex;
    }

    // Find the first non-weekend day
    for (int i = 0; i < _facility!.calendar.length; i++) {
      final date = _parseDateTime(_facility!.calendar[i].date);
      if (date.weekday < 6) {
        return i;
      }
    }
    return 0; // Default to the first day
  }

  Future<void> _initializeData() async {
    try {
      await _fetchFacilityData().then((_) async {
        if (_facility != null && _facility!.calendar.isNotEmpty) {
          // Load initial data and preload adjacent pages
          await _preloadDataAroundIndex(_persistentPageIndex);
          setState(() => _isLoading = false); // Hide loading indicator
        } else {
          setState(() => _isLoading = false);
        }
      });
    } catch (error) {
      if (!mounted) return;
      _handleError(error);
      setState(() => _isLoading = false);
    }
  }

  Future<void> _preloadDataAroundIndex(int index) async {
    final calendar = _facility!.calendar;
    List<CalendarItem> calendarToUse =
    _showWeekends ? calendar : _filteredCalendar;
    if (calendarToUse.isEmpty) return;

    if (index < 0 || index >= calendarToUse.length) {
      return;
    }

    final initialCalendarItem = calendarToUse[index];

    // preload current day
        {
      final eateryId = _figureOutEateryOfCalendarItem(initialCalendarItem);
      if (eateryId == null) {
        _handleError('Chyba při načítání jídelny');
        return;
      }
      await _fetchDayData(eateryId, initialCalendarItem.date);
    }

    // Preload the next day
    if (index + 1 < calendarToUse.length) {
      final nextCalendarItem = calendarToUse[index + 1];
      final eateryId = _figureOutEateryOfCalendarItem(nextCalendarItem);
      if (eateryId == null) {
        _handleError('Chyba při načítání jídelny');
        return;
      }
      await _fetchDayData(eateryId, nextCalendarItem.date);
    }

    // Preload the previous day
    if (index - 1 >= 0) {
      final prevCalendarItem = calendarToUse[index - 1];
      final eateryId = _figureOutEateryOfCalendarItem(prevCalendarItem);
      if (eateryId == null) {
        _handleError('Chyba při načítání jídelny');
        return;
      }
      await _fetchDayData(eateryId, prevCalendarItem.date);
    }
  }

  String? _figureOutEateryOfCalendarItem(CalendarItem item) {
    final eateryFromOrder = item.orders?.firstOrNull?.eatery;
    if (eateryFromOrder != null) return eateryFromOrder;

    final defaultEatery = widget.settingsNotifier.defaultEatery;
    if (defaultEatery != null) return defaultEatery;

    final fallbackEatery = _facility?.eateries.first.id;
    return fallbackEatery is String ? fallbackEatery : null;
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
      body: _isLoading ? const LoadingIndicator() : _buildContent(),
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
              'Kredit: ',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            AnimatedCreditLabel(
              startValue: _previousCredit,
              endValue: _currentCredit,
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


  Future<void> _handleOrder(Day currentDay, Meal meal) async {
    _optimisticUpdate(currentDay, meal, true);
    _updateCredit(-_figureOutPriceForAMeal(currentDay, meal));

    try {
      if (meal.status == 4 || meal.status == 3) {
        _updateCredit(_figureOutPriceForAMeal(currentDay, meal));
        await ApiClient.instance
            .exchange(currentDay.date, currentDay.eatery, false);
      } else {
        await ApiClient.instance
            .order(currentDay.date, currentDay.eatery, meal.id, meal.menuId);
      }
      if (!mounted) return;
      _refreshData(currentDay);
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> _handleCancelOrder(Day currentDay, Meal meal) async {
    _optimisticUpdate(currentDay, meal, false);
    _updateCredit(_figureOutPriceForAMeal(currentDay, meal));

    try {
      final succeeded = await ApiClient.instance
          .cancelOrder(currentDay.date, currentDay.eatery);
      // if order cancellation fails, try to exchange the meal
      if (!succeeded) {
        _updateCredit(-_figureOutPriceForAMeal(currentDay, meal));
        await ApiClient.instance
            .exchange(currentDay.date, currentDay.eatery, true);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Jídlo vloženo do burzy.')));
      }

      if (!mounted) return;
      _refreshData(currentDay);
    } catch (e) {
      _handleError(e);
    }
  }

  void _optimisticUpdate(Day currentDay, Meal meal, bool isOrdering) {
    // Optimistic update to skip UI delays
    List<Meal> updatedLunchMeals = currentDay.meals.lunch.map((m) {
      if (m.id == meal.id) {
        // Create a copy of the meal with the updated status
        return Meal(
          id: m.id,
          menuId: m.menuId,
          name: m.name,
          code: m.code,
          status: isOrdering ? 2 : 0,
          alergens: m.alergens,
          group: m.group,
        );
      }
      return m;
    }).toList();

    Meals updatedMeals =
    Meals(lunch: updatedLunchMeals, breakfast: [], dinner: []);

    Day optimisticDay = Day(
      date: currentDay.date,
      capacity: currentDay.capacity,
      eatery: currentDay.eatery,
      meals: updatedMeals,
      prices: currentDay.prices,
    );

    setState(() {
      _loadedDays[currentDay.date] = optimisticDay;
    });
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

    List<CalendarItem> calendarToUse =
    _showWeekends ? _facility!.calendar : _filteredCalendar;

    return PageView.builder(
      controller: _pageController,
      onPageChanged: _handlePageChange,
      itemCount: calendarToUse.length,
      itemBuilder: (context, index) {
        final calendarItem = calendarToUse[index];
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
        _buildDayInfoRow(currentDay),
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
            itemBuilder: (context, index) =>
                _buildMealCard(meals.lunch[index], currentDay),
          ),
        ),
        const Divider(),
        _buildEateriesDropdown(currentDay),
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
          IconButton(
              onPressed: () => {
                setState(() {
                  _pageController.previousPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.fastEaseInToSlowEaseOut);
                })
              },
              icon: Icon(Icons.arrow_back)),
          Expanded(
            child: Center(
                child: Text(
                  '${DateFormat('EEEE').format(_parseDateTime(currentDay.date))} ${currentDay.date}',
                  // Use DateFormat
                  style: Theme.of(context).textTheme.titleMedium,
                )),
          ),
          IconButton(
              onPressed: () => {
                setState(() {
                  _pageController.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.fastEaseInToSlowEaseOut);
                })
              },
              icon: Icon(Icons.arrow_forward)),
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
        onTap: meal.status != -1
            ? () => _handleMealTap(meal, currentDay, meal)
            : null,
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

  Color _getMealStatusColor(int status) {
    return switch (status) {
      -1 => Theme.of(context).colorScheme.surfaceContainerLowest,
      0 => Theme.of(context).colorScheme.surfaceContainerHighest,
      2 => Theme.of(context).colorScheme.primaryContainer,
    // 3 => moje jidlo vlozene do burzy
      3 => Theme.of(context).colorScheme.tertiaryContainer,
    // 4 => jidlo dostupne v burze
      4 => Theme.of(context).colorScheme.tertiaryContainer,
      _ => throw UnimplementedError(),
    };
  }

  Widget _buildEateriesDropdown(Day currentDay) {
    if (_facility == null || _facility!.eateries.isEmpty) {
      return const SizedBox.shrink();
    }

    final currentEatery =
    _facility!.eateries.firstWhere((e) => e.id == currentDay.eatery);

    return DropdownButton<String>(
      value: currentEatery.name,
      hint: const Text('Zvolit jídelnu'),
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
        child: Center(child: Text('Nepodařilo se načíst kalendář')),
      );
    }

    List<CalendarItem> calendarToUse =
    _showWeekends ? _facility!.calendar : _filteredCalendar;

    return Drawer(
      child: ListView.builder(
        itemCount: calendarToUse.length,
        itemBuilder: (context, index) =>
            _buildCalendarTile(calendarToUse[index], index),
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
      subtitle: Text(item.orders?.map((order) => order.name).join(', ') ??
          'Žádné objednávky'),
      onTap: () {
        Navigator.pop(context);
        _pageController.jumpToPage(index);
      },
    );
  }

  void _handlePageChange(int index) {
    if (!mounted || _facility == null) {
      return;
    }

    List<CalendarItem> calendarToUse =
    _showWeekends ? _facility!.calendar : _filteredCalendar;

    if (index < 0 || index >= calendarToUse.length) return;

    final calendarItem = calendarToUse[index];

    if (!_loadedDays.containsKey(calendarItem.date)) {
      String? eateryId = _figureOutEateryOfCalendarItem(calendarItem);
      if (eateryId == null) {
        _handleError('Chyba při načítání jídelny');
        return;
      }
      _fetchDayData(eateryId, calendarItem.date);
    }

    setState(() {
      _persistentPageIndex = index;
      _mealTapped.clear();
    });

    // Preload the next day if not loaded
    if (index + 1 < calendarToUse.length) {
      final nextDateItem = calendarToUse[index + 1];
      if (!_loadedDays.containsKey(nextDateItem.date)) {
        String? eateryId = _figureOutEateryOfCalendarItem(calendarItem);
        if (eateryId == null) {
          _handleError('Chyba při načítání jídelny');
          return;
        }

        _fetchDayData(eateryId, nextDateItem.date);
      }
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
          'Chyba: $error',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      ),
    );
  }
}
