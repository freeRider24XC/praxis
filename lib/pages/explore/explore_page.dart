import 'package:flutter/material.dart';
import 'package:praxis/common/style/design_tokens.dart';
import 'package:praxis/common/widgets/tag_chip.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// 发现社区页
class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  String _selectedCategory = '推荐';

  final List<String> _categories = ['推荐', '旅行', '健身', '编程'];

  final List<Map<String, dynamic>> _templates = [
    {
      'title': '7天京都深度游',
      'image': 'https://images.unsplash.com/photo-1493934558415-9d19f0b2b4d2?w=500&q=80',
      'tags': ['⛩️ 寺庙', '🍵 抹茶'],
      'author': 'Sarah L.',
      'authorRole': '旅行博主',
      'downloads': 2300,
      'likes': 582,
      'isHot': true,
    },
    {
      'title': '30天居家腹肌训练',
      'image': null,
      'icon': '🏋️',
      'description': '适合零基础 • 每日20分钟',
      'tags': ['无器械', 'P4级难度'],
      'author': 'Fitness Pro',
      'downloads': 1500,
      'likes': 320,
      'isHot': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
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
            child: Column(
              children: [
                Text(
                  '探索社区',
                  style: DesignTokens.textStyle(
                    fontSize: DesignTokens.fontSizeHeadlineSmall,
                    fontWeight: DesignTokens.fontWeightBold,
                    color: isDark
                        ? DesignTokens.onSurfaceDark
                        : DesignTokens.onSurfaceLight,
                  ),
                ),
                
                const SizedBox(height: DesignTokens.spacing4),
                
                // 标签栏
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    spacing: DesignTokens.spacing3,
                    children: _categories.map((category) {
                      final isSelected = _selectedCategory == category;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: DesignTokens.spacing5,
                            vertical: DesignTokens.spacing2 + 2,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark
                                    ? DesignTokens.surfaceDark
                                    : Colors.black)
                                : (isDark
                                    ? DesignTokens.surfaceDarkSecondary
                                    : Colors.white),
                            borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.transparent
                                  : (isDark
                                      ? DesignTokens.borderDark
                                      : DesignTokens.borderLight),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            category,
                            style: DesignTokens.textStyle(
                              fontSize: DesignTokens.fontSizeBodySmall,
                              fontWeight: DesignTokens.fontWeightBold,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark
                                      ? DesignTokens.textSecondaryDark
                                      : DesignTokens.textSecondaryLight),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // 内容区域
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(DesignTokens.spacing6),
              children: _templates.map((template) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: DesignTokens.spacing6),
                  child: _buildTemplateCard(template, isDark),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(Map<String, dynamic> template, bool isDark) {
    final hasImage = template['image'] != null;
    
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasImage)
            // 图片模板
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(DesignTokens.radiusXLarge),
                topRight: Radius.circular(DesignTokens.radiusXLarge),
              ),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: template['image'] as String,
                    width: double.infinity,
                    height: 176,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: DesignTokens.surfaceLightSecondary,
                    ),
                  ),
                  // 渐变遮罩
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // 热门标签
                  if (template['isHot'] == true)
                    Positioned(
                      top: DesignTokens.spacing4,
                      right: DesignTokens.spacing4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: DesignTokens.spacing3,
                          vertical: DesignTokens.spacing1,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
                        ),
                        child: Text(
                          '🔥 热门',
                          style: DesignTokens.textStyle(
                            fontSize: 10,
                            fontWeight: DesignTokens.fontWeightBold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  
                  // 标题和标签
                  Positioned(
                    bottom: DesignTokens.spacing4,
                    left: DesignTokens.spacing5,
                    right: DesignTokens.spacing5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          template['title'] as String,
                          style: DesignTokens.textStyle(
                            fontSize: DesignTokens.fontSizeHeadlineSmall,
                            fontWeight: DesignTokens.fontWeightBold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: DesignTokens.spacing2),
                        Wrap(
                          spacing: DesignTokens.spacing2,
                          children: (template['tags'] as List<String>).map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: DesignTokens.spacing2,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
                              ),
                              child: Text(
                                tag,
                                style: DesignTokens.textStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else
            // 图标模板
            Padding(
              padding: const EdgeInsets.all(DesignTokens.spacing5),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          DesignTokens.secondaryOrange.withOpacity(0.1),
                          DesignTokens.secondaryOrange.withOpacity(0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
                      border: Border.all(
                        color: DesignTokens.secondaryOrange.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        template['icon'] as String,
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: DesignTokens.spacing4),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          template['title'] as String,
                          style: DesignTokens.textStyle(
                            fontSize: DesignTokens.fontSizeTitleLarge,
                            fontWeight: DesignTokens.fontWeightBold,
                            color: isDark
                                ? DesignTokens.onSurfaceDark
                                : DesignTokens.onSurfaceLight,
                          ),
                        ),
                        const SizedBox(height: DesignTokens.spacing1),
                        Text(
                          template['description'] as String,
                          style: DesignTokens.textStyle(
                            fontSize: DesignTokens.fontSizeBodySmall,
                            color: isDark
                                ? DesignTokens.textSecondaryDark
                                : DesignTokens.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(height: DesignTokens.spacing3),
                        Wrap(
                          spacing: DesignTokens.spacing2,
                          children: (template['tags'] as List<String>).map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: DesignTokens.spacing2,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? DesignTokens.surfaceDarkSecondary
                                    : DesignTokens.surfaceLightSecondary,
                                borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
                              ),
                              child: Text(
                                tag,
                                style: DesignTokens.textStyle(
                                  fontSize: 10,
                                  fontWeight: DesignTokens.fontWeightBold,
                                  color: isDark
                                      ? DesignTokens.textSecondaryDark
                                      : DesignTokens.textSecondaryLight,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          
          // 底部信息
          Padding(
            padding: const EdgeInsets.all(DesignTokens.spacing4),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                DesignTokens.secondaryPurple,
                                DesignTokens.secondaryOrange,
                              ],
                            ),
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: DesignTokens.spacing2),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              template['author'] as String,
                              style: DesignTokens.textStyle(
                                fontSize: DesignTokens.fontSizeLabelSmall,
                                fontWeight: DesignTokens.fontWeightBold,
                                color: isDark
                                    ? DesignTokens.onSurfaceDark
                                    : DesignTokens.onSurfaceLight,
                              ),
                            ),
                            Text(
                              template['authorRole'] as String? ?? '',
                              style: DesignTokens.textStyle(
                                fontSize: 10,
                                color: isDark
                                    ? DesignTokens.textSecondaryDark
                                    : DesignTokens.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      spacing: DesignTokens.spacing3,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.download,
                              size: 14,
                              color: DesignTokens.primaryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${(template['downloads'] as int) ~/ 1000}k',
                              style: DesignTokens.textStyle(
                                fontSize: DesignTokens.fontSizeLabelSmall,
                                fontWeight: DesignTokens.fontWeightBold,
                                color: isDark
                                    ? DesignTokens.textSecondaryDark
                                    : DesignTokens.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.favorite,
                              size: 14,
                              color: Colors.pink,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${template['likes']}',
                              style: DesignTokens.textStyle(
                                fontSize: DesignTokens.fontSizeLabelSmall,
                                fontWeight: DesignTokens.fontWeightBold,
                                color: isDark
                                    ? DesignTokens.textSecondaryDark
                                    : DesignTokens.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: DesignTokens.spacing4),
                
                // 使用模板按钮
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // 使用模板
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? DesignTokens.primaryColor.withOpacity(0.1)
                          : DesignTokens.primaryColor.withOpacity(0.1),
                      foregroundColor: DesignTokens.primaryColor,
                      padding: const EdgeInsets.symmetric(
                        vertical: DesignTokens.spacing3,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
                        side: BorderSide(
                          color: DesignTokens.primaryColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.copy, size: 18),
                        const SizedBox(width: DesignTokens.spacing2),
                        Text(
                          '使用此模板',
                          style: DesignTokens.textStyle(
                            fontSize: DesignTokens.fontSizeBodySmall,
                            fontWeight: DesignTokens.fontWeightBold,
                            color: DesignTokens.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
