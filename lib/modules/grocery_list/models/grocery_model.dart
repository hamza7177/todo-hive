import 'package:hive/hive.dart';

part 'grocery_model.g.dart';

@HiveType(typeId: 6)
class GroceryList extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2) // New field for starring
  bool isStarred;

  GroceryList({required this.id, required this.name, this.isStarred = false});
}

@HiveType(typeId: 7)
class GroceryItem extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int quantity;

  @HiveField(2)
  String listId;

  @HiveField(3)
  bool isCompleted;

  GroceryItem({
    required this.name,
    required this.quantity,
    required this.listId,
    this.isCompleted = false,
  });
}