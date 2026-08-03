import 'package:flutter/material.dart';
import 'package:praxis/common/style/design_tokens.dart';

class LegalDocumentPage extends StatelessWidget {
  const LegalDocumentPage({
    super.key,
    required this.title,
    required this.sections,
  });

  final String title;
  final List<LegalSection> sections;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      backgroundColor:
          isDark ? DesignTokens.backgroundDark : DesignTokens.backgroundLight,
      body: ListView.separated(
        padding: const EdgeInsets.all(DesignTokens.spacing6),
        itemCount: sections.length,
        separatorBuilder: (_, __) =>
            const SizedBox(height: DesignTokens.spacing5),
        itemBuilder: (context, index) {
          final section = sections[index];
          return Container(
            padding: const EdgeInsets.all(DesignTokens.spacing5),
            decoration: BoxDecoration(
              color: isDark ? DesignTokens.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  section.heading,
                  style: DesignTokens.textStyle(
                    fontSize: DesignTokens.fontSizeTitleMedium,
                    fontWeight: DesignTokens.fontWeightBold,
                    color: isDark
                        ? DesignTokens.onSurfaceDark
                        : DesignTokens.onSurfaceLight,
                  ),
                ),
                const SizedBox(height: DesignTokens.spacing3),
                Text(
                  section.body,
                  style: DesignTokens.textStyle(
                    color: isDark
                        ? DesignTokens.textSecondaryDark
                        : DesignTokens.textSecondaryLight,
                  ).copyWith(height: 1.6),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class LegalSection {
  const LegalSection({
    required this.heading,
    required this.body,
  });

  final String heading;
  final String body;
}
