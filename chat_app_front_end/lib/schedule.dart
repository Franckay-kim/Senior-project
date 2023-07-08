import 'package:MeChat/services/profile_schedule.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SendMessagePage extends StatefulWidget {
  final String senderId;

  const SendMessagePage({Key? key, required this.senderId}) : super(key: key);
  @override
  _SendMessagePageState createState() => _SendMessagePageState();
}

class _SendMessagePageState extends State<SendMessagePage> {
  late List<ProfileSchedule> recipients;
  late List<ProfileSchedule> selectedRecipients;
  late TextEditingController messageController;
  late TextEditingController scheduleTimeController;

  final supabase = SupabaseClient('https://lvpjqqiicmztxjpdbgdz.supabase.co',
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx2cGpxcWlpY216dHhqcGRiZ2R6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2ODg2MDA2NzEsImV4cCI6MjAwNDE3NjY3MX0.cF8vWd-cgMED4DM6WK19r69VM_uXrrMXb7guyDxJq7U');

  @override
  void initState() {
    super.initState();
    recipients = [];
    selectedRecipients = [];
    messageController = TextEditingController();
    scheduleTimeController = TextEditingController();
    fetchRecipients();
  }

  Future<void> fetchRecipients() async {
    final response = await supabase.from('profiles').select().execute();
    if (response.status != 200) {
      final profiles = response.data as List<dynamic>;
      setState(() {
        recipients = profiles
            .map((profile) => ProfileSchedule(
                  id: profile['id'].toString(), // Convert the id to a string
                  username: profile['name'] as String,
                ))
            .toList();
      });
    } else {
      print('Error fetching recipients: ${Error()}');
    }
  }

  void toggleRecipient(ProfileSchedule profile) {
    setState(() {
      if (selectedRecipients.contains(profile)) {
        selectedRecipients.remove(profile);
      } else {
        selectedRecipients.add(profile);
      }
    });
  }

  Future<void> sendMessage() async {
    final recipientIds =
        selectedRecipients.map((profile) => profile.id).toList();
    final senderId = 123; // Replace with the actual sender ID
    final scheduledTime = DateTime.parse(scheduleTimeController.text);
    final content = messageController.text;

    final response = await supabase.from('schedules').insert([
      {
        'recipient_ids': recipientIds,
        'sender_id': senderId,
        'scheduled_time': scheduledTime.toIso8601String(),
        'content': content,
      }
    ]).execute();

    if (response.status != 200) {
      print('Message scheduled successfully');
    } else {
      print('Error scheduling message: ${Error()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Send Message'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Choose recipients:'),
            SizedBox(height: 8.0),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: recipients
                  .map((profile) => GestureDetector(
                        onTap: () => toggleRecipient(profile),
                        child: Chip(
                          label: Text(profile.username),
                          backgroundColor: selectedRecipients.contains(profile)
                              ? Colors.blue
                              : Colors.grey,
                        ),
                      ))
                  .toList(),
            ),
            SizedBox(height: 16.0),
            Text('Message:'),
            SizedBox(height: 8.0),
            TextField(
              controller: messageController,
              maxLines: 4,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            Text('Schedule Time:'),
            SizedBox(height: 8.0),
            TextField(
              controller: scheduleTimeController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: sendMessage,
              child: Text('Send Message'),
            ),
          ],
        ),
      ),
    );
  }
}
