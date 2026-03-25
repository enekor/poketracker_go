import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:poketracker_go/app/routes/app_routes.dart';
import 'package:poketracker_go/features/calendar/calendar_service.dart';
import 'package:poketracker_go/features/calendar/calendar_widgets.dart';
import 'package:poketracker_go/features/home/home_service.dart';

class PokeballBackground extends StatelessWidget {
  const PokeballBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.brightness == Brightness.dark
        ? Colors.white.withOpacity(0.03)
        : theme.colorScheme.primary.withOpacity(0.03);

    return Positioned(
      top: -100,
      right: -100,
      child: IgnorePointer(
        child: CustomPaint(
          size: const Size(400, 400),
          painter: _PokeballPainter(color: color),
        ),
      ),
    );
  }
}

class _PokeballPainter extends CustomPainter {
  final Color color;
  _PokeballPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 40;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    canvas.drawCircle(center, radius, paint);
    canvas.drawLine(Offset(0, center.dy), Offset(size.width, center.dy), paint);

    final centerPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 60, centerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;

  const GlassCard({super.key, required this.child, this.borderRadius = 24});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.white.withOpacity(0.4),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : theme.colorScheme.primary.withOpacity(0.15),
              width: 1.5,
            ),
            boxShadow: isDark
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class HubTile extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData? icon;
  final Widget? iconWidget;
  final Widget? backgroundWidget;
  final Color color;
  final VoidCallback onTap;

  const HubTile({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon,
    this.iconWidget,
    this.backgroundWidget,
    required this.color,
    required this.onTap,
  });

  @override
  State<HubTile> createState() => _HubTileState();
}

class _HubTileState extends State<HubTile> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          height: 160,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: theme.brightness == Brightness.light
                ? Border.all(color: widget.color.withOpacity(0.08), width: 1.5)
                : null,
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(
                  theme.brightness == Brightness.dark ? 0.15 : 0.08,
                ),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              if (widget.icon != null)
                Positioned(
                  right: -15,
                  bottom: -15,
                  child: Icon(
                    widget.icon,
                    size: 100,
                    color: widget.color.withOpacity(0.08),
                  ),
                )
              else if (widget.backgroundWidget != null)
                Positioned(
                  right: -15,
                  bottom: -15,
                  child: Opacity(
                    opacity: 0.12,
                    child: SizedBox(
                      width: 100,
                      height: 100,
                      child: widget.backgroundWidget!,
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: widget.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child:
                          widget.iconWidget ??
                          Icon(widget.icon, color: widget.color, size: 28),
                    ),
                    const Spacer(),
                    Text(
                      widget.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      widget.subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Home Carousel (Events <-> Pokédex Summary) ──────────

class HomeCarousel extends StatefulWidget {
  final HomeService service;
  const HomeCarousel({super.key, required this.service});

  @override
  State<HomeCarousel> createState() => _HomeCarouselState();
}

class _HomeCarouselState extends State<HomeCarousel> {
  int _currentIndex = 0;
  double _dragStartX = 0;

  void _goToPage(int page) {
    setState(() => _currentIndex = page.clamp(0, 1));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final service = widget.service;

    final pages = [
      // Page 0: Active Events + Missing Pokemon
      _CarouselPage(
        key: const ValueKey(0),
        swipeHintAlignment: Alignment.centerRight,
        child: Obx(
          () => _EventsPage(
            events: service.activeEvents,
            isLoading: service.isLoadingEvents.value,
            missingPokemon: service.missingPokemon,
            isLoadingMissing: service.isLoadingMissing.value,
            onTap: () => Get.toNamed(AppRoutes.calendar),
          ),
        ),
      ),

      // Page 1: Pokédex Summary
      _CarouselPage(
        key: const ValueKey(1),
        swipeHintAlignment: Alignment.centerLeft,
        child: Obx(
          () => _PokedexSummaryPage(
            totalOwned: service.totalOwned.value,
            totalShiny: service.totalShiny.value,
            totalPokemon: service.totalPokemon,
          ),
        ),
      ),
    ];

    return Column(
      children: [
        GestureDetector(
          onHorizontalDragStart: (d) => _dragStartX = d.globalPosition.dx,
          onHorizontalDragEnd: (d) {
            final delta = d.globalPosition.dx - _dragStartX;
            if (delta < -50)
              _goToPage(_currentIndex + 1);
            else if (delta > 50)
              _goToPage(_currentIndex - 1);
          },
          child: AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: pages[_currentIndex],
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Page indicator dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(2, (i) {
            final isActive = i == _currentIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? 20 : 8,
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: isActive
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withOpacity(0.2),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _CarouselPage extends StatelessWidget {
  final Widget child;
  final Alignment swipeHintAlignment;

  const _CarouselPage({
    super.key,
    required this.child,
    required this.swipeHintAlignment,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLeft = swipeHintAlignment == Alignment.centerLeft;

    return Stack(children: [child]);
  }
}

class _EventsPage extends StatelessWidget {
  final List<PogoEvent> events;
  final bool isLoading;
  final List<MissingPokemon> missingPokemon;
  final bool isLoadingMissing;
  final VoidCallback? onTap;

  const _EventsPage({
    required this.events,
    required this.isLoading,
    required this.missingPokemon,
    required this.isLoadingMissing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasMissing = missingPokemon.isNotEmpty || isLoadingMissing;

    return GlassCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Icon(
                    Icons.event_rounded,
                    size: 18,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'HOY EN POKÉMON GO',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Events list
              if (isLoading)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              else if (events.isEmpty && !hasMissing)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline_rounded,
                          size: 20,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'No hay eventos importantes hoy',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else ...[
                // Events
                if (events.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        'Sin eventos activos',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  )
                else
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 120),
                    child: ListView(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      children: events
                          .map((event) => _ActiveEventRow(event: event))
                          .toList(),
                    ),
                  ),

                // Missing Pokemon section
                if (hasMissing) ...[
                  Divider(
                    height: 1,
                    color: theme.colorScheme.onSurface.withOpacity(0.08),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.catching_pokemon,
                        size: 14,
                        color: Colors.red.withOpacity(0.7),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'TE FALTAN',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                          fontSize: 9,
                          color: theme.colorScheme.onSurface.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (isLoadingMissing)
                    const SizedBox(
                      height: 48,
                      child: Center(
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      height: 56,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: missingPokemon.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) =>
                            _MissingPokemonTile(pokemon: missingPokemon[index]),
                      ),
                    ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PokedexSummaryPage extends StatelessWidget {
  final int totalOwned;
  final int totalShiny;
  final int totalPokemon;

  const _PokedexSummaryPage({
    required this.totalOwned,
    required this.totalShiny,
    required this.totalPokemon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatItem(
                  label: 'NORMAL',
                  count: totalOwned,
                  total: totalPokemon,
                  icon: Icons.catching_pokemon,
                  color: theme.colorScheme.primary,
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: theme.colorScheme.onSurface.withOpacity(0.1),
                ),
                _StatItem(
                  label: 'SHINY',
                  count: totalShiny,
                  total: totalPokemon,
                  icon: Icons.auto_awesome,
                  color: theme.colorScheme.secondary,
                ),
              ],
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: totalOwned / totalPokemon,
                minHeight: 12,
                backgroundColor: theme.colorScheme.onSurface.withOpacity(0.05),
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.count,
    required this.total,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '$count / $total',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

// ─── Active Event Row ─────────────────────────────────────

class _ActiveEventRow extends StatelessWidget {
  final PogoEvent event;
  const _ActiveEventRow({required this.event});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          if (event.image.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: event.image,
                width: 48,
                height: 32,
                fit: BoxFit.cover,
                placeholder: (_, __) => SizedBox(
                  width: 48,
                  height: 32,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                errorWidget: (_, __, ___) =>
                    const SizedBox(width: 48, height: 32),
              ),
            )
          else
            eventTypeIcon(event.heading),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.name,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  event.heading,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'EN CURSO',
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Missing Pokemon Tile ─────────────────────────────────

class _MissingPokemonTile extends StatelessWidget {
  final MissingPokemon pokemon;
  const _MissingPokemonTile({required this.pokemon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            CachedNetworkImage(
              imageUrl: pokemon.image,
              width: 40,
              height: 40,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.none,
              placeholder: (_, __) => const SizedBox(width: 40, height: 40),
              errorWidget: (_, __, ___) =>
                  const Icon(Icons.catching_pokemon, size: 40),
            ),
            if (pokemon.isShiny)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    size: 12,
                    color: Colors.amber,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 48,
          child: Text(
            pokemon.name,
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: 8,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
