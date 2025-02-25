import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:todo_hive/modules/voice_notes/controllers/voice_note_controller.dart';
import 'package:todo_hive/utils/app_colors.dart';

import '../../../utils/app_text_style.dart';
import '../../todo_list/widgets/todo_list_filter.dart';

class VoiceNoteListScreen extends StatelessWidget {
  VoiceNoteListScreen({super.key});

  final VoiceNoteController voiceC = Get.put(VoiceNoteController());
  final TextEditingController titleController = TextEditingController();

  void _showRecordingBottomSheet(BuildContext context) {
    Get.bottomSheet(Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title field with light grey background and rounded corners
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: 'Give a Title to your voice note',
                hintStyle: AppTextStyle.regularGrey16,
                border: InputBorder.none, // Remove default border
                focusedBorder: InputBorder.none, // Remove focused border
              ),
              style: AppTextStyle.mediumBlack16,
            ),
          ),
          const SizedBox(height: 20),
          // Recording button and timer
          Obx(
            () => Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (voiceC.isRecording.value)
                      IconButton(
                        icon: Icon(Icons.pause, color: AppColors.grey),
                        onPressed: () => voiceC.pauseRecording(),
                      ),
                    if (!voiceC.isRecording.value &&
                        voiceC.currentRecordingPath != null)
                      IconButton(
                        icon: Icon(Icons.play_arrow, color: AppColors.grey),
                        onPressed: () => voiceC.resumeRecording(),
                      ),
                    // Record/Stop button
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: voiceC.isRecording.value
                            ? AppColors.lightRed
                            : AppColors
                                .blue, // Pink when recording, blue when not
                      ),
                      child: IconButton(
                        icon: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (voiceC.isRecording.value)
                              Icon(Icons.stop,
                                  color: AppColors.white, size: 30),
                            if (!voiceC.isRecording.value)
                              Icon(Icons.mic, color: AppColors.white, size: 30),
                            if (!voiceC.isRecording.value)
                              Positioned(
                                top: 8,
                                left: 8,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        onPressed: voiceC.isRecording.value
                            ? () => voiceC.stopRecording(titleController.text)
                            : () => voiceC.startRecording(),
                        padding: EdgeInsets.zero, // Remove default padding
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Timer (mm:ss format)
                Obx(
                  () {
                    final totalSeconds = 60; // 1-minute limit
                    final elapsedSeconds =
                        voiceC.recordingProgress.value.toInt();
                    final remainingSeconds = totalSeconds - elapsedSeconds;
                    final formattedTime =
                        '${elapsedSeconds.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
                    return Text(
                      '$formattedTime/01:00', // e.g., "00:04/01:00"
                      style: AppTextStyle.mediumBlack16,
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Cancel and Done buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lightRed,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: Text(
                  'Cancel',
                  style: AppTextStyle
                      .mediumBlack16, // Assuming white text for contrast
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (voiceC.currentRecordingPath != null &&
                      titleController.text.isNotEmpty) {
                    voiceC.stopRecording(titleController.text);
                    titleController.clear();
                    Get.back();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: Text(
                  'Done',
                  style: AppTextStyle
                      .mediumBlack16, // Assuming white text for contrast
                ),
              ),
            ],
          ),
        ],
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Icon(
            Icons.arrow_back_sharp,
            color: AppColors.black,
          ),
        ),
        title: Text(
          'Voice Notes',
          style:
              AppTextStyle.mediumBlack20.copyWith(fontWeight: FontWeight.w700),
        ),
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.symmetric(horizontal: 8.0),
        //     child: Row(
        //       children: [
        //         Image.asset(
        //           'assets/images/ic_search.webp',
        //           height: 20,
        //         ),
        //         SizedBox(
        //           width: 10,
        //         ),
        //       ],
        //     ),
        //   )
        // ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your go-to tool for seamless voice recording and note-taking.',
                  style: AppTextStyle.mediumBlack16,
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Obx(() => TodoListFilter(
                            label: "All",
                            isSelected: voiceC.selectedFilter.value == "All",
                            onTap: () => voiceC.setFilter("All"),
                          )),
                      const SizedBox(width: 8.0),
                      Obx(() => TodoListFilter(
                            label: "Starred",
                            isSelected:
                                voiceC.selectedFilter.value == "Starred",
                            onTap: () => voiceC.setFilter("Starred"),
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          Expanded(
            child: Obx(
              () => voiceC.voiceNotes.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/icons/ic_voice_note.webp',
                            height: 140,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'No voice notes found!',
                            style: AppTextStyle.mediumBlack18.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Click “+” to create your voice note.',
                            style: AppTextStyle.regularBlack16,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                      itemCount: voiceC.voiceNotes.length,
                      itemBuilder: (context, index) {
                        final note = voiceC.voiceNotes[index];
                        return Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                          width: Get.width,
                          decoration: BoxDecoration(
                            color: AppColors.cardColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                note.createdAt.toString().substring(0, 16),
                                style: AppTextStyle.regularBlack12
                                    .copyWith(color: Color(0xffAEAEAE)),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      note.title,
                                      style: AppTextStyle.mediumBlack16,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  ),
                                  Spacer(),
                                  Theme(
                                    data: Theme.of(context).copyWith(
                                      popupMenuTheme: PopupMenuThemeData(
                                        color: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                    child: PopupMenuButton<String>(
                                      icon: Icon(Icons.more_vert,
                                          color: Color(0xffAFAFAF)),
                                      onSelected: (value) async {
                                        if (value == "Starred") {
                                        } else if (value == "Delete") {
                                          bool? shouldDelete =
                                              await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              backgroundColor: AppColors.white,
                                              title: Text("Delete voice note",
                                                  style: AppTextStyle
                                                      .mediumBlack16),
                                              content: Text(
                                                  "Are you sure you want to delete this voice note?",
                                                  style: AppTextStyle
                                                      .regularBlack14),
                                              actions: [
                                                ElevatedButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  style: ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          Color(0xffF0F0F0),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8))),
                                                  child: Text('No',
                                                      style: AppTextStyle
                                                          .mediumPrimary14),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(true),
                                                  style: ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          AppColors.primary,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8))),
                                                  child: Text("Yes",
                                                      style: AppTextStyle
                                                          .mediumBlack14
                                                          .copyWith(
                                                              color: AppColors
                                                                  .white)),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (shouldDelete == true) {
                                            voiceC.deleteVoiceNote(index);
                                          }
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        PopupMenuItem(
                                            value: "Starred",
                                            child: Text("Starred",
                                                style: AppTextStyle
                                                    .regularBlack16)),
                                        PopupMenuItem(
                                            value: "Delete",
                                            child: Text("Delete",
                                                style: AppTextStyle
                                                    .mediumBlack16)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                height: 43,
                                width: 93,
                                decoration: BoxDecoration(
                                  color: Color(0xffEAEAEA),
                                  borderRadius: BorderRadius.circular(66),
                                ),
                                child: Obx(
                                  () => IconButton(
                                    icon: Icon(
                                      voiceC.isPlaying.value &&
                                              voiceC.audioPlayer.audioSource
                                                  is UriAudioSource &&
                                              (voiceC.audioPlayer.audioSource
                                                          as UriAudioSource)
                                                      .uri
                                                      .path ==
                                                  note.audioPath
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                    ),
                                    onPressed: () {
                                      if (voiceC.isPlaying.value &&
                                          voiceC.audioPlayer.audioSource
                                              is UriAudioSource &&
                                          (voiceC.audioPlayer.audioSource
                                                      as UriAudioSource)
                                                  .uri
                                                  .path ==
                                              note.audioPath) {
                                        voiceC.pauseVoiceNote();
                                      } else {
                                        voiceC.playVoiceNote(note.audioPath);
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: SizedBox(
        width: 70, // Adjust size as needed
        height: 70,
        child: FloatingActionButton(
          onPressed: () => _showRecordingBottomSheet(context),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30), // Adjust for rounded shape
            child: Image.asset('assets/images/ic_voicenote-1.webp'),
          ),
        ),
      ),
    );
  }
}
