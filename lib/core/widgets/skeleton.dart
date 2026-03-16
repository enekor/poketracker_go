// lib/core/widgets/skeleton.dart

import 'package:flutter/material.dart';

/// Shimmer animation wrapper. Wraps child with a sliding gradient effect.
class Shimmer extends StatefulWidget {
  final Widget child;

  const Shimmer({super.key, required this.child});

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                Color(0x33FFFFFF),
                Color(0x99FFFFFF),
                Color(0x33FFFFFF),
              ],
              stops: [
                (_controller.value - 0.3).clamp(0.0, 1.0),
                _controller.value,
                (_controller.value + 0.3).clamp(0.0, 1.0),
              ],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// A single skeleton bone (rounded rectangle placeholder).
class SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Skeleton grid that mimics the Pokédex grid while data loads.
class PokedexGridSkeleton extends StatelessWidget {
  const PokedexGridSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        slivers: [
          // Fake generation header
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: SkeletonBox(width: 140, height: 20, borderRadius: 6),
            ),
          ),
          // Fake grid tiles
          SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 0.85,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => const _SkeletonTile(),
              childCount: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonTile extends StatelessWidget {
  const _SkeletonTile();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(color: theme.colorScheme.surface),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SkeletonBox(width: 60, height: 60, borderRadius: 12),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 4),
              color: theme.colorScheme.onSurface.withValues(alpha: 0.03),
              child: Center(
                child: SkeletonBox(width: 50, height: 10, borderRadius: 4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton layout for the Pokémon detail screen.
class PokemonDetailSkeleton extends StatelessWidget {
  const PokemonDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final spriteSize = screenWidth * 0.65;

    return Shimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Sprite placeholder
            SkeletonBox(
              width: spriteSize,
              height: spriteSize,
              borderRadius: 24,
            ),
            const SizedBox(height: 16),
            // Name placeholder
            SkeletonBox(width: 200, height: 28, borderRadius: 8),
            const SizedBox(height: 12),
            // Type chips placeholder
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SkeletonBox(width: 70, height: 32, borderRadius: 16),
                const SizedBox(width: 8),
                SkeletonBox(width: 70, height: 32, borderRadius: 16),
              ],
            ),
            const SizedBox(height: 24),
            // Ownership toggle placeholder
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SkeletonBox(width: 100, height: 38, borderRadius: 20),
                const SizedBox(width: 12),
                SkeletonBox(width: 100, height: 38, borderRadius: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
