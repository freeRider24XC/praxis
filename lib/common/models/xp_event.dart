import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'xp_event.g.dart';

@HiveType(typeId: 16)
class XpEvent extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late int xp;

  @HiveField(2)
  late String source;

  @HiveField(3)
  late String sourceId;

  @HiveField(4)
  String? domainId;

  @HiveField(5)
  late String description;

  @HiveField(6)
  late DateTime createdAt;

  XpEvent({
    String? id,
    required this.xp,
    required this.source,
    required this.sourceId,
    this.domainId,
    required this.description,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();
}
