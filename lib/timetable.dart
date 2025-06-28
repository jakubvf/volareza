
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:table_calendar/table_calendar.dart';
import 'database_provider.dart';
import 'database.dart';
import 'database_import.dart';
import 'event_detail_page.dart';

class TimetablePage extends StatefulWidget {
  @override
  _TimetablePageState createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  late DateTime selectedDate;
  late PageController pageController;
  Map<String, List<Event>> eventCache = {};

  DateTime _getNearestWeekday(DateTime date) {
    if (date.weekday <= 5) {
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
    selectedDate = _getNearestWeekday(DateTime.now());
    pageController = PageController(initialPage: 365);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final database = DatabaseProvider.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rozvrh hodin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              final today = _getNearestWeekday(DateTime.now());
              setState(() {
                selectedDate = today;
                final index = _getIndexFromWeekday(today);
                pageController.jumpToPage(
                  index
                );
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          TextButton(
            onPressed: () async {
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
          _buildWeekDaysRow(),
          Expanded(
            child: PageView.builder(
              controller: pageController,
              onPageChanged: (index) {
                setState(() {
                  selectedDate = _getWeekdayFromIndex(index);
                });
              },
              itemBuilder: (context, index) {
                final date = _getWeekdayFromIndex(index);
                return _buildTimetableForDate(context, date);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekDaysRow() {
    final startOfWeek = _getStartOfWeek(selectedDate);
    final weekDays = List.generate(5, (index) => startOfWeek.add(Duration(days: index)));
    
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: weekDays.map((day) {
          final isSelected = isSameDay(day, selectedDate);
          final isToday = isSameDay(day, DateTime.now());
          
          return Expanded(
            child: InkWell(
              onTap: () => _selectDate(day),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: isSelected 
                    ? Theme.of(context).colorScheme.primary
                    : (isToday ? Theme.of(context).colorScheme.primaryContainer : null),
                  borderRadius: BorderRadius.circular(12),
                  border: isToday && !isSelected 
                    ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
                    : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _getShortWeekday(day.weekday),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isSelected 
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      day.day.toString(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected 
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  DateTime _getStartOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  String _getShortWeekday(int weekday) {
    const shortWeekdays = ['Po', 'Út', 'St', 'Čt', 'Pá', 'So', 'Ne'];
    return shortWeekdays[weekday - 1];
  }

  DateTime _getWeekdayFromIndex(int index) {
    // Convert page index to weekday-only dates
    // Index 365 represents today (if it's a weekday) or the nearest weekday
    final baseDate = DateTime.now();
    final weekdayIndex = index - 365;
    
    if (weekdayIndex == 0) {
      return _getNearestWeekday(baseDate);
    }
    
    DateTime result = _getNearestWeekday(baseDate);
    int daysToAdd = weekdayIndex;
    
    while (daysToAdd != 0) {
      if (daysToAdd > 0) {
        result = result.add(const Duration(days: 1));
        if (result.weekday <= 5) { // Monday to Friday
          daysToAdd--;
        }
      } else {
        result = result.subtract(const Duration(days: 1));
        if (result.weekday <= 5) { // Monday to Friday
          daysToAdd++;
        }
      }
    }
    
    return result;
  }

  int _getIndexFromWeekday(DateTime date) {
    // Convert weekday date to page index
    final baseDate = _getNearestWeekday(DateTime.now());
    int index = 365;
    
    if (date.isBefore(baseDate)) {
      DateTime current = baseDate;
      while (!isSameDay(current, date)) {
        current = current.subtract(const Duration(days: 1));
        if (current.weekday <= 5) {
          index--;
        }
      }
    } else if (date.isAfter(baseDate)) {
      DateTime current = baseDate;
      while (!isSameDay(current, date)) {
        current = current.add(const Duration(days: 1));
        if (current.weekday <= 5) {
          index++;
        }
      }
    }
    
    return index;
  }

  void _selectDate(DateTime date) {
    setState(() {
      selectedDate = date;
      final index = _getIndexFromWeekday(date);
      pageController.jumpToPage(index);
    });
  }

  Widget _buildTimetableForDate(BuildContext context, DateTime date) {
    final database = DatabaseProvider.of(context);
    final dateKey = '${date.year}-${date.month}-${date.day}';
    
    // If we have cached data, use it immediately
    if (eventCache.containsKey(dateKey)) {
      final events = eventCache[dateKey]!;
      _preloadAdjacentDays(database, date);
      return _buildEventList(events);
    }
    
    // Otherwise fetch data and cache it
    return FutureBuilder<List<Event>>(
      future: database.eventsOfGroupOnDate('22-5KB', date),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Chyba: ${snapshot.error}'));
        } else {
          final events = snapshot.data ?? [];
          eventCache[dateKey] = events;
          _preloadAdjacentDays(database, date);
          return _buildEventList(events);
        }
      },
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
        return _buildEventCard(event);
      },
    );
  }

  void _preloadAdjacentDays(AppDatabase database, DateTime currentDate) async {
    final adjacentDays = [
      currentDate.subtract(const Duration(days: 1)),
      currentDate.add(const Duration(days: 1)),
    ];
    
    for (final date in adjacentDays) {
      final dateKey = '${date.year}-${date.month}-${date.day}';
      if (!eventCache.containsKey(dateKey)) {
        try {
          final events = await database.eventsOfGroupOnDate('22-5KB', date);
          eventCache[dateKey] = events;
        } catch (e) {
          // Ignore preload errors
        }
      }
    }
  }

  Widget _buildEventCard(Event event) {
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
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      event.lessonFormName!,
                      style: TextStyle(
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