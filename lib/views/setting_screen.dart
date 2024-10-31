// 파일 위치: lib/views/setting_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getlery_client/controllers/set_controller.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingController = Get.put(SetController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Auto Delete',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Obx(() => SwitchListTile(
                    title: const Text('Auto Delete Screenshots'),
                    value: settingController.isAutoDelete.value,
                    onChanged: (value) {
                      settingController.toggleAutoDelete();
                    },
                  )),
              Obx(() {
                if (settingController.isAutoDelete.value) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      const Text('Select Deletion Time',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      ListTile(
                        title: Text(
                            'Delete screenshots at ${settingController.autoDeleteHours.value}:00'),
                        trailing: Icon(Icons.access_time),
                        onTap: () async {
                          final selectedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay(
                              hour: settingController.autoDeleteHours.value,
                              minute: 0,
                            ),
                          );
                          if (selectedTime != null) {
                            settingController
                                .setAutoDeleteHour(selectedTime.hour);
                          }
                        },
                      ),
                    ],
                  );
                } else {
                  return Container();
                }
              }),
              const SizedBox(height: 20),
              const Text('Notification Settings',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Obx(() => SwitchListTile(
                    title: const Text('Enable Push Notifications'),
                    value: settingController.isPushNotificationEnabled.value,
                    onChanged: (value) {
                      settingController.togglePushNotification();
                    },
                  )),
              const SizedBox(height: 20),
              const Text('Display Settings',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Obx(() => SwitchListTile(
                    title: const Text('Dark Mode'),
                    value: settingController.isDarkMode.value,
                    onChanged: (value) {
                      settingController.toggleDarkMode();
                    },
                  )),
              const SizedBox(height: 20),
              const Text('Language Settings',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Obx(() => ListTile(
                    title: const Text('Language'),
                    trailing: DropdownButton<String>(
                      value: settingController.selectedLanguage.value,
                      onChanged: (newValue) {
                        settingController.changeLanguage(newValue!);
                      },
                      items: ['en', 'ko']
                          .map<DropdownMenuItem<String>>((value) =>
                              DropdownMenuItem<String>(
                                value: value,
                                child:
                                    Text(value == 'en' ? 'English' : 'Korean'),
                              ))
                          .toList(),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
