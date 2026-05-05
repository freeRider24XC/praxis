import 'package:praxis/common/models/index.dart';
import 'package:praxis/common/services/database_service.dart';

class ProfileService {
  static UserProfile getProfile() {
    return DatabaseService.getUserProfile();
  }

  static Future<void> updateWeeklyCapacity(int hours) async {
    final profile = getProfile();
    profile.weeklyCapacityHours = hours;
    profile.updatedAt = DateTime.now();
    await DatabaseService.saveUserProfile(profile);
  }

  static Future<void> markActiveForDate(DateTime date) async {
    final profile = getProfile();
    final normalized = DateTime(date.year, date.month, date.day);
    final last = profile.lastActiveDate == null
        ? null
        : DateTime(
            profile.lastActiveDate!.year,
            profile.lastActiveDate!.month,
            profile.lastActiveDate!.day,
          );

    if (last == null) {
      profile.streakDays = 1;
    } else {
      final delta = normalized.difference(last).inDays;
      if (delta == 0) {
        // keep streak
      } else if (delta == 1) {
        profile.streakDays += 1;
      } else {
        profile.streakDays = 1;
      }
    }

    profile.lastActiveDate = normalized;
    profile.updatedAt = DateTime.now();
    await DatabaseService.saveUserProfile(profile);
  }

  static double getFocusedDomainWeeklyProgress() {
    final profile = getProfile();
    final domainId = profile.focusedDomainId;
    if (domainId == null) return 0;

    final now = DateTime.now();
    final startOfWeek = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));

    final todos = DatabaseService.getTodosByDomain(domainId).where((todo) {
      if (todo.dueDate == null) return false;
      return todo.dueDate!.isAfter(startOfWeek.subtract(const Duration(seconds: 1))) &&
          todo.dueDate!.isBefore(endOfWeek);
    }).toList();

    if (todos.isEmpty) return 0;
    final completed = todos.where((todo) => todo.isDone).length;
    return (completed / todos.length).clamp(0.0, 1.0);
  }
}
