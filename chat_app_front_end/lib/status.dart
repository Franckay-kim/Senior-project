import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ScheduledMessage {
  final String message;
  final DateTime scheduledTime;
  List<String> recipients;

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
       // '/recipientSelection': (context) => RecipientSelectionPage(),
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
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
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

  Future<void> _selectRecipients(ScheduledMessage scheduledMessage) async {
    final List<String>? selectedRecipients = await Navigator.pushNamed(
      context,
      '/recipientSelection',
      arguments: scheduledMessage.recipients,
    );

    if (selectedRecipients != null) {
      scheduledMessage.recipients = selectedRecipients;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scheduler'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 50,
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
            SizedBox(height: 20),
            Text(
              'Scheduled Messages:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: scheduledMessages.length,
                itemBuilder: (context, index) {
                  final scheduledMessage = scheduledMessages[index];
                  return ScheduledMessageTile(
                    scheduledMessage: scheduledMessage,
                    onSend: () {
                      _sendScheduledMessage(scheduledMessage);
                    },
                    onSelectRecipients: () {
                      _selectRecipients(scheduledMessage);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ScheduledMessageTile extends StatelessWidget {
  final ScheduledMessage scheduledMessage;
  final VoidCallback onSend;
  final VoidCallback onSelectRecipients;

  const ScheduledMessageTile({
    required this.scheduledMessage,
    required this.onSend,
    required this.onSelectRecipients,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: ListTile(
        title: Text(scheduledMessage.message),
        subtitle: Text(
          'Scheduled Time: ${scheduledMessage.scheduledTime}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              child: ElevatedButton(
                onPressed: onSelectRecipients,
                child: Text('Recipients'),
              ),
            ),
            SizedBox(width: 8),
            Container(
              width: 80,
              child: ElevatedButton(
                onPressed: onSend,
                child: Text('Send'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RecipientSelectionPage extends StatefulWidget {
  final List<String> selectedRecipients;

  RecipientSelectionPage({required this.selectedRecipients});

  @override
  _RecipientSelectionPageState createState() => _RecipientSelectionPageState();
}

class _RecipientSelectionPageState extends State<RecipientSelectionPage> {
  List<String> recipients = [];

  @override
  void initState() {
    super.initState();
    recipients = List.from(widget.selectedRecipients);
  }

  void _toggleRecipient(String recipient) {
    if (recipients.contains(recipient)) {
      recipients.remove(recipient);
    } else {
      recipients.add(recipient);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Recipients'),
      ),
      body: ListView.builder(
        itemCount: recipients.length,
        itemBuilder: (context, index) {
          final recipient = recipients[index];
          return ListTile(
            title: Text(recipient),
            trailing: Checkbox(
              value: widget.selectedRecipients.contains(recipient),
              onChanged: (selected) => _toggleRecipient(recipient),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context, recipients);
        },
        child: Icon(Icons.check),
      ),
    );
  }
}
