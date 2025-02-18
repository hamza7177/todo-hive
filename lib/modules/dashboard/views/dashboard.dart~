import 'package:flutter/material.dart';
import 'package:todo_hive/modules/dashboard/widgets/dashboard_card.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_text_style.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 40),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg_homepage.webp'),
            fit: BoxFit.contain, // Ensures the image covers the screen
            alignment: Alignment.topCenter, // Moves the image to the upper side
          ),
        ),
        child: Column(
          children: [
            Row(children: [
              Text(
                "To-Do",
                style: AppTextStyle.mediumBlack16.copyWith(
                    color: AppColors.lightRed,
                    fontSize: 23,
                    fontWeight: FontWeight.w700),
              ),
              Text(
                " List",
                style: AppTextStyle.mediumBlack16
                    .copyWith(fontSize: 23, fontWeight: FontWeight.w700),
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: Image.asset(
                  'assets/images/ic_setting.webp',
                  height: 30,
                ),
              ),
            ]),
            SizedBox(
              height: 20,
            ),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DashboardCard(
                  onPressed: () {
                    print("To-Do List Pressed!");
                  },
                  text: "To-Do\nList",
                  imagePath: 'assets/images/ic_todo.webp',
                  color: AppColors.lightBlue,
                ),
                DashboardCard(
                  onPressed: () {
                    print("To-Do List Pressed!");
                  },
                  text: "Set\nReminder",
                  imagePath: 'assets/images/ic_reminder.webp',
                  color: AppColors.darkRed,
                ),
              ],
            ),
            SizedBox(height: 10,),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DashboardCard(
                  onPressed: () {
                    print("To-Do List Pressed!");
                  },
                  text: "Notepad",
                  imagePath: 'assets/images/ic_notepad.webp',
                  color: AppColors.lightGrey2,
                ),
                DashboardCard(
                  onPressed: () {
                    print("To-Do List Pressed!");
                  },
                  text: "Set\nReminder",
                  imagePath: 'assets/images/ic_voicenote.webp',
                  color: AppColors.lightYellow,
                ),
              ],
            ),
            SizedBox(height: 10,),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DashboardCard(
                  onPressed: () {
                    print("To-Do List Pressed!");
                  },
                  text: "Grocery\nList",
                  imagePath: 'assets/images/ic_grocery.webp',
                  color: AppColors.green,
                ),
                DashboardCard(
                  onPressed: () {
                    print("To-Do List Pressed!");
                  },
                  text: "Set\nReminder",
                  imagePath: 'assets/images/ic_income.webp',
                  color: AppColors.lightGreen2,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
