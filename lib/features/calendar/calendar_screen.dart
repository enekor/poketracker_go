// lib/features/calendar/calendar_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:poketracker_go/features/calendar/calendar_service.dart';
import 'package:poketracker_go/features/calendar/calendar_widgets.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = Get.put(CalendarService());
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Eventos Pokémon GO',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list_rounded),
              onPressed: () => _showFilterSheet(context, service),
            ),
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: service.loadAll,
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(icon: Icon(Icons.event_rounded), text: 'Eventos'),
              Tab(icon: Icon(Icons.shield_rounded), text: 'Raids'),
              Tab(icon: Icon(Icons.egg_rounded), text: 'Huevos'),
              Tab(icon: Icon(Icons.assignment_rounded), text: 'Investigar'),
              Tab(icon: Icon(Icons.rocket_launch_rounded), text: 'Rocket'),
            ],
          ),
        ),
        body: Obx(() {
          if (service.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            children: [
              EventsTab(events: service.filteredEvents),
              RaidsTab(raids: service.raids),
              EggsTab(eggs: service.eggs),
              ResearchTab(tasks: service.research),
              RocketTab(members: service.rockets),
            ],
          );
        }),
      ),
    );
  }

  void _showFilterSheet(BuildContext context, CalendarService service) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Obx(() {
        final types = service.availableEventTypes;

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Filtrar eventos',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Desmarca los tipos que no quieras ver',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              if (types.isEmpty)
                const Text('Carga los eventos primero')
              else
                ...types.map((type) {
                  final isVisible =
                      !service.hiddenEventTypes.contains(type);
                  return CheckboxListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(type),
                    secondary: eventTypeIcon(type),
                    value: isVisible,
                    onChanged: (_) => service.toggleEventType(type),
                  );
                }),
              const SizedBox(height: 8),
            ],
          ),
        );
      }),
    );
  }
}
