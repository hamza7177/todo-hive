import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_hive/utils/app_colors.dart';
import 'package:todo_hive/utils/app_text_style.dart';

import 'modules/dashboard/views/dashboard.dart';


class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  PageController controller = PageController();
  int index = 0;

  final List<Map<String, String>> pages = [
    {
      'title': 'To-do and Grocery list',
      'image': 'ob_first.webp',
      'description': 'Stay organized with your daily tasks and shopping list. Keep track of everything you need to do and buy!',
    },
    {
      'title': 'Voice note & Notepad',
      'image': 'ob_second.webp',
      'description': 'Capture your ideas instantly with voice notes or jot them down in your notepad—everything in one place.',
    },
    {
      'title': 'Project & Schedule Planner',
      'image': 'ob_third.webp',
      'description': 'Plan and manage your projects and schedule with ease. Stay on top of deadlines and tasks to boost productivity.',
    },
  ];
  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false);
    Get.offAll(() => Dashboard());
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: controller,
              physics: AlwaysScrollableScrollPhysics(),
              onPageChanged: (i) {
                setState(() {
                  index = i;
                });
              },
              itemCount: pages.length,
              itemBuilder: (context, i) {
                return buildPage(pages[i]);
              },
            ),
          ),
          // Fixed Bottom Section with Buttons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Hide "Skip" button on last page
                index != pages.length - 1
                    ? ElevatedButton(
                  onPressed: () {
                    controller.animateToPage(pages.length - 1,
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOut);
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    backgroundColor: Color(0xffF0F0F0),
                  ),
                  child: Text('Skip', style: AppTextStyle.mediumPrimary14),
                )
                    : const SizedBox(width: 60), // Maintain layout spacing

                // Page Indicators
                Row(
                  children: List.generate(
                    pages.length,
                        (i) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: i == index ? 20 : 10,
                      height: 8,
                      decoration: BoxDecoration(
                        color: i == index ? AppColors.primary : Colors.grey,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),

                // "Next" or "Finish" Button
                ElevatedButton(
                  onPressed: () {
                    if (index == pages.length - 1) {
                      completeOnboarding();
                    } else {
                      controller.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOut);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    backgroundColor: AppColors.primary,
                  ),
                  child: Text(
                    index == pages.length - 1 ? "Finish" : "Next",
                    style: AppTextStyle.mediumBlack14.copyWith(color: AppColors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPage(Map<String, String> page) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          color: AppColors.lightOrange,
          height: Get.height * 0.685,
          width: double.infinity, // Ensure full width
          child: Image.asset(
            'assets/images/${page['image']}',
            fit: BoxFit.fill, // Stretch image fully
          ),
        ),

       Container(
         padding: EdgeInsets.symmetric(vertical: 10),
         decoration: BoxDecoration(
           color: AppColors.white,
           borderRadius: BorderRadius.only(
             topLeft: Radius.circular(20),
             topRight: Radius.circular(20),
           )
         ),
         child: Column(
           children: [
             Text(
               page['title']!,
               style: AppTextStyle.mediumBlack20.copyWith(
                   color: AppColors.primary, fontWeight: FontWeight.w700),
               textAlign: TextAlign.center,
             ),
             const SizedBox(height: 10),
             Padding(
               padding: const EdgeInsets.symmetric(horizontal: 30),
               child: Text(
                 page['description']!,
                 style: AppTextStyle.regularBlack14.copyWith(color: Color(0xff787A7C)),
                 textAlign: TextAlign.center,
               ),
             ),
           ],
         ),
       ),
      ],
    );
  }
}

