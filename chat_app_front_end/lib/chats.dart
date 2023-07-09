import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase/supabase.dart';

import 'constants.dart';

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
  final senderId = supabase.auth.currentSession?.user.id;

  @override
  void initState() {
    super.initState();
    _supabaseClient = SupabaseClient(
      'https://lvpjqqiicmztxjpdbgdz.supabase.co',
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx2cGpxcWlpY216dHhqcGRiZ2R6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2ODg2MDA2NzEsImV4cCI6MjAwNDE3NjY3MX0.cF8vWd-cgMED4DM6WK19r69VM_uXrrMXb7guyDxJq7U',
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchMessages();
  }

  Future<void> fetchMessages() async {
    final response1 = await _supabaseClient
        .from('messages')
        .select('sender_id, receiver_id, content, created_at')
        .filter('sender_id', 'eq', senderId)
        .filter('receiver_id', 'eq', widget.recipientId)
        .order('created_at', ascending: true)
        .execute();

    final response2 = await _supabaseClient
        .from('messages')
        .select('sender_id, receiver_id, content, created_at')
        .filter('sender_id', 'eq', widget.recipientId)
        .filter('receiver_id', 'eq', senderId)
        .order('created_at')
        .execute();

    if (response1.status == 200 && response2.status == 200) {
      setState(() {
        _messages = [
          ...(response1.data as List<dynamic>).cast<Map<String, dynamic>>(),
          ...(response2.data as List<dynamic>).cast<Map<String, dynamic>>(),
        ];
        _messages.sort((a, b) {
          final createdAtA = DateTime.parse(a['created_at'] as String);
          final createdAtB = DateTime.parse(b['created_at'] as String);
          return createdAtA.compareTo(createdAtB);
        });
      });
    } else {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch messages')),
      );
    }
  }

  Future<Map<String, dynamic>> fetchProfile(String userId) async {
    final response = await _supabaseClient
        .from('profiles')
        .select('username')
        .eq('id', userId)
        .single()
        .execute();

    if (response.status == 200) {
      return response.data as Map<String, dynamic>;
    } else {
      // Handle error
      return {};
    }
  }

  Future<void> sendMessage() async {
    final messageContent = _messageController.text;
    if (messageContent.isNotEmpty) {
      if (senderId != null) {
        final response = await _supabaseClient.from('messages').insert({
          'sender_id': senderId,
          'receiver_id': widget.recipientId,
          'content': messageContent,
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
            child: FutureBuilder(
              future: fetchProfile(widget.recipientId),
              builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasData) {
                  final profileData = snapshot.data!;
                  final recipientName = profileData['username'] as String;
                  return ListView.builder(
                    reverse: true,
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final senderId = message['sender_id'] as String;
                      final messageContent = message['content'] as String;
                      final createdAt =
                          DateTime.parse(message['created_at'] as String);
                      final isSentMessage =
                          senderId == supabase.auth.currentSession?.user.id;

                      return Align(
                        alignment: isSentMessage
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          padding: EdgeInsets.all(8),
                          margin:
                              EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          decoration: BoxDecoration(
                            color: isSentMessage
                                ? Colors.grey[300]
                                : Colors.green[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          constraints: BoxConstraints(
                              maxWidth: 350,
                              minWidth:
                                  200), // Adjust the maximum width as desired
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                DateFormat('HH:mm').format(createdAt),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black.withOpacity(0.6),
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isSentMessage ? 'You': recipientName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      messageContent,
                                      style: TextStyle(
                                        color: Colors.black,
                                      ),
                                      maxLines: null,
                                      overflow: TextOverflow.visible,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return Center(child: Text('Failed to fetch profile'));
                }
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
                      border: OutlineInputBorder(),
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
