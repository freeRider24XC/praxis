import 'package:praxis/common/models/todo.dart';

/// 计算完成行为产生的犒赏点（Praise Points）。
///
/// 蓝图中 §11.3 / §11.4 的规则：
/// - 完成事项：基础值 4 × 重要度 × 优先级 × 难度，clamp 到 [2, 8] 再 round
/// - 完成项目：固定 bonus 2
/// - 完成目标：固定 bonus 3
/// - 完成复盘：固定 bonus 1
///
/// 完成事项的三个维度若未填写（importanceLevel / difficultyLevel），
/// 默认按"中（1.0）"参与计算。
class PraisePointsCalculator {
  PraisePointsCalculator._();

  static const int todoBasePoints = 4;
  static const int todoMinPoints = 2;
  static const int todoMaxPoints = 8;

  static const int projectCompletionBonus = 2;
  static const int goalCompletionBonus = 3;
  static const int reviewCompletionBonus = 1;

  /// 完成事项时按加权公式结算。
  static int forTodo(Todo todo) {
    final importance = todo.importanceLevel?.coefficient ?? 1.0;
    final difficulty = todo.difficultyLevel?.coefficient ?? 1.0;
    final priority = todo.priority.coefficient;

    final raw = todoBasePoints * importance * priority * difficulty;
    final clamped = raw.clamp(todoMinPoints.toDouble(), todoMaxPoints.toDouble());
    return clamped.round();
  }

  /// 完成项目时的固定 bonus。
  static int forProject() => projectCompletionBonus;

  /// 完成目标时的固定 bonus。
  static int forGoal() => goalCompletionBonus;

  /// 完成每日复盘时的固定 bonus。
  static int forReview() => reviewCompletionBonus;

  /// 测试用：返回 (raw, final) 以便断言公式各步骤。
  static ({double raw, int finalPoints}) debugForTodo(Todo todo) {
    final importance = todo.importanceLevel?.coefficient ?? 1.0;
    final difficulty = todo.difficultyLevel?.coefficient ?? 1.0;
    final priority = todo.priority.coefficient;
    final raw = todoBasePoints * importance * priority * difficulty;
    return (raw: raw, finalPoints: raw.clamp(todoMinPoints.toDouble(), todoMaxPoints.toDouble()).round());
  }
}