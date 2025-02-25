import 'package:hive/hive.dart';

part 'category_model.g.dart'; // Run build_runner to generate adapter

@HiveType(typeId: 3) // Unique ID for this model
class Category extends HiveObject {
  @HiveField(0)
  String name;

  Category({required this.name});
}