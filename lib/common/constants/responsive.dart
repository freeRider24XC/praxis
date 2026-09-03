import 'package:flutter/material.dart';
import 'breakpoints.dart';

/// A responsive grid that switches column count by breakpoint.
///
/// Example:
///   ResponsiveGrid(
///     columns: const BreakpointColumns(mobile: 1, tablet: 2, desktop: 3),
///     children: myWidgets,
///   )
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.columns,
    required this.children,
    this.rowSpacing = 12,
    this.colSpacing = 12,
    this.padding,
  });

  final BreakpointColumns columns;
  final List<Widget> children;
  final double rowSpacing;
  final double colSpacing;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final bp = Breakpoint.of(context);
    final cols = columns.columnCount(bp);
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Wrap(
        spacing: colSpacing,
        runSpacing: rowSpacing,
        children: children.map((child) {
          final available = (MediaQuery.sizeOf(context).width -
            (padding?.horizontal ?? 0) -
            (colSpacing * (cols - 1))) / cols;
          return SizedBox(
            width: available,
            child: child,
          );
        }).toList(),
      ),
    );
  }
}

/// Adapts a single child based on the current breakpoint.
/// Use for refactoring pages that currently have branching MediaQuery
/// with hard-coded pixel values.
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  final Widget Function(BuildContext context, Breakpoint bp) builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return builder(context, Breakpoint.of(context));
      },
    );
  }
}
