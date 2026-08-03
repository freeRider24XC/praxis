import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:praxis/common/models/index.dart';
import 'package:praxis/common/services/index.dart';
import 'package:praxis/common/style/design_tokens.dart';
import 'package:praxis/pages/life_domains/domain_detail_page.dart';

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
      backgroundColor:
          isDark ? DesignTokens.backgroundDark : DesignTokens.backgroundLight,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.all(DesignTokens.spacing6),
          children: [
            Text(
              '领域视角',
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
              '领域用来帮助你观察生活的不同面向，不替代目标、项目和事项这条主推进链。',
              style: DesignTokens.textStyle(
                color: isDark
                    ? DesignTokens.textSecondaryDark
                    : DesignTokens.textSecondaryLight,
              ),
            ),
            const SizedBox(height: DesignTokens.spacing3),
            Container(
              padding: const EdgeInsets.all(DesignTokens.spacing4),
              decoration: BoxDecoration(
                color: isDark ? DesignTokens.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
                border: Border.all(
                  color: isDark
                      ? DesignTokens.borderDark
                      : DesignTokens.borderLight,
                ),
              ),
              child: Text(
                _focusedDomainId == null
                    ? '你还没有设置当前重点领域。设定它后，首页和目标页会用这个视角辅助你判断主线。'
                    : '当前重点领域只代表你现在更常从哪一个视角看问题，不会替代目标和项目本身。',
                style: DesignTokens.textStyle(
                  color: isDark
                      ? DesignTokens.textSecondaryDark
                      : DesignTokens.textSecondaryLight,
                ),
              ),
            ),
            const SizedBox(height: DesignTokens.spacing5),
            ..._domains.map((domain) {
              final isFocused = domain.id == _focusedDomainId;
              final todoCount =
                  DatabaseService.getTodosByDomain(domain.id).length;
              final goalCount =
                  DatabaseService.getGoalsByDomain(domain.id).length;
              return Container(
                margin: const EdgeInsets.only(bottom: DesignTokens.spacing4),
                decoration: BoxDecoration(
                  color: isDark ? DesignTokens.surfaceDark : Colors.white,
                  borderRadius:
                      BorderRadius.circular(DesignTokens.radiusXLarge),
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
                  onTap: () async {
                    await Get.to(() => DomainDetailPage(domainId: domain.id));
                    _load();
                  },
                  contentPadding: const EdgeInsets.all(DesignTokens.spacing4),
                  leading:
                      Text(domain.icon, style: const TextStyle(fontSize: 28)),
                  title: Text(domain.name),
                  subtitle: Text('$goalCount 个目标 · $todoCount 个事项'),
                  trailing: isFocused
                      ? const Icon(Icons.check_circle,
                          color: DesignTokens.primaryColor)
                      : TextButton(
                          onPressed: () => _setFocusedDomain(domain.id),
                          child: const Text('设为重点'),
                        ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
