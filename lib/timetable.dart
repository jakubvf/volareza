
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'database_provider.dart';
import 'database.dart';
import 'database_import.dart';

class TimetablePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final database = DatabaseProvider.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Rozvrh hodin'),
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
            child: Text('Nahrát databázi'),
          ),
          _buildTimetable(context),
        ],
      ),
    );
  }

  _buildTimetable(BuildContext context) {
    final database = DatabaseProvider.of(context);
    final events = database.eventsOfGroupOnDate('22-5KB', DateTime.now());

    return Expanded(
      child: FutureBuilder<List<Event>>(
        future: events,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Chyba: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Text('Žádné události pro dnešní den.');
          } else {
            final eventList = snapshot.data!;
            return ListView.builder(
              itemCount: eventList.length,
              itemBuilder: (context, index) {
                final event = eventList[index];
                return ListTile(
                  title: Text(event.subjectName ?? 'Neznámé téma'),
                  subtitle: Text('${event.startTime} - ${event.endTime}\n'
                      '${event.classroomNames ?? 'Neznámá učebna'}\n'
                      '${event.teacherNames ?? 'Neznámý učitel'}\n'
                      '${event.groupNames ?? 'Neznámá skupina'}'),
                  isThreeLine: true,
                );
              },
            );
          }
        },
      ),
    );
  }

}