import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_hive/utils/app_text_style.dart';

import '../../../utils/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});

  final List<SettingItem> settings = [
    SettingItem(
        image: 'assets/icons/feedback.png',
        title: "Feedback",
        subtitle: "Your feedback matters"),
    SettingItem(
        image: 'assets/icons/rate.png',
        title: "Rate us",
        subtitle: "Support our efforts — rate us today!"),
    SettingItem(
        image: 'assets/icons/share.png',
        title: "Share with others",
        subtitle: "Share this app with our friends"),
    SettingItem(
        image: 'assets/icons/privacy.png',
        title: "Privacy Policy",
        subtitle: "Our terms & conditions"),
    SettingItem(
        image: 'assets/icons/about.png',
        title: "About",
        subtitle: "Version: 1.1.20"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Icon(
            Icons.arrow_back_sharp,
            color: AppColors.black,
          ),
        ),
        title: Text(
          'Settings',
          style:
              AppTextStyle.mediumBlack18.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: AppColors.cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: settings.length,
            separatorBuilder: (context, index) =>
                Divider(color: Color(0xffEAEAEA)),
            itemBuilder: (context, index) {
              final item = settings[index];
              return Row(
                children: [
                  Container(
                    height: 42,
                    width: 42,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(11)),
                    child: Image.asset(
                      item.image,
                      height: 20,
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title,
                          style: AppTextStyle.mediumBlack16
                              .copyWith(fontWeight: FontWeight.w600)),
                      SizedBox(
                        height: 5,
                      ),
                      Text(item.subtitle,
                          style: AppTextStyle.regularBlack14
                              .copyWith(color: Color(0xff8D8D8D))),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class SettingItem {
  final String image;
  final String title;
  final String subtitle;

  SettingItem(
      {required this.image, required this.title, required this.subtitle});
}
