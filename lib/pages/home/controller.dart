import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Todo {
  String title;
  bool isDone;

  Todo({required this.title, this.isDone = false});
}

class HomeController extends GetxController {
  final todos = <Todo>[].obs;
  final textEditingController = TextEditingController();

  // 主题色列表
  final List<Color> themeColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.purple,
    Colors.orange,
  ];

  // 主题色名称列表
  final List<String> themeNames = ['蓝色', '红色', '绿色', '紫色', '橙色'];

  // 当前主题索引
  final RxInt currentThemeIndex = 0.obs;

  HomeController() {
    // 初始化时设置主题
    ever(currentThemeIndex, (_) => updateTheme());
  }

  void _initData() {
    update(["home"]);
  }

  @override
  void onReady() {
    super.onReady();
    _initData();
  }

  void addTodo() {
    if (textEditingController.text.isNotEmpty) {
      todos.add(Todo(title: textEditingController.text));
      textEditingController.clear();
    }
  }

  void toggleTodo(int index) {
    todos[index].isDone = !todos[index].isDone;
    todos.refresh();
  }

  void removeTodo(int index) {
    todos.removeAt(index);
  }

  // 切换主题
  void changeTheme(int index) {
    currentThemeIndex.value = index;
  }

  // 更新主题
  void updateTheme() {
    Get.changeTheme(ThemeData(
      primarySwatch: createMaterialColor(themeColors[currentThemeIndex.value]),
      brightness: Brightness.light,
    ));
  }

  // 创建 MaterialColor
  MaterialColor createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }

  @override
  void onClose() {
    textEditingController.dispose();
    super.onClose();
  }
}
