import 'dart:ui';
import 'package:flutter/material.dart';

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
  final Color color;
  final VoidCallback onTap;

  const HubTile({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon,
    this.iconWidget,
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
                      child: widget.iconWidget ??
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
