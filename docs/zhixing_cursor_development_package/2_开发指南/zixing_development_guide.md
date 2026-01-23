---
AIGC:
    ContentProducer: Minimax Agent AI
    ContentPropagator: Minimax Agent AI
    Label: AIGC
    ProduceID: "00000000000000000000000000000000"
    PropagateID: "00000000000000000000000000000000"
    ReservedCode1: 304402201c1a18f47a1e0b1c93a47cdb893d07a411c7678fda0601e7d8b5b56ca467ff4d02204062fb01890d4f20e1958638c62082012b549f12587aa4f52954b6a3fc74e727
    ReservedCode2: 3044022046953eed2d3e9e6bb2746344c0400c67b6c8e776ae95289e68eb2a22d9ef196d02203ac4ffaf8cee662cb28d1fede4ab124b37d2ad35c7c5daaf8a1928064f4a4344
---

# ZhiXing 开发指导文档
*从 Praxis 到 ZhiXing 的具体实施计划*

## 🎯 立即可实施的品牌升级

### 1. 项目重命名
```yaml
# pubspec.yaml 更新
name: zixing  # 从 praxis 改为 zixing
description: "知行合一，规划人生 - 智能AI规划助手"
version: 1.0.0+1
```

### 2. 应用入口更新
```dart
// lib/main.dart - 品牌升级
return Obx(() => GetMaterialApp(
  title: "ZhiXing (知行)",  // 从 "Praxis" 更新
  debugShowCheckedModeBanner: false,
  // ... 其他配置保持不变
));
```

### 3. 应用图标和启动页面
```dart
// 创建启动页面，显示 ZhiXing 品牌
class SplashPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade600,
              Colors.blue.shade800,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 100,
                color: Colors.white,
              ),
              SizedBox(height: 20),
              Text(
                'ZhiXing',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '知行合一，规划人生',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

## 🎨 UI/UX 优化升级

### 1. 主题系统升级
```dart
// lib/common/style/themes.dart
class ZhiXingTheme {
  // ZhiXing 品牌色彩
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color accentColor = Color(0xFF6200EE);
  
  // 创建 Material 3 主题
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
  
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
      ),
    );
  }
}
```

### 2. 通用组件优化
```dart
// lib/common/widgets/zixing_card.dart
import 'package:flutter/material.dart';

class ZhiXingCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  
  const ZhiXingCard({
    Key? key,
    required this.child,
    this.onTap,
    this.padding,
    this.backgroundColor,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: backgroundColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: padding ?? EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}

// lib/common/widgets/zixing_button.dart
class ZhiXingButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonType type;
  
  const ZhiXingButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.type = ButtonType.primary,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    switch (type) {
      case ButtonType.primary:
        return ElevatedButton(
          onPressed: onPressed,
          child: Text(text),
        );
      case ButtonType.secondary:
        return OutlinedButton(
          onPressed: onPressed,
          child: Text(text),
        );
      case ButtonType.text:
        return TextButton(
          onPressed: onPressed,
          child: Text(text),
        );
    }
  }
}

enum ButtonType { primary, secondary, text }
```

## 🤖 AI功能增强

### 1. 多AI提供商支持
```dart
// lib/common/ai/providers/ai_provider.dart
abstract class AIProvider {
  Future<String> chat(String message, {Map<String, dynamic>? context});
  Future<List<Task>> parseTasks(String message);
  Future<Goal> createGoal(String description);
  Future<List<String>> suggestPriorities(List<Task> tasks);
}

// lib/common/ai/providers/deepseek_provider.dart
class DeepSeekProvider extends AIProvider {
  @override
  Future<String> chat(String message, {Map<String, dynamic>? context}) async {
    // DeepSeek API 实现
    return await _callDeepSeekAPI(message, context);
  }
  
  @override
  Future<List<Task>> parseTasks(String message) async {
    // 智能任务解析
    final prompt = '''
请从以下消息中提取具体的任务项，每个任务应该包含：
1. 任务标题
2. 优先级（高/中/低）
3. 预计完成时间
4. 相关标签

消息内容：$message

请以JSON格式返回：
{
  "tasks": [
    {
      "title": "任务标题",
      "priority": "high|medium|low",
      "estimatedTime": "2小时",
      "tags": ["标签1", "标签2"]
    }
  ]
}
''';
    
    final response = await chat(prompt);
    return _parseTasksFromResponse(response);
  }
}
```

### 2. 智能任务分解
```dart
// lib/common/ai/services/task_decomposition_service.dart
class TaskDecompositionService {
  static Future<List<Task>> decomposeGoal(Goal goal) async {
    final prompt = '''
请将以下目标分解为具体的可执行任务：

目标：${goal.title}
描述：${goal.description}

要求：
1. 每个任务都应该具体、可衡量、可达成
2. 按照逻辑顺序排列
3. 考虑任务的依赖关系
4. 提供时间估算

请返回JSON格式：
{
  "tasks": [
    {
      "title": "任务标题",
      "description": "任务描述",
      "priority": "high|medium|low",
      "estimatedTime": "时间估算",
      "dependencies": ["依赖的任务ID"],
      "subTasks": ["子任务列表"]
    }
  ]
}
''';
    
    final aiResponse = await AIProvider.chat(prompt);
    return _parseDecomposedTasks(aiResponse);
  }
  
  static Future<List<Task>> smartSchedule(List<Task> tasks) async {
    // 智能时间安排
    final prompt = '''
请为以下任务安排合理的时间：

任务列表：${tasks.map((t) => t.title).join(', ')}

考虑因素：
1. 任务优先级
2. 任务依赖关系
3. 用户的历史效率
4. 当前时间安排

返回格式：
{
  "schedule": [
    {
      "taskId": "任务ID",
      "scheduledTime": "建议时间",
      "reason": "安排理由"
    }
  ]
}
''';
    
    return await AIProvider.chat(prompt).then((response) {
      // 解析AI建议并应用到任务
      return _applyScheduleToTasks(tasks, response);
    });
  }
}
```

## 📊 数据分析增强

### 1. 统计分析服务
```dart
// lib/common/services/analytics_service.dart
class AnalyticsService {
  static Future<AnalyticsData> generateWeeklyReport() async {
    final todos = await TodoService.getCompletedTodos(
      from: DateTime.now().subtract(Duration(days: 7)),
      to: DateTime.now(),
    );
    
    final analytics = AnalyticsData(
      totalTasks: todos.length,
      completedTasks: todos.where((t) => t.isDone).length,
      completionRate: _calculateCompletionRate(todos),
      averageCompletionTime: _calculateAverageTime(todos),
      productivityScore: _calculateProductivityScore(todos),
      commonPatterns: _analyzePatterns(todos),
      recommendations: await _generateRecommendations(todos),
    );
    
    return analytics;
  }
  
  static Future<List<ProductivityInsight>> getInsights() async {
    final insights = <ProductivityInsight>[];
    
    // 1. 效率模式分析
    final efficiencyPattern = await _analyzeEfficiencyPattern();
    if (efficiencyPattern != null) {
      insights.add(ProductivityInsight(
        type: InsightType.efficiency,
        title: "工作效率分析",
        description: efficiencyPattern.description,
        recommendation: efficiencyPattern.recommendation,
        priority: InsightPriority.high,
      ));
    }
    
    // 2. 时间管理建议
    final timeManagement = await _analyzeTimeManagement();
    if (timeManagement != null) {
      insights.add(ProductivityInsight(
        type: InsightType.timeManagement,
        title: "时间管理优化",
        description: timeManagement.description,
        recommendation: timeManagement.recommendation,
        priority: InsightPriority.medium,
      ));
    }
    
    return insights;
  }
}
```

### 2. 可视化图表增强
```dart
// lib/pages/stats/widgets/productivity_chart.dart
import 'package:fl_chart/fl_chart.dart';

class ProductivityChart extends StatelessWidget {
  final List<ProductivityData> data;
  
  const ProductivityChart({Key? key, required this.data}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      padding: EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: data.asMap().entries.map((entry) {
                return FlSpot(entry.key.toDouble(), entry.value.score);
              }).toList(),
              isCurved: true,
              color: ZhiXingTheme.primaryColor,
              barWidth: 3,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: ZhiXingTheme.primaryColor.withOpacity(0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## 🔧 技术优化建议

### 1. 性能优化
```dart
// lib/common/utils/performance_utils.dart
class PerformanceUtils {
  static Widget cachedWidget({
    required Widget Function() builder,
    String? cacheKey,
    Duration? cacheDuration,
  }) {
    return FutureBuilder(
      future: _getCachedWidget(cacheKey, cacheDuration),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return snapshot.data!;
        }
        return builder();
      },
    );
  }
  
  static void optimizeImageLoading() {
    // 图片缓存和懒加载
    ImageCache memoryCache = PaintingBinding.instance.imageCache;
    memoryCache.maximumSize = 100; // 限制内存缓存大小
  }
}
```

### 2. 错误处理增强
```dart
// lib/common/utils/error_handler.dart
class ErrorHandler {
  static void handleError(Object error, StackTrace stackTrace) {
    // 记录错误
    print('ZhiXing Error: $error');
    print('Stack Trace: $stackTrace');
    
    // 用户友好的错误提示
    _showUserFriendlyError(error);
    
    // 发送错误报告（如果配置了）
    _sendErrorReport(error, stackTrace);
  }
  
  static void _showUserFriendlyError(Object error) {
    // 显示适当的错误信息
    Get.snackbar(
      '操作失败',
      '抱歉，操作过程中出现了问题，请稍后重试',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}
```

## 📱 实施检查清单

### ✅ 第一阶段：品牌升级 (1-2天)
- [ ] 更新 pubspec.yaml 中的项目信息
- [ ] 修改应用标题为 ZhiXing
- [ ] 更新应用图标
- [ ] 创建启动页面
- [ ] 更新 README.md

### ✅ 第二阶段：UI优化 (3-5天)
- [ ] 创建 ZhiXing 主题系统
- [ ] 升级到 Material 3
- [ ] 优化通用组件
- [ ] 改进动画效果
- [ ] 测试暗色模式

### ✅ 第三阶段：功能增强 (1-2周)
- [ ] 实现多AI提供商支持
- [ ] 添加智能任务分解功能
- [ ] 增强统计分析
- [ ] 优化性能
- [ ] 添加错误处理

## 🎯 开发建议

1. **渐进式开发**: 不要一次性重构整个项目
2. **测试驱动**: 为新功能编写测试
3. **用户反馈**: 早期测试和收集用户反馈
4. **性能监控**: 添加性能监控和错误追踪
5. **文档维护**: 及时更新技术文档

您的项目基础很好，只需要适度的优化就能实现 ZhiXing 的产品愿景！