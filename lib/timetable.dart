
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'database_provider.dart';
import 'database.dart';
import 'database_import.dart';
import 'event_detail_page.dart';

class TimetablePage extends StatefulWidget {
  @override
  _TimetablePageState createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  DateTime selectedDate = DateTime.now();
  PageController pageController = PageController(initialPage: 365);

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
              setState(() {
                selectedDate = DateTime.now();
                pageController.animateToPage(
                  365,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
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
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              _formatDate(selectedDate),
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: pageController,
              onPageChanged: (index) {
                setState(() {
                  selectedDate = DateTime.now().add(Duration(days: index - 365));
                });
              },
              itemBuilder: (context, index) {
                final date = DateTime.now().add(Duration(days: index - 365));
                return _buildTimetableForDate(context, date);
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final weekdays = ['Pondělí', 'Úterý', 'Středa', 'Čtvrtek', 'Pátek', 'Sobota', 'Neděle'];
    final months = ['ledna', 'února', 'března', 'dubna', 'května', 'června',
                   'července', 'srpna', 'září', 'října', 'listopadu', 'prosince'];
    
    return '${weekdays[date.weekday - 1]}, ${date.day}. ${months[date.month - 1]} ${date.year}';
  }

  Widget _buildTimetableForDate(BuildContext context, DateTime date) {
    final database = DatabaseProvider.of(context);
    final events = database.eventsOfGroupOnDate('22-5KB', date);

    return FutureBuilder<List<Event>>(
        future: events,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Chyba: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Žádné události pro dnešní den.'));
          } else {
            final eventList = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: eventList.length,
              itemBuilder: (context, index) {
                final event = eventList[index];
                return _buildEventCard(event);
              },
            );
          }
        },
    );
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
                    _formatClassrooms(event.classroomNames),
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
                    _formatTeachers(event.teacherNames),
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

  String _formatClassrooms(String? classrooms) {
    if (classrooms == null || classrooms.isEmpty) return 'Neznámá učebna';
    if (classrooms.startsWith('[') && classrooms.endsWith(']')) {
      var cleaned = classrooms.substring(1, classrooms.length - 1);
      cleaned = cleaned.replaceAll('"', '').replaceAll(',', ', ');

      if (cleaned.isEmpty) {
        return 'Neznámá učebna';
      }
      return cleaned;
    }
    return classrooms;
  }

  String _formatTeachers(String? teachers) {
    if (teachers == null || teachers.isEmpty) return 'Neznámý učitel';
    if (teachers.startsWith('[') && teachers.endsWith(']')) {
      var cleaned = teachers.substring(1, teachers.length - 1);
      cleaned = cleaned.replaceAll('"', '').replaceAll(',', ', ');

      if (cleaned.isEmpty) {
        return 'Neznámý učitel';
      }
      return cleaned;
    }
    return teachers;
  }

}