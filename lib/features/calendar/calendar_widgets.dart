// lib/features/calendar/calendar_widgets.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:poketracker_go/features/calendar/calendar_service.dart';

// ─── Pokemon Type Colors ──────────────────────────────────

const _typeColors = <String, Color>{
  'normal': Color(0xFFA8A77A),
  'fire': Color(0xFFEE8130),
  'water': Color(0xFF6390F0),
  'electric': Color(0xFFF7D02C),
  'grass': Color(0xFF7AC74C),
  'ice': Color(0xFF96D9D6),
  'fighting': Color(0xFFC22E28),
  'poison': Color(0xFFA33EA1),
  'ground': Color(0xFFE2BF65),
  'flying': Color(0xFFA98FF3),
  'psychic': Color(0xFFF95587),
  'bug': Color(0xFFA6B91A),
  'rock': Color(0xFFB6A136),
  'ghost': Color(0xFF735797),
  'dragon': Color(0xFF6F35FC),
  'dark': Color(0xFF705746),
  'steel': Color(0xFFB7B7CE),
  'fairy': Color(0xFFD685AD),
};

// ─── Event type icon helper ───────────────────────────────

Widget eventTypeIcon(String type) {
  final (IconData icon, Color color) = switch (type.toLowerCase()) {
    'event' => (Icons.celebration_rounded, Colors.blue),
    'community day' => (Icons.groups_rounded, Colors.orange),
    'spotlight hour' => (Icons.lightbulb_rounded, Colors.purple),
    'raid' || 'raid day' || 'raid hour' => (Icons.shield_rounded, Colors.red),
    'research' => (Icons.assignment_rounded, Colors.teal),
    'go battle league' => (Icons.sports_mma_rounded, Colors.indigo),
    _ => (Icons.event_rounded, Colors.grey),
  };
  return Icon(icon, color: color, size: 22);
}

// ─── Shiny indicator ──────────────────────────────────────

Widget shinyBadge() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: Colors.amber.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(8),
    ),
    child: const Text('✨', style: TextStyle(fontSize: 10)),
  );
}

// ─── Events Tab ───────────────────────────────────────────

class EventsTab extends StatelessWidget {
  final List<PogoEvent> events;
  const EventsTab({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) return const _EmptyState(text: 'No hay eventos');

    final active = events.where((e) => e.isActive).toList();
    final upcoming = events.where((e) => e.isUpcoming).toList();
    final past = events.where((e) => !e.isActive && !e.isUpcoming).toList();

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        if (active.isNotEmpty) ...[
          _SectionHeader(title: 'Activos', color: Colors.green),
          ...active.map((e) => _EventCard(event: e)),
        ],
        if (upcoming.isNotEmpty) ...[
          _SectionHeader(title: 'Próximamente', color: Colors.blue),
          ...upcoming.map((e) => _EventCard(event: e)),
        ],
        if (past.isNotEmpty) ...[
          _SectionHeader(title: 'Finalizados', color: Colors.grey),
          ...past.map((e) => _EventCard(event: e)),
        ],
      ],
    );
  }
}

class _EventCard extends StatelessWidget {
  final PogoEvent event;
  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = event.isActive;

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isActive
            ? const BorderSide(color: Colors.green, width: 1.5)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: event.link.isNotEmpty
            ? () => launchUrl(Uri.parse(event.link),
                mode: LaunchMode.externalApplication)
            : null,
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (event.image.isNotEmpty)
            CachedNetworkImage(
              imageUrl: event.image,
              width: double.infinity,
              height: 140,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                height: 140,
                color: theme.colorScheme.surfaceContainerHighest,
              ),
              errorWidget: (_, __, ___) => const SizedBox.shrink(),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _EventTypeBadge(type: event.heading),
                    if (isActive) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'EN CURSO',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  event.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (event.start != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _formatDateRange(event.start!, event.end),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class _EventTypeBadge extends StatelessWidget {
  final String type;
  const _EventTypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final color = switch (type.toLowerCase()) {
      'event' => Colors.blue,
      'community day' => Colors.orange,
      'spotlight hour' => Colors.purple,
      'raid' || 'raid day' || 'raid hour' => Colors.red,
      'research' => Colors.teal,
      'go battle league' => Colors.indigo,
      _ => Colors.grey,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        type,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// ─── Raids Tab ────────────────────────────────────────────

class RaidsTab extends StatelessWidget {
  final List<RaidPokemon> raids;
  const RaidsTab({super.key, required this.raids});

  @override
  Widget build(BuildContext context) {
    if (raids.isEmpty) return const _EmptyState(text: 'No hay raids');

    final grouped = <String, List<RaidPokemon>>{};
    for (final raid in raids) {
      grouped.putIfAbsent(raid.tier, () => []).add(raid);
    }

    final tierOrder = [
      'Mega Raids',
      '5-Star Raids',
      '3-Star Raids',
      '1-Star Raids',
    ];

    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) {
        final ia = tierOrder.indexOf(a);
        final ib = tierOrder.indexOf(b);
        return (ia == -1 ? 99 : ia).compareTo(ib == -1 ? 99 : ib);
      });

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        for (final tier in sortedKeys) ...[
          _SectionHeader(
            title: tier,
            color: _tierColor(tier),
          ),
          ...grouped[tier]!.map((r) => _RaidCard(raid: r)),
        ],
      ],
    );
  }

  Color _tierColor(String tier) {
    return switch (tier) {
      'Mega Raids' => Colors.deepPurple,
      '5-Star Raids' => Colors.amber.shade700,
      '3-Star Raids' => Colors.orange,
      '1-Star Raids' => Colors.pink,
      _ => Colors.grey,
    };
  }
}

class _RaidCard extends StatelessWidget {
  final RaidPokemon raid;
  const _RaidCard({required this.raid});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CachedNetworkImage(
              imageUrl: raid.image,
              width: 56,
              height: 56,
              placeholder: (_, __) => const SizedBox(width: 56, height: 56),
              errorWidget: (_, __, ___) =>
                  const Icon(Icons.catching_pokemon, size: 56),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          raid.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (raid.canBeShiny) ...[
                        const SizedBox(width: 6),
                        shinyBadge(),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      for (final type in raid.types) ...[
                        _TypeChip(type: type),
                        const SizedBox(width: 4),
                      ],
                    ],
                  ),
                  if (raid.cpMin != null && raid.cpMax != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'CP: ${raid.cpMin} – ${raid.cpMax}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Eggs Tab ─────────────────────────────────────────────

class EggsTab extends StatelessWidget {
  final List<EggPokemon> eggs;
  const EggsTab({super.key, required this.eggs});

  @override
  Widget build(BuildContext context) {
    if (eggs.isEmpty) return const _EmptyState(text: 'No hay huevos');

    final grouped = <String, List<EggPokemon>>{};
    for (final egg in eggs) {
      grouped.putIfAbsent(egg.eggType, () => []).add(egg);
    }

    final distOrder = ['1 km', '2 km', '5 km', '7 km', '10 km', '12 km'];
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) {
        final ia = distOrder.indexOf(a);
        final ib = distOrder.indexOf(b);
        return (ia == -1 ? 99 : ia).compareTo(ib == -1 ? 99 : ib);
      });

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        for (final dist in sortedKeys) ...[
          _SectionHeader(title: dist, color: _eggColor(dist)),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: grouped[dist]!.map((e) => _EggChip(egg: e)).toList(),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Color _eggColor(String dist) {
    return switch (dist) {
      '1 km' => Colors.green,
      '2 km' => Colors.green.shade300,
      '5 km' => Colors.orange,
      '7 km' => Colors.yellow.shade700,
      '10 km' => Colors.purple,
      '12 km' => Colors.red,
      _ => Colors.grey,
    };
  }
}

class _EggChip extends StatelessWidget {
  final EggPokemon egg;
  const _EggChip({required this.egg});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CachedNetworkImage(
            imageUrl: egg.image,
            width: 28,
            height: 28,
            placeholder: (_, __) => const SizedBox(width: 28, height: 28),
            errorWidget: (_, __, ___) =>
                const Icon(Icons.catching_pokemon, size: 28),
          ),
          const SizedBox(width: 6),
          Text(
            egg.name,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          if (egg.canBeShiny) ...[
            const SizedBox(width: 4),
            shinyBadge(),
          ],
          if (egg.isRegional) ...[
            const SizedBox(width: 4),
            const Icon(Icons.public, size: 12, color: Colors.blue),
          ],
        ],
      ),
    );
  }
}

// ─── Research Tab ─────────────────────────────────────────

class ResearchTab extends StatelessWidget {
  final List<ResearchTask> tasks;
  const ResearchTab({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const _EmptyState(text: 'No hay investigaciones');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: tasks.length,
      itemBuilder: (context, index) => _ResearchCard(task: tasks[index]),
    );
  }
}

class _ResearchCard extends StatelessWidget {
  final ResearchTask task;
  const _ResearchCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.assignment_rounded,
                    size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    task.text,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: task.rewards
                  .map((r) => _RewardChip(reward: r))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _RewardChip extends StatelessWidget {
  final ResearchReward reward;
  const _RewardChip({required this.reward});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CachedNetworkImage(
            imageUrl: reward.image,
            width: 24,
            height: 24,
            placeholder: (_, __) => const SizedBox(width: 24, height: 24),
            errorWidget: (_, __, ___) =>
                const Icon(Icons.catching_pokemon, size: 24),
          ),
          const SizedBox(width: 6),
          Text(reward.name, style: theme.textTheme.bodySmall),
          if (reward.canBeShiny) ...[
            const SizedBox(width: 4),
            shinyBadge(),
          ],
        ],
      ),
    );
  }
}

// ─── Rocket Tab ───────────────────────────────────────────

class RocketTab extends StatelessWidget {
  final List<RocketMember> members;
  const RocketTab({super.key, required this.members});

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) {
      return const _EmptyState(text: 'No hay datos de Team Rocket');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: members.length,
      itemBuilder: (context, index) => _RocketCard(member: members[index]),
    );
  }
}

class _RocketCard extends StatelessWidget {
  final RocketMember member;
  const _RocketCard({required this.member});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person, size: 20),
                const SizedBox(width: 8),
                Text(
                  member.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  member.title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (member.type.isNotEmpty) ...[
                  const Spacer(),
                  _TypeChip(type: member.type),
                ],
              ],
            ),
            const SizedBox(height: 10),
            _RocketSlotRow(label: '1º', pokemon: member.firstPokemon),
            _RocketSlotRow(label: '2º', pokemon: member.secondPokemon),
            _RocketSlotRow(label: '3º', pokemon: member.thirdPokemon),
          ],
        ),
      ),
    );
  }
}

class _RocketSlotRow extends StatelessWidget {
  final String label;
  final List<RocketPokemon> pokemon;
  const _RocketSlotRow({required this.label, required this.pokemon});

  @override
  Widget build(BuildContext context) {
    if (pokemon.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              children: pokemon.map((p) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CachedNetworkImage(
                      imageUrl: p.image,
                      width: 24,
                      height: 24,
                      placeholder: (_, __) =>
                          const SizedBox(width: 24, height: 24),
                      errorWidget: (_, __, ___) =>
                          const Icon(Icons.catching_pokemon, size: 24),
                    ),
                    const SizedBox(width: 3),
                    Text(p.name, style: theme.textTheme.bodySmall),
                    if (p.canBeShiny) ...[
                      const SizedBox(width: 3),
                      shinyBadge(),
                    ],
                    if (p.isEncounter)
                      const Padding(
                        padding: EdgeInsets.only(left: 3),
                        child: Icon(Icons.catching_pokemon,
                            size: 12, color: Colors.red),
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared Widgets ───────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;
  const _SectionHeader({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 10),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String type;
  const _TypeChip({required this.type});

  @override
  Widget build(BuildContext context) {
    final color = _typeColors[type.toLowerCase()] ?? Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        type,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String text;
  const _EmptyState({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy_rounded,
              size: 64, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: 12),
          Text(text, style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }
}

// ─── Date formatting ──────────────────────────────────────

String _formatDateRange(DateTime start, DateTime? end) {
  final s = _formatDate(start);
  if (end == null) return s;
  final e = _formatDate(end);
  return '$s  →  $e';
}

String _formatDate(DateTime d) {
  final months = [
    'ene', 'feb', 'mar', 'abr', 'may', 'jun',
    'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
  ];
  final h = d.hour.toString().padLeft(2, '0');
  final m = d.minute.toString().padLeft(2, '0');
  return '${d.day} ${months[d.month - 1]} ${h}:${m}';
}
