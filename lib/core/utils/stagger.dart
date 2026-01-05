import 'dart:async';
import 'package:flutter/material.dart';

class ProStagger extends StatefulWidget {
  final Widget child;
  final int delayMs;

  const ProStagger({
    super.key,
    required this.child,
    this.delayMs = 0,
  });

  @override
  State<ProStagger> createState() => _ProStaggerState();
}

class _ProStaggerState extends State<ProStagger> {
  bool _show = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(Duration(milliseconds: widget.delayMs), () {
      if (mounted) setState(() => _show = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, anim) {
        final fade = CurvedAnimation(parent: anim, curve: Curves.easeOut);
        final slide = Tween<Offset>(
          begin: const Offset(0, 0.06),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic));

        return FadeTransition(
          opacity: fade,
          child: SlideTransition(position: slide, child: child),
        );
      },
      child: _show ? widget.child : const SizedBox.shrink(),
    );
  }
}