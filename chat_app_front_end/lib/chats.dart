import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Message> messages = [];

  void addMessage(Message message) {
    setState(() {
      messages.add(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: MessagesScreen(messages: messages),
          ),
          ChatInputField(onSendMessage: addMessage),
        ],
      ),
    );
  }
}

class MessagesScreen extends StatelessWidget {
  final List<Message> messages;

  MessagesScreen({required this.messages});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: messages.length,
      itemBuilder: (BuildContext context, int index) {
        return MessageTile(message: messages[index]);
      },
    );
  }
}

class MessageTile extends StatelessWidget {
  final Message message;

  MessageTile({required this.message});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(message.sender),
      subtitle: Text(message.content),
    );
  }
}

class ChatInputField extends StatefulWidget {
  final Function onSendMessage;

  ChatInputField({required this.onSendMessage});

  @override
  _ChatInputFieldState createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: textEditingController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              String messageContent = textEditingController.text;
              if (messageContent.isNotEmpty) {
                widget.onSendMessage(
                  Message(sender: 'Me', content: messageContent),
                );
                textEditingController.clear();
              }
            },
          ),
        ],
      ),
    );
  }
}

class Message {
  final String sender;
  final String content;

  Message({required this.sender, required this.content});
}

/*void main() {
  runApp(ChatsApp());
}*/

class ChatsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChatScreen(),
    );
  }
}
 