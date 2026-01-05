import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class ProShimmer extends StatefulWidget {
  final Widget child;
  final double radius;

  const ProShimmer({super.key, required this.child, this.radius = 16});

  @override
  State<ProShimmer> createState() => _ProShimmerState();
}

class _ProShimmerState extends State<ProShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? AppColors.cardDark : AppColors.card;
    final shimmer = isDark ? 0.18 : 0.35;
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.radius),
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          return Stack(
            fit: StackFit.passthrough,
            children: [
              widget.child,
              Positioned.fill(
                child: ShaderMask(
                  blendMode: BlendMode.srcATop,
                  shaderCallback: (rect) {
                    final t = _c.value;
                    return LinearGradient(
                      begin: Alignment(-1.0 - 0.2 + (t * 2.4), 0),
                      end: Alignment(-0.2 + (t * 2.4), 0),
                      colors: [
                        Colors.white.withValues(alpha: 0.0),
                        Colors.white.withValues(alpha: shimmer),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                      stops: const [0.25, 0.5, 0.75],
                    ).createShader(rect);
                  },
                  child: Container(color: base),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
