import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'life_domain.g.dart';

@HiveType(typeId: 14)
class LifeDomain extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String icon;

  @HiveField(3)
  late String color;

  LifeDomain({
    String? id,
    required this.name,
    required this.icon,
    required this.color,
  }) : id = id ?? const Uuid().v4();

  LifeDomain copyWith({
    String? id,
    String? name,
    String? icon,
    String? color,
  }) {
    return LifeDomain(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
    );
  }
}
