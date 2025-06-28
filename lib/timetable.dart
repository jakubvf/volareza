import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'database_provider.dart';
import 'database.dart';
import 'event_detail_page.dart';
import 'database_import.dart';

class TimetablePage extends StatefulWidget {
  static const String defaultGroupId = '22-5KB';
  
  const TimetablePage({super.key});

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  late final ValueNotifier<List<Event>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.week;
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  Map<DateTime, List<Event>> _events = {};
  
  static const int _weekdaysOnly = 5;
  static const Duration _dayDuration = Duration(days: 1);
  static const Duration _weekDuration = Duration(days: 4);

  DateTime _getNearestWeekday(DateTime date) {
    if (date.weekday <= _weekdaysOnly) {
      return date;
    } else if (date.weekday == 6) { // Saturday
      return date.add(const Duration(days: 2)); // Move to Monday
    } else { // Sunday
      return date.add(const Duration(days: 1)); // Move to Monday
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = _getNearestWeekday(DateTime.now());
    _focusedDay = _selectedDay!;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadEvents();
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    // Only load events for the current week initially for better performance
    final startOfWeek = _getStartOfWeek(_selectedDay!);
    final endOfWeek = startOfWeek.add(_weekDuration); // Monday to Friday
    
    final eventsMap = await _loadEventsForDateRange(startOfWeek, endOfWeek);
    
    setState(() {
      _events = eventsMap;
      _selectedEvents.value = _getEventsForDay(_selectedDay!);
    });
  }

  List<Event> _getEventsForDay(DateTime day) {
    final dateKey = DateTime(day.year, day.month, day.day);
    return _events[dateKey] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rozvrh hodin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_view_month),
            onPressed: () {
              setState(() {
                _calendarFormat = _calendarFormat == CalendarFormat.week 
                    ? CalendarFormat.month 
                    : CalendarFormat.week;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              final today = _getNearestWeekday(DateTime.now());
              setState(() {
                _focusedDay = today;
                _selectedDay = today;
                _selectedEvents.value = _getEventsForDay(_selectedDay!);
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          TextButton(
            onPressed: () async {
              final database = DatabaseProvider.of(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Načítání databáze...')),
              );
              
              try {
                await DatabaseImporter.importFromAssets(database);
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Databáze byla úspěšně nahrána!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Chyba při načítání databáze: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Nahrát databázi'),
          ),
          _buildCalendarView(),
        ],
      ),
    );
  }


  Widget _buildCalendarView() {
    return Expanded(
      child: Column(
        children: [
          TableCalendar<Event>(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2026, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            calendarFormat: _calendarFormat,
            eventLoader: _getEventsForDay,
            startingDayOfWeek: StartingDayOfWeek.monday,
            availableCalendarFormats: const {
              CalendarFormat.month: 'Týden',
              CalendarFormat.week: 'Měsíc',
            },
            calendarStyle: const CalendarStyle(
              outsideDaysVisible: false,
              weekendTextStyle: TextStyle(color: Colors.red),
              holidayTextStyle: TextStyle(color: Colors.red),
              selectedDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
            daysOfWeekVisible: true,
            sixWeekMonthsEnforced: false,
            availableGestures: AvailableGestures.all,
            enabledDayPredicate: (day) {
              return _calendarFormat == CalendarFormat.month ? true : day.weekday <= 5;
            },
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay) && 
                  selectedDay.weekday <= _weekdaysOnly) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                  _selectedEvents.value = _getEventsForDay(selectedDay);
                });
              }
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
              _loadEventsForWeek(focusedDay);
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, events) {
                if (events.isNotEmpty) {
                  return Positioned(
                    right: 1,
                    bottom: 1,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      child: Center(
                        child: Text(
                          '${events.length}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: ValueListenableBuilder<List<Event>>(
              valueListenable: _selectedEvents,
              builder: (context, value, _) {
                return _buildSwipeableEventList(value);
              },
            ),
          ),
        ],
      ),
    );
  }

  DateTime _getStartOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  Future<Map<DateTime, List<Event>>> _loadEventsForDateRange(DateTime startDate, DateTime endDate) async {
    final database = DatabaseProvider.of(context);
    final eventsMap = <DateTime, List<Event>>{};
    
    for (DateTime date = startDate; date.isBefore(endDate.add(_dayDuration)); date = date.add(_dayDuration)) {
      if (date.weekday <= _weekdaysOnly) {
        try {
          final dbEvents = await database.eventsOfGroupOnDate(TimetablePage.defaultGroupId, date);
          if (dbEvents.isNotEmpty) {
            final dateKey = DateTime(date.year, date.month, date.day);
            eventsMap[dateKey] = dbEvents;
          }
        } catch (e) {
          debugPrint('Error loading events for $date: $e');
        }
      }
    }
    
    return eventsMap;
  }


  Widget _buildSwipeableEventList(List<Event> events) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity == null) return;
        
        final velocity = details.primaryVelocity!;
        const double sensitivity = 300.0;
        
        if (velocity > sensitivity) {
          _navigateToDay(-1);
        } else if (velocity < -sensitivity) {
          _navigateToDay(1);
        }
      },
      child: _buildEventList(events),
    );
  }

  Widget _buildEventList(List<Event> events) {
    if (events.isEmpty) {
      return const Center(child: Text('Žádné události pro dnešní den.'));
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return _buildTimetableEventCard(event);
      },
    );
  }

  void _navigateToDay(int direction) {
    if (_selectedDay == null) return;
    
    DateTime newDay = _selectedDay!.add(Duration(days: direction));
    
    // Skip weekends - continue in the same direction
    while (newDay.weekday > _weekdaysOnly) {
      newDay = newDay.add(Duration(days: direction));
    }
    
    setState(() {
      _selectedDay = newDay;
      _focusedDay = newDay;
      _selectedEvents.value = _getEventsForDay(newDay);
    });
    
    _loadEventsForWeek(newDay);
  }

  Future<void> _loadEventsForWeek(DateTime focusedDay) async {
    final startOfWeek = _getStartOfWeek(focusedDay);
    final endOfWeek = startOfWeek.add(_weekDuration);
    
    final eventsMap = await _loadEventsForDateRange(startOfWeek, endOfWeek);
    
    setState(() {
      _events.addAll(eventsMap);
    });
  }

  Widget _buildTimetableEventCard(Event event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventDetailPage(event: event),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${event.startTime} - ${event.endTime}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (event.lessonFormName != null && event.lessonFormName!.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        event.lessonFormName!,
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Text(
                event.subjectName ?? event.subtopic ?? 'Neznámý předmět',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (event.topic != null && event.topic!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  event.topic!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      formatClassrooms(event.classroomNames),
                      style: TextStyle(color: Colors.grey.shade700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      formatTeachers(event.teacherNames),
                      style: TextStyle(color: Colors.grey.shade700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

}