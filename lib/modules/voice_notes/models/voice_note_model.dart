// voice_note_model.dart
import 'package:hive/hive.dart';

part 'voice_note_model.g.dart';

@HiveType(typeId: 4)
class VoiceNote extends HiveObject {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String audioPath;

  @HiveField(2)
  final DateTime createdAt;

  @HiveField(3)
  bool isStarred;

  @HiveField(4) // New field for duration in seconds
  final double duration; // Using double to match recordingProgress type

  VoiceNote({
    required this.title,
    required this.audioPath,
    required this.createdAt,
    this.isStarred = false,
    required this.duration, // Make duration required
  });
}