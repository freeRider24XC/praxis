import 'package:flutter/material.dart';
import 'package:praxis/common/style/design_tokens.dart';
import 'package:get/get.dart';

/// 消息通知页
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final todayNotifications = [
      {
        'type': 'ai_complete',
        'title': '计划生成完毕',
        'content': '你的 "2024 年书单计划" 已完成拆解，包含 3 个阶段共 15 个任务。',
        'time': '2 分钟前',
        'icon': Icons.auto_awesome,
        'iconColor': DesignTokens.primaryColor,
        'isUnread': true,
      },
      {
        'type': 'social',
        'title': 'Sarah 赞了你的计划',
        'content': 'Sarah 觉得你的 "30天腹肌训练" 很棒，并收藏了模板。',
        'time': '1 小时前',
        'icon': Icons.favorite,
        'iconColor': Colors.pink,
        'avatar': 'https://api.dicebear.com/7.x/avataaars/svg?seed=Sarah',
        'isUnread': true,
      },
    ];
    
    final yesterdayNotifications = [
      {
        'type': 'system',
        'title': '每日回顾提醒',
        'content': '你今天完成了 4 个任务，别忘了填写每日总结哦。',
        'time': '昨天 20:00',
        'icon': Icons.notifications,
        'iconColor': DesignTokens.secondaryOrange,
        'isUnread': false,
      },
    ];
    
    return Scaffold(
      backgroundColor: isDark
          ? DesignTokens.backgroundDark
          : DesignTokens.backgroundLight,
      body: Column(
        children: [
          // 顶部栏
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.spacing6,
              vertical: DesignTokens.spacing4,
            ),
            decoration: BoxDecoration(
              color: isDark
                  ? DesignTokens.backgroundDark
                  : Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: isDark
                      ? DesignTokens.borderDark
                      : DesignTokens.borderLight,
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '通知消息',
                  style: DesignTokens.textStyle(
                    fontSize: DesignTokens.fontSizeHeadlineSmall,
                    fontWeight: DesignTokens.fontWeightBold,
                    color: isDark
                        ? DesignTokens.onSurfaceDark
                        : DesignTokens.onSurfaceLight,
                  ),
                ),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isDark
                        ? DesignTokens.surfaceDarkSecondary
                        : DesignTokens.surfaceLightSecondary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark
                          ? DesignTokens.borderDark
                          : DesignTokens.borderLight,
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.done_all,
                    size: 18,
                    color: isDark
                        ? DesignTokens.textSecondaryDark
                        : DesignTokens.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),

          // 内容区域
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(DesignTokens.spacing6),
              children: [
                // 今天
                Text(
                  '今天',
                  style: DesignTokens.textStyle(
                    fontSize: DesignTokens.fontSizeLabelSmall,
                    fontWeight: DesignTokens.fontWeightBold,
                    color: isDark
                        ? DesignTokens.textSecondaryDark
                        : DesignTokens.textSecondaryLight,
                  ),
                ),
                
                const SizedBox(height: DesignTokens.spacing4),
                
                ...todayNotifications.map((notification) {
                  return _buildNotificationCard(notification, isDark);
                }),
                
                const SizedBox(height: DesignTokens.spacing6),
                
                // 昨天
                Text(
                  '昨天',
                  style: DesignTokens.textStyle(
                    fontSize: DesignTokens.fontSizeLabelSmall,
                    fontWeight: DesignTokens.fontWeightBold,
                    color: isDark
                        ? DesignTokens.textSecondaryDark
                        : DesignTokens.textSecondaryLight,
                  ),
                ),
                
                const SizedBox(height: DesignTokens.spacing4),
                
                ...yesterdayNotifications.map((notification) {
                  return _buildNotificationCard(notification, isDark);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification, bool isDark) {
    final isUnread = notification['isUnread'] == true;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: DesignTokens.spacing3),
      child: GestureDetector(
        onTap: () {
          // 处理通知点击
        },
        child: Container(
          padding: const EdgeInsets.all(DesignTokens.spacing4),
          decoration: BoxDecoration(
            color: isDark
                ? DesignTokens.surfaceDark
                : Colors.white,
            borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
            border: Border.all(
              color: isDark
                  ? DesignTokens.borderDark
                  : DesignTokens.borderLight,
              width: 0.5,
            ),
            boxShadow: DesignTokens.shadowIOS,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 图标或头像
              if (notification['avatar'] != null)
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        DesignTokens.secondaryPurple,
                        DesignTokens.secondaryOrange,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
                  ),
                  padding: const EdgeInsets.all(2),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge - 2),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 24,
                    ),
                  ),
                )
              else
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: (notification['iconColor'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
                  ),
                  child: Icon(
                    notification['icon'] as IconData,
                    color: notification['iconColor'] as Color,
                    size: 24,
                  ),
                ),
              
              const SizedBox(width: DesignTokens.spacing4),
              
              // 内容
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification['title'] as String,
                            style: DesignTokens.textStyle(
                              fontSize: DesignTokens.fontSizeBodySmall,
                              fontWeight: DesignTokens.fontWeightBold,
                              color: isDark
                                  ? DesignTokens.onSurfaceDark
                                  : DesignTokens.onSurfaceLight,
                            ),
                          ),
                        ),
                        if (isUnread)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: DesignTokens.spacing1),
                    Text(
                      notification['content'] as String,
                      style: DesignTokens.textStyle(
                        fontSize: DesignTokens.fontSizeBodySmall,
                        color: isDark
                            ? DesignTokens.textSecondaryDark
                            : DesignTokens.textSecondaryLight,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: DesignTokens.spacing2),
                    Text(
                      notification['time'] as String,
                      style: DesignTokens.textStyle(
                        fontSize: 10,
                        fontWeight: DesignTokens.fontWeightBold,
                        color: isDark
                            ? DesignTokens.textTertiaryDark
                            : DesignTokens.textTertiaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

