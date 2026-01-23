---
AIGC:
    ContentProducer: Minimax Agent AI
    ContentPropagator: Minimax Agent AI
    Label: AIGC
    ProduceID: "00000000000000000000000000000000"
    PropagateID: "00000000000000000000000000000000"
    ReservedCode1: 3046022100f40c53ba8c2ba3381c8df1cd25d3fe5b49854bb87aec8f7be799c63fef7495db022100816cb4b7c31db1bbaef15a7edafb436d0b8190f7ad07757dba6217a4f48b2b2d
    ReservedCode2: 3045022100b90ff4beb90ff5411e4a7d9e6d15bdbfb60adc0282066ea042a3aa81ead7ea9d02203114ab4451d928856b0b58ba2dfe42c3b1d0eb5c43254aa04e8be94844d3ff93
---

# ZhiXing AI服务集成示例

## 🚀 快速开始

### 1. 注册AI服务
```dart
// 在 main.dart 中注册
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 注册AI服务
  await Get.putAsync(() => ZhiXingAIService().onInit().then((_) => ZhiXingAIService()));
  
  runApp(MyApp());
}
```

### 2. 在页面中使用AI服务
```dart
class AITaskPlanningPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final aiService = Get.find<ZhiXingAIService>();
    
    return Scaffold(
      appBar: AppBar(title: Text('AI智能规划')),
      body: Column(
        children: [
          // AI输入区域
          _buildInputSection(),
          // AI输出结果
          _buildResultSection(),
        ],
      ),
    );
  }
}
```

## 🧩 智能任务分解

### 基础使用
```dart
class GoalDecompositionWidget extends StatelessWidget {
  final aiService = Get.find<ZhiXingAIService>();
  
  Future<void> _decomposeGoal(String goalTitle, String description) async {
    try {
      // 显示加载状态
      Get.dialog(
        Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );
      
      // 调用AI分解服务
      final tasks = await aiService.decomposeGoalWithAI(
        goalTitle: goalTitle,
        description: description,
        estimatedDays: 30,
      );
      
      // 关闭加载对话框
      Get.back();
      
      // 显示结果
      _showDecompositionResult(tasks);
      
    } catch (e) {
      Get.back(); // 关闭加载对话框
      Get.snackbar('错误', 'AI分解失败: $e');
    }
  }
  
  void _showDecompositionResult(List<Task> tasks) {
    Get.dialog(
      Dialog(
        child: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Text('任务分解结果', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return ZhiXingCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(task.title, style: TextStyle(fontWeight: FontWeight.bold)),
                          if (task.description.isNotEmpty)
                            Text(task.description),
                          Row(
                            children: [
                              Chip(label: Text('优先级: ${task.priority}')),
                              SizedBox(width: 8),
                              Chip(label: Text('时间: ${task.estimatedTime}')),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  child: Text('确认'),
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

## ⏰ 智能时间规划

### 高级时间规划
```dart
class SmartSchedulingWidget extends StatefulWidget {
  @override
  _SmartSchedulingWidgetState createState() => _SmartSchedulingWidgetState();
}

class _SmartSchedulingWidgetState extends State<SmartSchedulingWidget> {
  final aiService = Get.find<ZhiXingAIService>();
  List<Task> selectedTasks = [];
  List<TimeSlot> scheduledSlots = [];
  
  Future<void> _generateSchedule() async {
    if (selectedTasks.isEmpty) {
      Get.snackbar('提示', '请先选择要规划的任务');
      return;
    }
    
    try {
      final schedule = await aiService.smartScheduleTasks(
        tasks: selectedTasks,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(Duration(days: 7)),
      );
      
      setState(() {
        scheduledSlots = schedule;
      });
      
      _showScheduleDialog();
      
    } catch (e) {
      Get.snackbar('错误', '生成时间规划失败: $e');
    }
  }
  
  void _showScheduleDialog() {
    Get.dialog(
      Dialog(
        child: Container(
          width: double.maxFinite,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Text('智能时间规划', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: scheduledSlots.length,
                  itemBuilder: (context, index) {
                    final slot = scheduledSlots[index];
                    return ZhiXingCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('任务: ${slot.taskId}'),
                          Text('开始: ${slot.startTime}'),
                          Text('结束: ${slot.endTime}'),
                          if (slot.tips.isNotEmpty)
                            Text('建议: ${slot.tips}', style: TextStyle(color: Colors.blue)),
                        ],
                      ),
                    );
                  },
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

## 📊 智能进度分析

### 进度监控和分析
```dart
class ProgressAnalysisWidget extends StatelessWidget {
  final aiService = Get.find<ZhiXingAIService>();
  
  Future<void> _analyzeProgress() async {
    try {
      // 获取项目数据
      final completedTasks = await _getCompletedTasks();
      final pendingTasks = await _getPendingTasks();
      
      // 调用AI分析
      final analysis = await aiService.analyzeProgress(
        completedTasks: completedTasks,
        pendingTasks: pendingTasks,
        startDate: DateTime.now().subtract(Duration(days: 30)),
      );
      
      // 显示分析结果
      _showAnalysisResult(analysis);
      
    } catch (e) {
      Get.snackbar('错误', '进度分析失败: $e');
    }
  }
  
  void _showAnalysisResult(ProgressAnalysis analysis) {
    Get.dialog(
      AlertDialog(
        title: Text('项目进度分析'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ZhiXingStatCard(
              title: '完成率',
              value: '${(analysis.completionRate * 100).toInt()}%',
              subtitle: analysis.progress,
            ),
            SizedBox(height: 16),
            Text('效率评估: ${analysis.efficiency}'),
            Text('整体策略: ${analysis.overallStrategy}'),
            if (analysis.recommendations.isNotEmpty) ...[
              SizedBox(height: 16),
              Text('改进建议:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...analysis.recommendations.map((rec) => 
                Text('• $rec')
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('关闭'),
          ),
        ],
      ),
    );
  }
}
```

## 🔔 智能提醒系统

### 自适应提醒
```dart
class SmartReminderWidget extends StatefulWidget {
  @override
  _SmartReminderWidgetState createState() => _SmartReminderWidgetState();
}

class _SmartReminderWidgetState extends State<SmartReminderWidget> {
  final aiService = Get.find<ZhiXingAIService>();
  List<SmartReminder> reminders = [];
  
  Future<void> _generateReminders() async {
    try {
      final tasks = await _getCurrentTasks();
      final reminders = await aiService.generateSmartReminders(
        tasks: tasks,
        currentTime: DateTime.now(),
      );
      
      setState(() {
        this.reminders = reminders;
      });
      
      // 设置实际提醒
      await _setupActualReminders(reminders);
      
    } catch (e) {
      Get.snackbar('错误', '生成智能提醒失败: $e');
    }
  }
  
  Future<void> _setupActualReminders(List<SmartReminder> reminders) async {
    for (final reminder in reminders) {
      // 这里可以集成实际的提醒服务
      // 比如 flutter_local_notifications
      print('设置提醒: ${reminder.title} - ${reminder.scheduledTime}');
    }
    
    Get.snackbar('成功', '已设置 ${reminders.length} 个智能提醒');
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _generateReminders,
            child: Text('生成智能提醒'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: reminders.length,
              itemBuilder: (context, index) {
                final reminder = reminders[index];
                return ZhiXingCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(reminder.title, style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(reminder.message),
                      Text('类型: ${reminder.type}'),
                      Text('优先级: ${reminder.priority}'),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

## 🎯 智能聊天界面

### AI对话界面
```dart
class AIChatInterface extends StatefulWidget {
  @override
  _AIChatInterfaceState createState() => _AIChatInterfaceState();
}

class _AIChatInterfaceState extends State<AIChatInterface> {
  final aiService = Get.find<ZhiXingAIService>();
  final TextEditingController messageController = TextEditingController();
  final List<ChatMessage> messages = [];
  
  Future<void> _sendMessage() async {
    final message = messageController.text.trim();
    if (message.isEmpty) return;
    
    // 添加用户消息
    setState(() {
      messages.add(ChatMessage(text: message, isUser: true));
    });
    messageController.clear();
    
    try {
      // 获取AI响应
      final response = await aiService.chat(message);
      
      // 添加AI回复
      setState(() {
        messages.add(ChatMessage(text: response, isUser: false));
      });
      
    } catch (e) {
      setState(() {
        messages.add(ChatMessage(text: '抱歉，AI服务暂时不可用: $e', isUser: false));
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('AI助手')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return Align(
                  alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: message.isUser ? Theme.of(context).primaryColor : Colors.grey[300],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(message.text),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: '输入您的问题...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  onPressed: _sendMessage,
                  icon: Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  
  ChatMessage({required this.text, required this.isUser});
}
```

## ⚠️ 错误处理和优化

### 错误处理最佳实践
```dart
class SafeAIServiceWrapper {
  final aiService = Get.find<ZhiXingAIService>();
  
  Future<T> safeCall<T>(Future<T> Function() operation, {T? fallback}) async {
    try {
      return await operation();
    } catch (e) {
      print('AI服务调用失败: $e');
      if (fallback != null) return fallback;
      
      // 显示用户友好的错误信息
      _showUserFriendlyError(e);
      rethrow;
    }
  }
  
  void _showUserFriendlyError(Object error) {
    Get.snackbar(
      'AI服务提示',
      '抱歉，AI助手暂时不可用，请稍后重试',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
    );
  }
}
```

### 性能优化
```dart
class AIServiceCache {
  final Map<String, dynamic> _cache = {};
  
  Future<T> getCachedResult<T>(String key, Future<T> Function() operation) async {
    if (_cache.containsKey(key)) {
      return _cache[key] as T;
    }
    
    final result = await operation();
    _cache[key] = result;
    
    // 定期清理缓存
    if (_cache.length > 100) {
      _cache.clear();
    }
    
    return result;
  }
}
```

这些示例展示了如何在实际项目中集成和使用ZhiXing AI服务的各种功能。