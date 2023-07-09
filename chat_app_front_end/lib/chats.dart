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

  @override
  void initState() {
    super.initState();
    _supabaseClient = SupabaseClient(
      'https://lvpjqqiicmztxjpdbgdz.supabase.co',
      'YOUR_SUPABASE_API_KEY',
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchMessages();
  }

  Future<void> fetchMessages() async {
    final senderId = supabase.auth.currentSession?.user.id;

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
        .order('created_at', ascending: true)
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
    final messageContent = _messageController.text.trim();

    if (messageContent.isNotEmpty) {
      final senderId = _supabaseClient.auth.currentUser?.id;

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
                          senderId == _supabaseClient.auth.currentUser?.id;

                      return Container(
                        alignment: isSentMessage
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: ListTile(
                          title: Text(
                            isSentMessage ? 'You' : recipientName,
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
