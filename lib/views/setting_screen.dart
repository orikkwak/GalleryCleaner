// 파일 위치: lib/views/setting_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getlery/controllers/set_controller.dart';

class SettingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settingController = Get.put(SetController());

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Auto Delete',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Obx(() => SwitchListTile(
                    title: Text('Auto Delete Screenshots'),
                    value: settingController.isAutoDelete.value,
                    onChanged: (value) {
                      settingController.toggleAutoDelete();
                    },
                  )),
              SizedBox(height: 20),
              Text('Display Settings',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Obx(() => SwitchListTile(
                    title: Text('Dark Mode'),
                    value: settingController.isDarkMode.value,
                    onChanged: (value) {
                      settingController.toggleDarkMode();
                    },
                  )),
              SizedBox(height: 20),
              Text('Language Settings',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Obx(() => ListTile(
                    title: Text('Language'),
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
