import 'package:flutter_test/flutter_test.dart';
import 'package:praxis/common/models/todo.dart';
import 'package:praxis/common/services/praise_points_calculator.dart';

void main() {
  group('PraisePointsCalculator.forTodo', () {
    Todo buildTodo({
      ImportanceLevel? importance,
      DifficultyLevel? difficulty,
      TodoPriority priority = TodoPriority.medium,
    }) {
      return Todo(
        title: 't',
        importanceLevel: importance,
        difficultyLevel: difficulty,
        priority: priority,
      );
    }

    test('all medium gives base 4', () {
      final t = buildTodo();
      expect(PraisePointsCalculator.forTodo(t), 4);
    });

    test('null importance and difficulty default to medium (1.0)', () {
      final t = buildTodo(priority: TodoPriority.high);
      // 4 × 1.0 × 1.2 × 1.0 = 4.8 → round = 5
      expect(PraisePointsCalculator.forTodo(t), 5);
    });

    test('high importance × high priority × high difficulty clamps to 8', () {
      final t = buildTodo(
        importance: ImportanceLevel.high,
        difficulty: DifficultyLevel.high,
        priority: TodoPriority.urgent,
      );
      // 4 × 1.4 × 1.4 × 1.2 = 9.408 → clamp 8 → 8
      expect(PraisePointsCalculator.forTodo(t), 8);
    });

    test('low importance × low priority × low difficulty clamps to 3', () {
      final t = buildTodo(
        importance: ImportanceLevel.low,
        difficulty: DifficultyLevel.low,
        priority: TodoPriority.low,
      );
      // 4 × 0.8 × 0.9 × 0.9 = 2.592 → round = 3
      expect(PraisePointsCalculator.forTodo(t), 3);
    });

    test('urgent priority alone gives 6', () {
      final t = buildTodo(priority: TodoPriority.urgent);
      // 4 × 1.0 × 1.4 × 1.0 = 5.6 → round = 6
      expect(PraisePointsCalculator.forTodo(t), 6);
    });

    test('debugForTodo returns raw and final', () {
      final t = buildTodo(
        importance: ImportanceLevel.high,
        difficulty: DifficultyLevel.high,
        priority: TodoPriority.urgent,
      );
      final dbg = PraisePointsCalculator.debugForTodo(t);
      expect(dbg.raw, closeTo(9.408, 0.001));
      expect(dbg.finalPoints, 8);
    });

    test('constants match blueprint §11.3 / §11.4', () {
      expect(PraisePointsCalculator.todoBasePoints, 4);
      expect(PraisePointsCalculator.todoMinPoints, 2);
      expect(PraisePointsCalculator.todoMaxPoints, 8);
      expect(PraisePointsCalculator.forProject(), 2);
      expect(PraisePointsCalculator.forGoal(), 3);
      expect(PraisePointsCalculator.forReview(), 1);
    });
  });
}