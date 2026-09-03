import 'package:praxis/common/models/todo.dart';
import 'package:praxis/common/services/database_service.dart';

/// Page-facing Todo persistence boundary.
class TodoRepository {
  static List<Todo> getAll() => DatabaseService.getAllTodos();
  static List<Todo> getForToday() => DatabaseService.getTodosForToday();
  static List<Todo> getTopForToday({int limit = 5}) =>
      DatabaseService.getTopTodosForToday(limit: limit);
  static List<Todo> getByProject(String projectId) =>
      DatabaseService.getTodosByProject(projectId);
  static List<Todo> getByGoal(String goalId) =>
      DatabaseService.getTodosByGoal(goalId);
  static Todo? getById(String id) => DatabaseService.getTodoById(id);
  static Future<void> add(Todo todo) => DatabaseService.addTodo(todo);
  static Future<void> addAll(List<Todo> todos) =>
      DatabaseService.addTodos(todos);
  static Future<void> update(Todo todo) => DatabaseService.updateTodo(todo);
  static Future<void> delete(Todo todo) => DatabaseService.deleteTodo(todo);
}
