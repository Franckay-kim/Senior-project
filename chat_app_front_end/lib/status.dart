// ignore_for_file: unnecessary_import

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:flutter/cupertino.dart';

class ScheduledMessage {
  final String message;
  final DateTime scheduledTime;
  final List<String> recipients;

  ScheduledMessage({
    required this.message,
    required this.scheduledTime,
    required this.recipients,
  });
}

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
        '/': (context) => HomePages(),
        //'/profile': (context) => ProfilePage(),
      },
    );
  }
}

class HomePages extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePages> {
  final TextEditingController _messageController = TextEditingController();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final List<ScheduledMessage> scheduledMessages = [];

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
        platformChannelSpecifics,
      );

      scheduledMessages.add(
        ScheduledMessage(
          message: _messageController.text,
          scheduledTime: scheduledTime,
          recipients: [], // Replace with selected recipients
        ),
      );

      _messageController.clear();

      setState(() {});
    }
  }

  void _sendScheduledMessage(ScheduledMessage scheduledMessage) {
    // Send the scheduled message to the selected recipients
    // Your implementation here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scheduler'),
      ),
      body: Center(
        child: Stack(
          children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Padding(padding: const EdgeInsets.only(top: 100,bottom: 100, left: 5, right: 5),)],
          ),
          SizedBox(
            height:50,
              child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Enter your message',
              ),
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
                      timeOfDay.minute,
                    );
                    _scheduleNotification(scheduledTime);
                  }
                }
              },
              child: Text('Schedule Message'),
            ),
            SizedBox(
              height: 20,
            child:Text(
              'Scheduled Messages:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ),
            Positioned(
              top: 250,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40)),
                  color: Colors.grey,
                ),
              child: ListView.builder(
                itemCount:scheduledMessages.length,
                itemBuilder: (context, index){
                  final ScheduledMessage = scheduledMessages[index];
                  return ListTile(
                    title: Text(ScheduledMessage.message),
                    subtitle: Text(
                      'Scheduled Time: ${ScheduledMessage.scheduledTime}',
                    ),
                    trailing: ElevatedButton(
                      onPressed: (){
                       // _sendScheduledMessage(scheduledMessage);
                      },
                      child: Text('Send'),
                    ),
                  );
                },
              ),
            ),
            )
          ],
        ),
      ),
    );
  }
  }
