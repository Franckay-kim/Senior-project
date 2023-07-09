import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:workmanager/workmanager.dart';

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

  final supabase = SupabaseClient(
    'https://lvpjqqiicmztxjpdbgdz.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx2cGpxcWlpY216dHhqcGRiZ2R6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2ODg2MDA2NzEsImV4cCI6MjAwNDE3NjY3MX0.cF8vWd-cgMED4DM6WK19r69VM_uXrrMXb7guyDxJq7U',
  );

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
    if (response.status == 200) {
      final profiles = response.data as List<dynamic>;
      setState(() {
        recipients = profiles
            .map((profile) => ProfileSchedule(
                  id: profile['id'].toString(), // Convert the id to a string
                  username: profile['username'] as String,
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
    final senderId = widget.senderId;
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

    if (response.status == 201) {
      showSuccessPrompt();
    } else {
      showErrorPrompt();
    }
  }

  void showSuccessPrompt() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Success'),
        content: Text('Message scheduled successfully.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void showErrorPrompt() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text('Failed to schedule message.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> selectDateTime(BuildContext context) async {
    final currentDate = DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: currentDate,
      lastDate: DateTime(currentDate.year + 1),
    );

    if (selectedDate != null) {
      final selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(currentDate),
      );

      if (selectedTime != null) {
        final selectedDateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );
        scheduleTimeController.text =
            DateFormat('yyyy-MM-dd HH:mm').format(selectedDateTime);
      }
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
            GestureDetector(
              onTap: () => selectDateTime(context),
              child: AbsorbPointer(
                child: TextFormField(
                  controller: scheduleTimeController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                ),
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

class ProfileSchedule {
  final String id;
  final String username;

  ProfileSchedule({required this.id, required this.username});
}
