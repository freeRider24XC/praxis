import 'package:praxis/common/models/index.dart';
import 'package:praxis/common/services/database_service.dart';
import 'package:praxis/common/services/profile_service.dart';

class ScheduleService {
  static Future<void> ensureWeeklySchedule({DateTime? anchorDate}) async {
    final now = DateTime.now();
    final reference = DateTime(
      (anchorDate ?? now).year,
      (anchorDate ?? now).month,
      (anchorDate ?? now).day,
    );
    final startOfWeek =
        reference.subtract(Duration(days: reference.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    final weeklyCapacity = ProfileService.getProfile().weeklyCapacityHours;
    final slotsPerDay = weeklyCapacity <= 3 ? 1 : weeklyCapacity <= 7 ? 2 : 3;

    final existing = DatabaseService
        .getScheduleSlotsBetween(startOfWeek, endOfWeek)
        .map((slot) => slot.todoId)
        .toSet();
    final candidates = DatabaseService.getAllTodos()
      ..removeWhere((todo) => todo.isDone || existing.contains(todo.id));
    candidates.sort((a, b) {
      final aDue = a.dueDate ?? DateTime(9999);
      final bDue = b.dueDate ?? DateTime(9999);
      final dueCompare = aDue.compareTo(bDue);
      if (dueCompare != 0) {
        return dueCompare;
      }
      return b.priority.value.compareTo(a.priority.value);
    });

    var dayCursor = startOfWeek;
    var dayCount = 0;
    var slotCount = 0;
    for (final todo in candidates.take(14)) {
      if (slotCount >= slotsPerDay) {
        dayCursor = dayCursor.add(const Duration(days: 1));
        slotCount = 0;
      }
      if (!dayCursor.isBefore(endOfWeek)) {
        break;
      }
      final start = DateTime(
        dayCursor.year,
        dayCursor.month,
        dayCursor.day,
        9 + (slotCount * 3),
      );
      final end = start.add(const Duration(hours: 1));
      await DatabaseService.addOrUpdateScheduleSlot(
        TodoScheduleSlot(
          todoId: todo.id,
          scheduledDate: dayCursor,
          scheduledStart: start,
          scheduledEnd: end,
          source: ScheduleSlotSource.ai,
        ),
      );
      slotCount += 1;
      dayCount += 1;
      if (dayCount >= 7 * slotsPerDay) {
        break;
      }
    }
  }
}
