import 'package:flutter/material.dart';
import 'package:praxis/common/models/index.dart';
import 'package:praxis/common/services/index.dart';
import 'package:praxis/common/style/design_tokens.dart';

class DomainsPage extends StatefulWidget {
  const DomainsPage({super.key});

  @override
  State<DomainsPage> createState() => _DomainsPageState();
}

class _DomainsPageState extends State<DomainsPage> {
  late List<LifeDomain> _domains;
  String? _focusedDomainId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final profile = ProfileService.getProfile();
    setState(() {
      _domains = DomainService.getDomains();
      _focusedDomainId = profile.focusedDomainId;
    });
  }

  Future<void> _setFocusedDomain(String domainId) async {
    await DomainService.setFocusedDomain(domainId);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark
          ? DesignTokens.backgroundDark
          : DesignTokens.backgroundLight,
      body: ListView(
        padding: const EdgeInsets.all(DesignTokens.spacing6),
        children: [
          Text(
            '人生领域',
            style: DesignTokens.textStyle(
              fontSize: DesignTokens.fontSizeHeadlineSmall,
              fontWeight: DesignTokens.fontWeightBold,
              color: isDark
                  ? DesignTokens.onSurfaceDark
                  : DesignTokens.onSurfaceLight,
            ),
          ),
          const SizedBox(height: DesignTokens.spacing2),
          Text(
            '先盯住一个当前重点方向，把这一周推进顺。',
            style: DesignTokens.textStyle(
              color: isDark
                  ? DesignTokens.textSecondaryDark
                  : DesignTokens.textSecondaryLight,
            ),
          ),
          const SizedBox(height: DesignTokens.spacing5),
          ..._domains.map((domain) {
            final isFocused = domain.id == _focusedDomainId;
            final todoCount = DatabaseService.getTodosByDomain(domain.id).length;
            final goalCount = DatabaseService.getGoalsByDomain(domain.id).length;
            return Container(
              margin: const EdgeInsets.only(bottom: DesignTokens.spacing4),
              decoration: BoxDecoration(
                color: isDark ? DesignTokens.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
                border: Border.all(
                  color: isFocused
                      ? DesignTokens.primaryColor
                      : (isDark
                          ? DesignTokens.borderDark
                          : DesignTokens.borderLight),
                  width: isFocused ? 2 : 1,
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(DesignTokens.spacing4),
                leading: Text(domain.icon, style: const TextStyle(fontSize: 28)),
                title: Text(domain.name),
                subtitle: Text('$goalCount 个目标 · $todoCount 个任务'),
                trailing: isFocused
                    ? const Icon(Icons.check_circle, color: DesignTokens.primaryColor)
                    : TextButton(
                        onPressed: () => _setFocusedDomain(domain.id),
                        child: const Text('设为重点'),
                      ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
