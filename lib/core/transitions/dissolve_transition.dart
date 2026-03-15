import 'package:flutter/material.dart';

/// Dissolve Transition — The "Gateway to Sanctum" navigation effect.
///
/// A cinematic dissolve where the outgoing page fades out while
/// slightly expanding (as if dissolving into the void), and the
/// incoming page fades in with a slight delay for overlap.
///
/// Performance: Uses only FadeTransition + ScaleTransition (both
/// composited layer operations), ensuring 60fps on all platforms.
///
/// Duration: 800ms total
///   - Outgoing: fade 0→1 over 0–60%, scale 1.0→1.05
///   - Incoming: fade 0→1 over 25–100% (overlap zone)
class DissolvePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  DissolvePageRoute({required this.page})
      : super(
          transitionDuration: const Duration(milliseconds: 800),
          reverseTransitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Incoming page: fade in with slight delay
            final incomingFade = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: const Interval(0.25, 1.0, curve: Curves.easeInOut),
              ),
            );

            // Outgoing page: scale up slightly as it dissolves
            final outgoingScale = Tween<double>(begin: 1.0, end: 1.05).animate(
              CurvedAnimation(
                parent: secondaryAnimation,
                curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
              ),
            );

            final outgoingFade = Tween<double>(begin: 1.0, end: 0.0).animate(
              CurvedAnimation(
                parent: secondaryAnimation,
                curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
              ),
            );

            // Apply outgoing transforms to child when this page is being replaced
            return FadeTransition(
              opacity: incomingFade,
              child: FadeTransition(
                opacity: outgoingFade,
                child: ScaleTransition(
                  scale: outgoingScale,
                  child: child,
                ),
              ),
            );
          },
        );
}
