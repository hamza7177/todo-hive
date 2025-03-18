import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:todo_hive/modules/income_and_expense/database_service/database_service.dart';
import 'package:todo_hive/modules/notes/models/note_model.dart';
import 'package:todo_hive/on_boarding_screen.dart';
import 'package:todo_hive/utils/app_colors.dart';
import 'package:workmanager/workmanager.dart';
import 'modules/dashboard/views/dashboard.dart';
import 'modules/grocery_list/models/grocery_model.dart';
import 'modules/income_and_expense/controllers/transaction_controller.dart';
import 'modules/manage_project/models/project.dart';
import 'modules/manage_project/models/task.dart';
import 'modules/notes/models/category_model.dart';
import 'modules/reminders/models/reminder_model.dart';
import 'modules/schedule_planner/models/schedule_model.dart';
import 'modules/todo_list/model/task_model.dart';
import 'modules/voice_notes/models/voice_note_model.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService().init();
  tz.initializeTimeZones();
  final prefs = await SharedPreferences.getInstance();
  final bool isFirstTime = prefs.getBool('isFirstTime') ?? true;
  // await _requestNotificationPermission();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings(
          '@mipmap/ic_launcher'); // Use your app's launcher icon

  final InitializationSettings initializationSettings = const InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  var directory = await getApplicationDocumentsDirectory();
  Hive.init(directory.path);
  //Register Adapters
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(NoteAdapter()); // Register the adapter
  Hive.registerAdapter(ReminderModelAdapter());
  Hive.registerAdapter(CategoryAdapter());
  Hive.registerAdapter(VoiceNoteAdapter());
  Hive.registerAdapter(ScheduleModelAdapter());
  Hive.registerAdapter(GroceryListAdapter()); // Registers the GroceryList adapter
  Hive.registerAdapter(GroceryItemAdapter()); // Registers the GroceryItem adapter
  Hive.registerAdapter(ProjectAdapter());
  Hive.registerAdapter(ProjectTaskAdapter());
  //Open Boxes
  await Hive.openBox<Task>('tasks');
  await Hive.openBox<Task>('completed_tasks');
  await Hive.openBox<Category>('categories');
  await Hive.openBox<Note>('notes');
  await Hive.openBox<ReminderModel>('reminders');
  await Hive.openBox<ReminderModel>('completed_reminders');
  await Hive.openBox<VoiceNote>('voiceNotes');
  await Hive.openBox<ScheduleModel>('schedules');
  await Hive.openBox<ScheduleModel>('completedSchedules');
  await Hive.openBox<GroceryList>('groceryLists');
  await Hive.openBox<GroceryItem>('groceryItems');
  await Hive.openBox<Project>('projects');
   // Workmanager().initialize(callbackDispatcher, isInDebugMode: true);

  runApp(MyApp(
    isFirstTime: isFirstTime,
  ));
}

//
// @pragma('vm:entry-point')
// void callbackDispatcher() {
//   Workmanager().executeTask((task, inputData) async {
//     try {
//       // Initialize Hive in the background isolate
//       final dir = await getApplicationDocumentsDirectory();
//       Hive.init(dir.path);
//       Hive.registerAdapter(ReminderModelAdapter());
//       final reminderBox = await Hive.openBox<ReminderModel>('reminders');
//       final completedBox = await Hive.openBox<ReminderModel>('completed_reminders');
//
//       // Background task logic
//       final reminders = reminderBox.values.toList();
//       final now = DateTime.now();
//       for (var reminder in reminders) {
//         DateTime? nextTime = calculateNextTriggerTime(reminder, now);
//         if (nextTime != null && nextTime.isBefore(now)) {
//           print("Background: Reminder ${reminder.name} time is up");
//           // Note: Notifications can't be triggered here directly without additional setup
//           if (reminder.isRepeating) {
//             // Update next trigger time for repeating reminders
//             DateTime newNextTime = calculateNextTriggerTime(reminder, now.add(const Duration(minutes: 1)))!;
//             reminderBox.put(reminder.key, reminder); // Update in Hive if needed
//           }
//         }
//       }
//       await reminderBox.close();
//       await completedBox.close();
//       return Future.value(true);
//     } catch (e) {
//       print("Background task error: $e");
//       return Future.value(false);
//     }
//   });
// }

// DateTime? calculateNextTriggerTime(ReminderModel reminder, DateTime now) {
//   if (reminder.reminderType == 'interval') {
//     int totalMinutes = (reminder.intervalHours * 60) + reminder.intervalMinutes;
//     DateTime initialTriggerTime = reminder.createdAt!.add(Duration(minutes: totalMinutes));
//     if (!reminder.isRepeating) {
//       return initialTriggerTime;
//     }
//     DateTime nextTime = initialTriggerTime;
//     while (nextTime.isBefore(now)) {
//       nextTime = nextTime.add(Duration(minutes: totalMinutes));
//     }
//     return nextTime;
//   } else if (reminder.reminderType == 'date_time') {
//     if (reminder.dateTime!.isAfter(now)) return reminder.dateTime!;
//     if (reminder.isRepeating) {
//       DateTime nextTime = reminder.dateTime!;
//       while (nextTime.isBefore(now)) {
//         nextTime = nextTime.add(const Duration(days: 1));
//       }
//       return nextTime;
//     }
//     return reminder.dateTime!;
//   } else if (reminder.reminderType == 'weekday') {
//     int targetHour = reminder.dateTime!.hour;
//     int targetMinute = reminder.dateTime!.minute;
//     for (int i = 0; i < 7; i++) {
//       int checkDay = (now.weekday + i - 1) % 7;
//       if (reminder.weekdays.contains(checkDay)) {
//         DateTime candidate = DateTime(now.year, now.month, now.day, targetHour, targetMinute).add(Duration(days: i));
//         if (candidate.isAfter(now)) return candidate;
//       }
//     }
//   }
//   return null;
// }
// Future<void> _requestNotificationPermission() async {
//   PermissionStatus status = await Permission.notification.request();
//   if (status.isDenied || status.isPermanentlyDenied) {
//     // Show a dialog or message prompting the user to enable notifications
//     print("Notification permission denied.");
//   }
// }

class MyApp extends StatelessWidget {
  final bool isFirstTime;

  MyApp({super.key, required this.isFirstTime});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return GetMaterialApp(
      builder: (context, child) {
        // Combine MediaQuery customization and EasyLoading initialization
        return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.1),
            child: child!);
      },
      debugShowCheckedModeBanner: false,
      title: 'TODO',
      theme: ThemeData(
        primaryColor: AppColors.primary,
        useMaterial3: true,
      ),
      home: isFirstTime ? const OnBoardingScreen() : const Dashboard(),
      initialBinding: BindingsBuilder(() {
        Get.put(TransactionController());
      }),
    );
  }
}
