import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/widgets/custom_flash_bar.dart';
import '../models/voice_note_model.dart';

class VoiceNoteController extends GetxController{
  var selectedFilter = "All".obs;



  late FlutterSoundRecorder _recorder;
  late AudioPlayer audioPlayer;
  RxBool isRecording = false.obs;
  RxBool isPlaying = false.obs;
  RxList<VoiceNote> voiceNotes = <VoiceNote>[].obs;
  late Box<VoiceNote> voiceBox;
  String? currentRecordingPath;
  RxDouble recordingProgress = 0.0.obs;

  StreamSubscription? _recordingProgressSubscription; // To manage the subscription

  @override
  void onInit() async {
    super.onInit();
    _recorder = FlutterSoundRecorder();
    audioPlayer = AudioPlayer();
    try {
      await _recorder.openRecorder();
      print('Recorder opened successfully');
    } catch (e) {
      print('Error opening recorder: $e');

    }
    voiceBox = await Hive.openBox<VoiceNote>('voiceNotes');
    loadVoiceNotes();
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
    loadVoiceNotes(); // Reload notes based on filter
  }

  void loadVoiceNotes() {
    final allNotes = voiceBox.values.toList();
    if (selectedFilter.value == "Starred") {
      voiceNotes.value = allNotes.where((note) => note.isStarred).toList();
    } else {
      voiceNotes.value = allNotes; // "All" filter
    }
  }

  Future<bool> checkMicrophonePermission(BuildContext context) async {
    var status = await Permission.microphone.status;
    if (status.isDenied || status.isPermanentlyDenied) {
      status = await Permission.microphone.request();
      if (status.isPermanentlyDenied) {
        CustomFlashBar.show(
          context: context,
          message: "Please enable microphone access in settings",
          isAdmin: true, // optional
          isShaking: false, // optional
          primaryColor: AppColors.primary, // optional
          secondaryColor: Colors.white, // optional
        );

        await openAppSettings();
        return false;
      }
    }
    return status.isGranted;
  }

  Future<void> startRecording(BuildContext context) async {
    try {
      print('Attempting to start recording...');
      if (await checkMicrophonePermission(context)) {
        CustomFlashBar.show(
          context: context,
          message: "Starting recording...",
          isAdmin: true, // optional
          isShaking: false, // optional
          primaryColor: AppColors.primary, // optional
          secondaryColor: Colors.white, // optional
        );
        Directory tempDir = await getTemporaryDirectory();
        String path = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.aac';
        await _recorder.startRecorder(toFile: path);
        currentRecordingPath = path;
        isRecording.value = true;
        recordingProgress.value = 0.0;

        // Cancel any existing subscription to prevent duplicates
        await _recordingProgressSubscription?.cancel();

        // Listen to progress events
        _recordingProgressSubscription = _recorder.onProgress!.listen(
              (event) {
            recordingProgress.value = event.duration.inSeconds.toDouble();
            print('Recording progress: ${recordingProgress.value} seconds');
            if (recordingProgress.value >= 60) {
              stopRecording();
            }
          },
          onError: (error) {
            print('Error in recording progress: $error');

          },
        );

        // Fallback timer (optional) to ensure progress updates even if onProgress fails
        Future.delayed(const Duration(seconds: 1), () {
          _updateProgressPeriodically();
        });
      } else {
        CustomFlashBar.show(
          context: context,
          message: "Microphone permission is required to record audio",
          isAdmin: true, // optional
          isShaking: false, // optional
          primaryColor: AppColors.primary, // optional
          secondaryColor: Colors.white, // optional
        );
      }
    } catch (e) {
      print('Error starting recording: $e');
    }
  }

  Future<void> pauseRecording() async {
    if (isRecording.value) {
      await _recorder.pauseRecorder();
      isRecording.value = false;
      _recordingProgressSubscription?.pause(); // Remove 'await' since pause() returns void
    }
  }

  Future<void> resumeRecording() async {
    if (!isRecording.value && currentRecordingPath != null) {
      await _recorder.resumeRecorder();
      isRecording.value = true;

      // Cancel any existing subscription to prevent duplicates
      await _recordingProgressSubscription?.cancel();

      // Resume listening to progress
      _recordingProgressSubscription = _recorder.onProgress!.listen(
            (event) {
          recordingProgress.value = event.duration.inSeconds.toDouble();
          print('Recording progress: ${recordingProgress.value} seconds');
          if (recordingProgress.value >= 60) {
            stopRecording();
          }
        },
        onError: (error) {
          print('Error in recording progress: $error');
        },
      );

      // Fallback timer
      Future.delayed(const Duration(seconds: 1), () {
        _updateProgressPeriodically();
      });
    }
  }

  Future<void> stopRecording([String? title]) async {
    try {
      await _recorder.stopRecorder();
      isRecording.value = false;
      double finalDuration = recordingProgress.value; // Save the duration before resetting
      recordingProgress.value = 0.0;

      // Cancel the progress subscription
      await _recordingProgressSubscription?.cancel();
      _recordingProgressSubscription = null;

      if (currentRecordingPath != null) {
        final voiceNote = VoiceNote(
          title: title ?? 'Untitled Note',
          audioPath: currentRecordingPath!,
          createdAt: DateTime.now(),
          duration: finalDuration, // Save the duration
        );

        await voiceBox.add(voiceNote);
        voiceNotes.add(voiceNote);
        currentRecordingPath = null;
      }
    } catch (e) {
      print('Error stopping recording: $e');
    }
  }

  Future<void> cancelRecording() async {
    try {
      if (isRecording.value || currentRecordingPath != null) {
        await _recorder.stopRecorder();
        isRecording.value = false;
        recordingProgress.value = 0.0;

        // Cancel the progress subscription
        await _recordingProgressSubscription?.cancel();
        _recordingProgressSubscription = null;

        // Delete the temporary file if it exists
        if (currentRecordingPath != null) {
          final file = File(currentRecordingPath!);
          if (await file.exists()) {
            await file.delete();
            print('Temporary recording file deleted: $currentRecordingPath');
          }
          currentRecordingPath = null;
        }
      }
    } catch (e) {
      print('Error cancelling recording: $e');

    }
  }

  // Fallback method to update progress periodically (1 second intervals)
  void _updateProgressPeriodically() {
    if (isRecording.value && recordingProgress.value < 60) {
      Future.delayed(const Duration(seconds: 1), () {
        recordingProgress.value += 1;
        _updateProgressPeriodically(); // Recursive call until recording stops
      });
    }
  }

  Future<void> playVoiceNote(String audioPath) async {
    try {
      await audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(audioPath)));
      isPlaying.value = true;
      await audioPlayer.play();
      audioPlayer.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          isPlaying.value = false;
        }
      });
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  Future<void> pauseVoiceNote() async {
    await audioPlayer.pause();
    isPlaying.value = false;
  }

  void deleteVoiceNote(int index) {
    voiceBox.deleteAt(index);
    voiceNotes.removeAt(index);
  }

  Future<void> toggleStarred(int index) async {
    final note = voiceBox.getAt(index);
    if (note != null) {
      note.isStarred = !note.isStarred;
      await note.save(); // Save works now because VoiceNote extends HiveObject
      loadVoiceNotes();
    }
  }
  @override
  void onClose() {
    _recorder.closeRecorder();
    audioPlayer.dispose();
    _recordingProgressSubscription?.cancel();
    super.onClose();
  }
}