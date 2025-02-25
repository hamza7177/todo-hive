import 'package:hive/hive.dart';

part 'voice_note_model.g.dart';

@HiveType(typeId: 4)
class VoiceNote {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String audioPath;

  @HiveField(2)
  final DateTime createdAt;

  VoiceNote({
    required this.title,
    required this.audioPath,
    required this.createdAt,
  });
}