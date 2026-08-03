import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:praxis/common/models/index.dart';
import 'package:praxis/common/services/index.dart';
import 'package:praxis/common/style/design_tokens.dart';

class RewardTodosPage extends StatefulWidget {
  const RewardTodosPage({super.key});

  @override
  State<RewardTodosPage> createState() => _RewardTodosPageState();
}

class _RewardTodosPageState extends State<RewardTodosPage> {
  late List<RewardTodo> _items;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _items = DatabaseService.getAllRewardTodos();
    });
  }

  Future<void> _complete(RewardTodo item) async {
    await RewardService.completeRewardTodo(item);
    _load();
    if (!mounted) return;
    Get.snackbar('已兑现', '这次奖励已经真正完成。');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('奖励待办')),
      backgroundColor:
          isDark ? DesignTokens.backgroundDark : DesignTokens.backgroundLight,
      body: ListView(
        padding: const EdgeInsets.all(DesignTokens.spacing6),
        children: _items.isEmpty
            ? [
                Text(
                  '还没有奖励待办。先完成关键行动，再回来犒赏自己。',
                  style: DesignTokens.textStyle(
                    color: isDark
                        ? DesignTokens.textSecondaryDark
                        : DesignTokens.textSecondaryLight,
                  ),
                ),
              ]
            : _items.map((item) {
                final completed = item.status == RewardTodoStatus.completed;
                return Container(
                  margin: const EdgeInsets.only(bottom: DesignTokens.spacing4),
                  padding: const EdgeInsets.all(DesignTokens.spacing5),
                  decoration: BoxDecoration(
                    color: isDark ? DesignTokens.surfaceDark : Colors.white,
                    borderRadius:
                        BorderRadius.circular(DesignTokens.radiusXLarge),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: DesignTokens.textStyle(
                                fontSize: DesignTokens.fontSizeTitleMedium,
                                fontWeight: DesignTokens.fontWeightBold,
                                color: isDark
                                    ? DesignTokens.onSurfaceDark
                                    : DesignTokens.onSurfaceLight,
                              ),
                            ),
                            if ((item.description ?? '').isNotEmpty) ...[
                              const SizedBox(height: DesignTokens.spacing2),
                              Text(item.description!),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: DesignTokens.spacing4),
                      ElevatedButton(
                        onPressed: completed ? null : () => _complete(item),
                        child: Text(completed ? '已完成' : '兑现'),
                      ),
                    ],
                  ),
                );
              }).toList(),
      ),
    );
  }
}
