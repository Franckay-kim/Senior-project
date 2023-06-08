import 'package:flutter/material.dart';
import 'schedule.dart';

class ScheduledMessage {
  String message;
  List<String> recipients;
  int repetitionCount;

  ScheduledMessage({required this.message, required this.recipients, required this.repetitionCount});
}

class ScheduleScreen extends StatefulWidget {
  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  List<ScheduledMessage> scheduledMessages = [];
  TextEditingController messageController = TextEditingController();
  List<String> selectedRecipients = [];
  int repetitionCount = 1;

  void scheduleMessage() {
    if (messageController.text.isNotEmpty && selectedRecipients.isNotEmpty) {
      ScheduledMessage scheduledMessage = ScheduledMessage(
        message: messageController.text,
        recipients: List.from(selectedRecipients),
        repetitionCount: repetitionCount,
      );
      setState(() {
        scheduledMessages.add(scheduledMessage);
        messageController.clear();
        selectedRecipients.clear();
        repetitionCount = 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Schedule Messages'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
           
              ),
            TextField(
              controller: messageController,
              decoration: InputDecoration(labelText: 'Message'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Open contacts picker to select recipients
                // Code to select recipients and update 'selectedRecipients' list
              },
              child: Text('Select Recipients'),
            ),
            SizedBox(height: 16.0),
            Text(
              'Recipients: ${selectedRecipients.length}',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 16.0),
            Text(
              'Repetition Count: $repetitionCount',
              style: TextStyle(fontSize: 16.0),
            ),
            Slider(
              value: repetitionCount.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              onChanged: (value) {
                setState(() {
                  repetitionCount = value.toInt();
                });
              },
            ),
           ElevatedButton(
              onPressed: () {
                 Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return HomePage();
                  },
                ),
              );
              },
              child: Text('Schedule'),
            ),
            SizedBox(height: 16.0),
            Text(
              'Scheduled Messages:',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: scheduledMessages.length,
                itemBuilder: (context, index) {
                  ScheduledMessage message = scheduledMessages[index];
                  return ListTile(
                    title: Text(message.message),
                    subtitle: Text('Recipients: ${message.recipients.length}'),
                    trailing: Text('Repetition: ${message.repetitionCount}'),
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
