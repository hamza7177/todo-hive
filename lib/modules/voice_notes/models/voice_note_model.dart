// voice_note_model.dart
import 'package:hive/hive.dart';

part 'voice_note_model.g.dart';

@HiveType(typeId: 4)
class VoiceNote extends HiveObject{
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String audioPath;

  @HiveField(2)
  final DateTime createdAt;

  @HiveField(3) // New field for starred status
  bool isStarred;

  VoiceNote({
    required this.title,
    required this.audioPath,
    required this.createdAt,
    this.isStarred = false, // Default to not starred
  });
}