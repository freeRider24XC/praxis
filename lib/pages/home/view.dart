import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:praxis/generated/l10n.dart';

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
                  decoration: const InputDecoration(
                    hintText: '添加新的待办事项',
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
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(Get.context!).primaryColor,
            ),
            child: Text(
              S.of(Get.context!).appName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.note),
            title: Text(S.of(Get.context!).notes),
            onTap: () {
              // 处理笔记功能
              Get.back();
            },
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(S.of(Get.context!).language),
            onTap: () {
              // 处理语言切换功能
              Get.back();
            },
          ),
          ExpansionTile(
            leading: const Icon(Icons.color_lens),
            title: Text(S.of(Get.context!).theme),
            children: List.generate(
              controller.themeColors.length,
              (index) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: controller.themeColors[index],
                ),
                title: Text(controller.themeNames[index]),
                onTap: () {
                  controller.changeTheme(index);
                  Get.back();
                },
              ),
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
        return Scaffold(
          appBar: AppBar(
            title: Text(S.of(context).todoList),
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
