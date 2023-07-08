import 'package:flutter/material.dart';
import 'package:supabase/supabase.dart';
import 'package:intl/intl.dart';

class ChatsPage extends StatefulWidget {
  final String recipientId;

  const ChatsPage({Key? key, required this.recipientId}) : super(key: key);

  @override
  _ChatsPageState createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late SupabaseClient _supabaseClient;
  List<Map<String, dynamic>> _messages = [];
  TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _supabaseClient = SupabaseClient('https://lvpjqqiicmztxjpdbgdz.supabase.co',
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx2cGpxcWlpY216dHhqcGRiZ2R6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2ODg2MDA2NzEsImV4cCI6MjAwNDE3NjY3MX0.cF8vWd-cgMED4DM6WK19r69VM_uXrrMXb7guyDxJq7U');
    fetchMessages();
  }

  Future<void> fetchMessages() async {
    print(widget.recipientId);
    final senderId = _supabaseClient.auth.currentUser?.id;
    final response = await _supabaseClient
        .from('messages')
        .select('sender_id, receiver_id, content, created_at')
        .or(
          'sender_id.eq.$senderId,receiver_id.eq.${widget.recipientId}',
        )
        .order('created_at', ascending: true)
        .execute();

    if (response.status == 200) {
      setState(() {
        _messages =
            (response.data as List<dynamic>).cast<Map<String, dynamic>>();
      });
    } else {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch messages')),
      );
    }
  }

  Future<void> sendMessage() async {
    final messageContent = _messageController.text.trim();

    if (messageContent.isNotEmpty) {
      final senderId = _supabaseClient.auth.currentUser?.id;

      if (senderId != null) {
        final response = await _supabaseClient.from('messages').insert({
          'sender_id': senderId,
          'receiver_id': widget.recipientId,
          'content': messageContent
        }).execute();

        if (response.status == 201) {
          _messageController.clear();
          fetchMessages();
        } else {
          // Handle error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to send message')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Chat with User'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final senderId = message['sender_id'] as String;
                final messageContent = message['content'] as String;
                final createdAt =
                    DateTime.parse(message['created_at'] as String);
                final isSentMessage =
                    senderId == _supabaseClient.auth.currentUser?.id;

                return ListTile(
                  title: Text(
                    isSentMessage ? 'You' : 'User',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    messageContent,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    DateFormat('HH:mm').format(createdAt),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                    ),
                  ),
                ),
                IconButton(
                  onPressed: sendMessage,
                  icon: Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
