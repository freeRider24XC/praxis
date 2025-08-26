import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:praxis/generated/l10n.dart';
import 'package:praxis/common/widgets/language_switcher.dart';
import 'package:praxis/pages/settings/settings_page.dart';

import 'index.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return const _HomeViewGetX();
  }
}

class _HomeViewGetX extends GetView<HomeController> {
  const _HomeViewGetX();

  // 主视图
  Widget _buildView() {
    final s = S.of(Get.context!);
    
    return Column(
      children: [
        Expanded(
          child: Obx(() => ListView.builder(
                itemCount: controller.todos.length,
                itemBuilder: (context, index) {
                  final todo = controller.todos[index];
                  return ListTile(
                    title: Text(todo.title),
                    leading: Checkbox(
                      value: todo.isDone,
                      onChanged: (value) => controller.toggleTodo(index),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => controller.removeTodo(index),
                    ),
                  );
                },
              )),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.textEditingController,
                  decoration: InputDecoration(
                    hintText: s.addNewTodo,
                  ),
                  onSubmitted: (_) => controller.addTodo(),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => controller.addTodo(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 抽屉视图
  Widget _buildDrawer() {
    final s = S.of(Get.context!);
    
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(Get.context!).primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.appName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  s.title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: Text(s.bottomNavHome),
            onTap: () {
              Get.back();
            },
          ),
          ListTile(
            leading: const Icon(Icons.folder),
            title: Text(s.bottomNavProjects),
            onTap: () {
              Get.back();
              // 导航到项目页面
            },
          ),
          ListTile(
            leading: const Icon(Icons.track_changes),
            title: Text(s.bottomNavGoals),
            onTap: () {
              Get.back();
              // 导航到目标页面
            },
          ),
          ListTile(
            leading: const Icon(Icons.checklist),
            title: Text(s.bottomNavTodos),
            onTap: () {
              Get.back();
              // 当前就在待办页面
            },
          ),
          ListTile(
            leading: const Icon(Icons.analytics),
            title: Text(s.bottomNavStats),
            onTap: () {
              Get.back();
              // 导航到统计页面
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(s.settings),
            onTap: () {
              Get.back();
              Get.to(() => const SettingsPage());
            },
          ),
          // 内联语言切换
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.language),
                const SizedBox(width: 32),
                Expanded(
                  child: Text(s.language),
                ),
                const LanguageSwitcher(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      init: HomeController(),
      id: "home",
      builder: (_) {
        final s = S.of(context);
        return Scaffold(
          appBar: AppBar(
            title: Text(s.todoList),
            leading: Builder(
              builder: (BuildContext context) {
                return IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                );
              },
            ),
          ),
          drawer: _buildDrawer(),
          body: SafeArea(
            child: _buildView(),
          ),
        );
      },
    );
  }
}
