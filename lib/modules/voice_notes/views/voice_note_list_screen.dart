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
      padding: const EdgeInsets.symmetric(horizontal: 16.0,vertical: 10),
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
          SizedBox(height: 20),
          // Title field
          TextField(
            controller: titleController,
            decoration: InputDecoration(
              hintText: "Give a Title to your voice note",
              hintStyle: AppTextStyle.regularBlack16.copyWith(color: Color(0xffAFAFAF)),
              filled: true,
              fillColor: AppColors.textFieldColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
            style: AppTextStyle.regularBlack16,
          ),
          const SizedBox(height: 20),
          // Conditional content based on recording state
          Obx(
            () => voiceC.isRecording.value ||
                    voiceC.currentRecordingPath != null
                ? Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(19),
                      border: Border.all(color: Color(0xffD2D2D2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            await voiceC.cancelRecording();
                            titleController.clear();
                            Get.back();
                          },
                          child: Container(
                            height: 53,
                            width: 87,
                            decoration: BoxDecoration(
                              color: Color(0xffFEE8E8),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Text(
                                'Cancel',
                                style: AppTextStyle.mediumBlack14
                                    .copyWith(color: Color(0xffF21A18)),
                              ),
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              voiceC.isRecording.value
                                  ? 'Recording...'
                                  : 'Paused',
                              style: AppTextStyle.regularBlack14,
                            ),
                            SizedBox(height: 4),
                            Obx(
                              () {
                                const totalSeconds = 120;
                                final elapsedSeconds =
                                    voiceC.recordingProgress.value.toInt();
                                final elapsedMinutes = (elapsedSeconds ~/ 60)
                                    .toString()
                                    .padLeft(2, '0');
                                final elapsedSecs = (elapsedSeconds % 60)
                                    .toString()
                                    .padLeft(2, '0');
                                final formattedElapsed =
                                    '$elapsedMinutes:$elapsedSecs';
                                final totalMinutes = (totalSeconds ~/ 60)
                                    .toString()
                                    .padLeft(2, '0');
                                final totalSecs = (totalSeconds % 60)
                                    .toString()
                                    .padLeft(2, '0');
                                final formattedTotal =
                                    '$totalMinutes:$totalSecs';
                                return Text(
                                  '$formattedElapsed / $formattedTotal',
                                  style: AppTextStyle.regularBlack14,
                                );
                              },
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            if (voiceC.isRecording.value)
                              GestureDetector(
                                onTap: () => voiceC.pauseRecording(),
                                child: Container(
                                  height: 45,
                                  width: 45,
                                  decoration: BoxDecoration(
                                      color: AppColors.cardColor,
                                      borderRadius: BorderRadius.circular(15)),
                                  child: Center(
                                    child: Icon(Icons.pause, color: AppColors.black)
                                  ),
                                ),
                              ),

                            if (!voiceC.isRecording.value &&
                                voiceC.currentRecordingPath != null)
                            GestureDetector(
                              onTap: () => voiceC.resumeRecording(),
                              child: Container(
                                height: 45,
                                width: 45,
                                decoration: BoxDecoration(
                                    color: AppColors.cardColor,
                                    borderRadius: BorderRadius.circular(15)),
                                child: Center(
                                  child: Image.asset(
                                    'assets/icons/play.png',
                                    height: 15,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            if (voiceC.currentRecordingPath != null &&
                                titleController.text.isNotEmpty) {
                              voiceC.stopRecording(titleController.text);
                              titleController.clear();
                              Get.back();
                            }
                          },
                          child: Container(
                            height: 53,
                            width: 87,
                            decoration: BoxDecoration(
                              color: Color(0xffEFF9EF),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.check,
                                    color: Color(0xff48B02C),
                                    size: 20,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Done',
                                    style: AppTextStyle.mediumBlack14
                                        .copyWith(color: Color(0xff5EC363)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : GestureDetector(
                    onTap: voiceC.isRecording.value
                        ? () => voiceC.stopRecording(titleController.text)
                        : () => voiceC.startRecording(),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(19),
                        border: Border.all(color: Color(0xffD2D2D2)),
                      ),
                      child: Container(
                        width: Get.width * 0.9,
                        height: 53,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset('assets/icons/record_icon.png',
                                  height: 20),
                              SizedBox(width: 6),
                              Text(
                                'Record',
                                style: AppTextStyle.mediumBlack16
                                    .copyWith(color: AppColors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 20),
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
                        return Column(
                          children: [
                            Container(
                              padding: EdgeInsets.only(
                                  left: 16, bottom: 10, top: 10),
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
                                          style: AppTextStyle.mediumBlack16
                                              .copyWith(
                                                  fontWeight: FontWeight.w700),
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
                                          padding: EdgeInsets.zero,
                                          icon: Icon(Icons.more_vert,
                                              color: Color(0xffAFAFAF)),
                                          onSelected: (value) async {
                                            if (value == "Starred") {
                                              voiceC.toggleStarred(index);
                                            } else if (value == "Delete") {
                                              bool? shouldDelete =
                                                  await showDialog<bool>(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                  backgroundColor:
                                                      AppColors.white,
                                                  title: Text(
                                                      "Delete voice note",
                                                      style: AppTextStyle
                                                          .mediumBlack16),
                                                  content: Text(
                                                      "Are you sure you want to delete this voice note?",
                                                      style: AppTextStyle
                                                          .regularBlack14),
                                                  actions: [
                                                    ElevatedButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context),
                                                      style: ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              Color(0xffF0F0F0),
                                                          shape: RoundedRectangleBorder(
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
                                                          shape: RoundedRectangleBorder(
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
                                                  (voiceC.audioPlayer
                                                                  .audioSource
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
                                            voiceC
                                                .playVoiceNote(note.audioPath);
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                          ],
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
          // Resting elevation
          highlightElevation: 0,
          // Pressed elevation
          splashColor: Colors.transparent,
          // Removes ripple effect
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30), // Adjust for rounded shape
            child: Image.asset('assets/images/ic_voicenote-1.webp'),
          ),
        ),
      ),
    );
  }
}
