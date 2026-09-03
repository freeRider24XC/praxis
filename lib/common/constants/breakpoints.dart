import 'package:flutter/material.dart';

/// Unified responsive breakpoints for Praxis.
///
/// Layout philosophy:
/// - < mobile   : rare; legacy small devices
/// - mobile     : phone  (< 600)
/// - tablet     : tablet (600–839)
/// - desktop    : desktop (840–1199)
/// - wide       : wide desktop (≥ 1200)
///
/// Usage:
///   final bp = Breakpoint.of(context);
///   if (bp.isMobile) { ... }
///   if (bp.isAtLeast(Breakpoint.tablet)) { ... }
enum Breakpoint {
  mobile,
  tablet,
  desktop,
  wide;

  static const double mobileMax = 599;
  static const double tabletMax = 839;
  static const double desktopMax = 1199;

  /// Current breakpoint from MediaQuery width.
  static Breakpoint of(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w < 600) return mobile;
    if (w < 840) return tablet;
    if (w < 1200) return desktop;
    return wide;
  }

  bool get isMobile => this == mobile;
  bool get isTablet => this == tablet;
  bool get isDesktop => this == desktop;
  bool get isWide => this == wide;

  /// True when this breakpoint is at least [other].
  bool isAtLeast(Breakpoint other) => index >= other.index;

  /// True when this breakpoint is at most [other].
  bool isAtMost(Breakpoint other) => index <= other.index;

  @override
  String toString() => 'Breakpoint.$name';
}

/// Grid column counts per breakpoint.
class BreakpointColumns {
  const BreakpointColumns({required this.mobile, this.tablet, this.desktop, this.wide});
  final int mobile;
  final int? tablet;
  final int? desktop;
  final int? wide;

  int columnCount(Breakpoint bp) {
    switch (bp) {
      case Breakpoint.mobile: return mobile;
      case Breakpoint.tablet: return tablet ?? mobile;
      case Breakpoint.desktop: return desktop ?? tablet ?? mobile;
      case Breakpoint.wide: return wide ?? desktop ?? tablet ?? mobile;
    }
  }
}
