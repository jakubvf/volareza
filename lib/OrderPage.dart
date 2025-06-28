import 'package:flutter/material.dart';
import 'VolarezaService.dart';
import 'models/login.dart';
import 'models/menu.dart';
import 'models/facility.dart';
import 'models/meal.dart';
import 'models/calendar.dart' as cal;
import 'settings/settings_provider.dart';
import 'order_page_widgets.dart';
import 'date_utils.dart';
import 'error_handler.dart';

// Type alias for compatibility
typedef CalendarItem = cal.Day;

class OrderPage extends StatefulWidget {
  const OrderPage(
      {super.key, required this.login, required this.volarezaService});

  final Login login;
  final VolarezaService volarezaService;

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
  bool get _showWeekends => SettingsProvider.of(context).showWeekends;

  /// Filtered calendar items that exclude weekends
  List<CalendarItem> get _filteredCalendar {
    if (_facility == null) return [];
    return !_showWeekends
        ? _facility!.calendar.where((item) {
            final date = CzechDateUtils.parseDateTime(item.date);
            return date.weekday < 6; // Monday to Friday
          }).toList().cast<CalendarItem>()
        : _facility!.calendar.cast<CalendarItem>();
  }

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
      final date = CzechDateUtils.parseDateTime(_facility!.calendar[i].date);
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
    List<CalendarItem> calendarToUse =
        _showWeekends ? _facility!.calendar.cast<CalendarItem>() : _filteredCalendar;
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

    final defaultEatery = SettingsProvider.of(context).defaultEatery;
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
            CreditDisplay(
              previousCredit: _previousCredit,
              currentCredit: _currentCredit,
            ),
          ]),
      drawer: CalendarDrawer(
        calendarItems: _filteredCalendar,
        onTilePressed: (index) {
          Navigator.pop(context);
          _pageController.jumpToPage(index);
        },
      ),
      body: _isLoading ? const LoadingIndicator() : _buildContent(),
    );
  }

  Future<void> _fetchFacilityData() async {
    if (!mounted) return;

    try {
      final facility = await widget.volarezaService.getFacility();

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
      final day = await widget.volarezaService.getDay(eateryId, date);

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
      if (meal.status == MealStatus.availableInExchange || meal.status == MealStatus.sellingOnExchange) {
        _updateCredit(_figureOutPriceForAMeal(currentDay, meal));
        await widget.volarezaService
            .exchange(currentDay.date, currentDay.eatery, false);
      } else {
        await widget.volarezaService
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
      final succeeded = await widget.volarezaService
          .cancelOrder(currentDay.date, currentDay.eatery);
      // if order cancellation fails, try to exchange the meal
      if (!succeeded) {
        _updateCredit(-_figureOutPriceForAMeal(currentDay, meal));
        await widget.volarezaService
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
          status: isOrdering ? MealStatus.ordered : MealStatus.available,
          alergens: m.alergens,
          group: m.group,
          price: m.price,
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

  double _figureOutPriceForAMeal(Day currentDay, Meal meal) {
    return meal.price;
  }

  void _handleError(dynamic error) {
    String errorMessage;
    bool canRetry = false;
    
    if (error is AppError) {
      errorMessage = error.userMessage;
      canRetry = error.canRetry;
    } else {
      // Fallback for any remaining non-AppError exceptions
      final appError = ErrorHandler.handleException(
        error is Exception ? error : Exception(error.toString()),
      );
      errorMessage = appError.userMessage;
      canRetry = appError.canRetry;
    }
    
    _showErrorSnackBar(errorMessage, canRetry: canRetry);
    setState(() {
      _error = errorMessage;
    });
  }

  void _showErrorSnackBar(String message, {bool canRetry = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: canRetry ? 5 : 3),
        action: canRetry
            ? SnackBarAction(
                label: 'Zkusit znovu',
                onPressed: () {
                  setState(() {
                    _error = null;
                  });
                  _fetchFacilityData();
                },
              )
            : null,
      ),
    );
  }

  Widget _buildContent() {
    return Stack(
      children: [
        if (_error != null)
          ErrorDisplay(error: _error!)
        else if (_facility != null)
          _buildPageView()
        else
          const LoadingIndicator(),
      ],
    );
  }

  Widget _buildPageView() {
    if (_facility == null || _facility!.calendar.isEmpty) {
      return const LoadingIndicator();
    }

    List<CalendarItem> calendarToUse =
        _showWeekends ? _facility!.calendar.cast<CalendarItem>() : _filteredCalendar;

    return PageView.builder(
      controller: _pageController,
      onPageChanged: _handlePageChange,
      itemCount: calendarToUse.length,
      itemBuilder: (context, index) {
        final calendarItem = calendarToUse[index];
        final currentDay = _loadedDays[calendarItem.date];

        return currentDay != null
            ? DayContent(
                currentDay: currentDay,
                mealTapped: _mealTapped,
                onMealTap: _handleMealTap,
                eateries: _facility?.eateries ?? [],
                onEateryChanged: (String? newValue) {
                  if (newValue == null) return;

                  final newEatery = _facility!.eateries
                      .firstWhere((eatery) => eatery.name == newValue)
                      .id;

                  setState(() {
                    _mealTapped.clear();
                  });

                  _fetchDayData(newEatery, currentDay.date);
                },
                onPreviousDay: () {
                  _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.fastEaseInToSlowEaseOut);
                },
                onNextDay: () {
                  _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.fastEaseInToSlowEaseOut);
                },
              )
            : const LoadingIndicator();
      },
    );
  }

  void _handleMealTap(Meal meal, Day currentDay) {
    final isTapped = _mealTapped[meal.id] ?? false;

    if (isTapped) {
      if (meal.status == MealStatus.ordered) {
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

  void _handlePageChange(int index) {
    if (!mounted || _facility == null) {
      return;
    }

    List<CalendarItem> calendarToUse =
        _showWeekends ? _facility!.calendar.cast<CalendarItem>() : _filteredCalendar;

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
}

