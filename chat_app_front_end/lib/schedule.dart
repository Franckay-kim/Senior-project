// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Messaging App',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        //'/profile': (context) => ProfilePage(),
      },
    );
  }
}



class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _messageController = TextEditingController();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: AndroidInitializationSettings('@mipmap/ic_launcher'));
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }


  Future<void> _scheduleNotification(DateTime scheduledTime) async {
    if (_messageController.text.isNotEmpty && scheduledTime != true) {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        '1',
        'Messaging App',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: false,
      );
      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);
      flutterLocalNotificationsPlugin.schedule(
          0,
          'Messaging App',
          _messageController.text,
          scheduledTime,
          platformChannelSpecifics);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scheduler'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Enter your message',
              ),
            ),
             SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2025),
                );
                if (picked != null) {
                  final TimeOfDay? timeOfDay = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (timeOfDay != null) {
                    final DateTime scheduledTime = DateTime(
                        picked.year,
                        picked.month,
                        picked.day,
                        timeOfDay.hour,
                        timeOfDay.minute);
                    _scheduleNotification(scheduledTime);
                     }
                }
              },
              child: Text('Schedule Message'),
            ),
          ],
        ),
      ),
    );
  }
}
