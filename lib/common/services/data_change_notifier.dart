import 'package:flutter/foundation.dart';

/// A single in-process signal for persisted workspace changes.
///
/// This is intentionally small: repositories can replace the storage layer later
/// without forcing feature pages to subscribe to Hive boxes directly.
class DataChangeNotifier {
  DataChangeNotifier._();

  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  static void notifyChange() {
    revision.value++;
  }
}
