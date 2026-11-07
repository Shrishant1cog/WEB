/// FFT Loading Skeletons
/// Modern skeleton loaders for better perceived performance

import 'package:flutter/material.dart';

import '../themes/design_tokens.dart';

/// Base shimmer widget
class FFTShimmer extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const FFTShimmer({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<FFTShimmer> createState() => _FFTShimmerState();
}

class _FFTShimmerState extends State<FFTShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark
        ? const Color(0xFF2D3A4E)
        : const Color(0xFFE2E8F0);
    final highlightColor = isDark
        ? const Color(0xFF3D4A5E)
        : const Color(0xFFF1F5F9);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(-1.0 - _animation.value * 2, 0),
              end: Alignment(1.0 + _animation.value * 2, 0),
              colors: [
                baseColor,
                Color.lerp(baseColor, highlightColor, _animation.value)!,
                baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
    );
  }
}

/// Skeleton for tournament card
class FFTTournamentCardSkeleton extends StatelessWidget {
  final bool isCompact;

  const FFTTournamentCardSkeleton({
    super.key,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final skeletonColor = isDark
        ? const Color(0xFF2D3A4E)
        : const Color(0xFFE2E8F0);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Header skeleton
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: FFTShimmer(
                    child: Container(
                      height: 20,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: skeletonColor,
                        borderRadius: BorderRadius.circular(Radii.sm),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs),
                  decoration: BoxDecoration(
                    color: skeletonColor,
                    borderRadius: BorderRadius.circular(Radii.round),
                  ),
                  child: const SizedBox(width: 60, height: 16),
                ),
              ],
            ),

            const SizedBox(height: Spacing.sm),

            // Meta row skeleton
            FFTShimmer(
              child: Container(
                height: 14,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: skeletonColor,
                  borderRadius: BorderRadius.circular(Radii.xs),
                ),
              ),
            ),

            const SizedBox(height: Spacing.sm),

            // Info row skeleton
            Row(
              children: <Widget>[
                Expanded(
                  child: FFTShimmer(
                    child: Container(
                      height: 14,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: skeletonColor,
                        borderRadius: BorderRadius.circular(Radii.xs),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: Spacing.lg),
                FFTShimmer(
                  child: Container(
                    width: 80,
                    height: 14,
                    decoration: BoxDecoration(
                      color: skeletonColor,
                      borderRadius: BorderRadius.circular(Radii.xs),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: Spacing.sm),

            // Badges skeleton
            Row(
              children: <Widget>[
                FFTShimmer(
                  child: Container(
                    width: 50,
                    height: 24,
                    decoration: BoxDecoration(
                      color: skeletonColor,
                      borderRadius: BorderRadius.circular(Radii.round),
                    ),
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                FFTShimmer(
                  child: Container(
                    width: 80,
                    height: 24,
                    decoration: BoxDecoration(
                      color: skeletonColor,
                      borderRadius: BorderRadius.circular(Radii.round),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for tournament list
class FFTTournamentListSkeleton extends StatelessWidget {
  final int itemCount;
  final bool isCompact;

  const FFTTournamentListSkeleton({
    super.key,
    this.itemCount = 5,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(Spacing.md),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: Spacing.sm),
      itemBuilder: (context, index) => FFTTournamentCardSkeleton(isCompact: isCompact),
    );
  }
}

/// Generic skeleton builder
class FFTSkeletonBuilder extends StatelessWidget {
  final Widget child;
  final bool isLoading;

  const FFTSkeletonBuilder({
    super.key,
    required this.child,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return child;

    return FFTSkeleton.fromWidget(child);
  }
}

/// Skeleton factory from existing widget
class FFTSkeleton {
  const FFTSkeleton._();

  static Widget fromWidget(Widget widget) {
    if (widget is Text) {
      return _textSkeleton(widget);
    }
    if (widget is Container) {
      return _containerSkeleton(widget);
    }
    if (widget is Card) {
      return _cardSkeleton(widget);
    }
    if (widget is Row) {
      return _rowSkeleton(widget);
    }
    if (widget is Column) {
      return _columnSkeleton(widget);
    }
    if (widget is Icon) {
      return _iconSkeleton(widget);
    }
    if (widget is ListView) {
      return FFTTournamentListSkeleton();
    }
    if (widget is ListTile) {
      return _listTileSkeleton(widget);
    }
    return _genericSkeleton(widget);
  }

  static Widget _textSkeleton(Text widget) {
    final style = widget.style ?? const TextStyle();
    final lines = (widget.maxLines ?? 1).clamp(1, 3);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(lines, (i) => Padding(
        padding: EdgeInsets.only(bottom: i == lines - 1 ? 0 : Spacing.xs),
        child: FFTShimmer(
          child: Container(
            height: style.fontSize?.toDouble() ?? 14,
            width: double.infinity,
            decoration: BoxDecoration(
              color: _skeletonBaseColor,
              borderRadius: BorderRadius.circular(Radii.xs),
            ),
          ),
        ),
      )),
    );
  }

  static Widget _containerSkeleton(Container widget) {
    return FFTShimmer(
      child: Container(
        width: widget.constraints?.maxWidth ?? double.infinity,
        height: widget.constraints?.maxHeight,
        decoration: BoxDecoration(
          color: _skeletonBaseColor,
          borderRadius: widget.decoration is BoxDecoration
              ? (widget.decoration as BoxDecoration).borderRadius ?? BorderRadius.zero
              : BorderRadius.zero,
        ),
      ),
    );
  }

  static Widget _cardSkeleton(Card widget) {
    return FFTShimmer(
      child: Card(
        child: Container(
          decoration: BoxDecoration(
            color: _skeletonBaseColor,
            borderRadius: BorderRadius.circular(Radii.md),
          ),
        ),
      ),
    );
  }

  static Widget _rowSkeleton(Row widget) {
    return Row(
      mainAxisAlignment: widget.mainAxisAlignment,
      crossAxisAlignment: widget.crossAxisAlignment,
      children: widget.children.map((child) => Expanded(child: fromWidget(child))).toList(),
    );
  }

  static Widget _columnSkeleton(Column widget) {
    return Column(
      mainAxisAlignment: widget.mainAxisAlignment,
      crossAxisAlignment: widget.crossAxisAlignment,
      children: widget.children.map((child) => fromWidget(child)).toList(),
    );
  }

  static Widget _iconSkeleton(Icon widget) {
    return FFTShimmer(
      child: Container(
        width: widget.size ?? IconSizes.md,
        height: widget.size ?? IconSizes.md,
        decoration: BoxDecoration(
          color: _skeletonBaseColor,
          borderRadius: BorderRadius.circular(Radii.round),
        ),
      ),
    );
  }

  static Widget _listTileSkeleton(ListTile widget) {
    return ListTile(
      leading: widget.leading != null ? fromWidget(widget.leading!) : null,
      title: widget.title != null ? fromWidget(widget.title!) : null,
      subtitle: widget.subtitle != null ? fromWidget(widget.subtitle!) : null,
      trailing: widget.trailing != null ? fromWidget(widget.trailing!) : null,
      contentPadding: widget.contentPadding,
    );
  }

  static Widget _genericSkeleton(Widget widget) {
    return FFTShimmer(
      child: Container(
        color: _skeletonBaseColor,
      ),
    );
  }

  static Color get _skeletonBaseColor {
    // This will be resolved at runtime based on theme
    return Colors.grey[300]!;
  }
}