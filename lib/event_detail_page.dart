import 'package:flutter/material.dart';
import 'database.dart';

class EventDetailPage extends StatelessWidget {
  final Event event;

  const EventDetailPage({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                event.subjectName ?? event.subtopic ?? 'Neznámý předmět',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primaryContainer,
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.school,
                    size: 80,
                    color: Colors.white70,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(context),
                  const SizedBox(height: 16),
                  _buildDetailsCard(context),
                  const SizedBox(height: 16),
                  _buildLocationCard(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Základní informace',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.access_time, 'Čas', '${event.startTime} - ${event.endTime}'),
            if (event.lessonOrder != null)
              _buildInfoRow(Icons.numbers, 'Hodina', '${event.lessonOrder}. vyučovací hodina'),
            if (event.lessonFormName != null && event.lessonFormName!.isNotEmpty)
              _buildInfoRow(Icons.category, 'Forma výuky', event.lessonFormName!),
            if (event.departmentName != null && event.departmentName!.isNotEmpty)
              _buildInfoRow(Icons.business, 'Katedra', event.departmentName!),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Podrobnosti',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (event.topic != null && event.topic!.isNotEmpty)
              _buildInfoRow(Icons.topic, 'Téma', event.topic!),
            if (event.subtopic != null && event.subtopic!.isNotEmpty)
              _buildInfoRow(Icons.subdirectory_arrow_right, 'Podtéma', event.subtopic!),
            _buildInfoRow(Icons.group, 'Skupiny', _formatGroups(event.groupNames)),
            _buildInfoRow(Icons.person_outline, 'Vyučující', _formatTeachers(event.teacherNames)),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Místo konání',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.location_on, 'Učebna', _formatClassrooms(event.classroomNames)),
            Container(
              margin: const EdgeInsets.only(top: 12),
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map, size: 40, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('Mapa učebny', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatClassrooms(String? classrooms) {
    if (classrooms == null || classrooms.isEmpty) return 'Neznámá učebna';
    if (classrooms.startsWith('[') && classrooms.endsWith(']')) {
      var cleaned = classrooms.substring(1, classrooms.length - 1);
      cleaned = cleaned.replaceAll('"', '').replaceAll(',', ', ');
      if (cleaned.isEmpty) return 'Neznámá učebna';
      return cleaned;
    }
    return classrooms;
  }

  String _formatTeachers(String? teachers) {
    if (teachers == null || teachers.isEmpty) return 'Neznámý učitel';
    if (teachers.startsWith('[') && teachers.endsWith(']')) {
      var cleaned = teachers.substring(1, teachers.length - 1);
      cleaned = cleaned.replaceAll('"', '').replaceAll(',', ', ');
      if (cleaned.isEmpty) return 'Neznámý učitel';
      return cleaned;
    }
    return teachers;
  }

  String _formatGroups(String? groups) {
    if (groups == null || groups.isEmpty) return 'Neznámá skupina';
    if (groups.startsWith('[') && groups.endsWith(']')) {
      var cleaned = groups.substring(1, groups.length - 1);
      cleaned = cleaned.replaceAll('"', '').replaceAll(',', ', ');
      if (cleaned.isEmpty) return 'Neznámá skupina';
      return cleaned;
    }
    return groups;
  }
}