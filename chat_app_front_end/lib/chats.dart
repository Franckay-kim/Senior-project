import 'package:flutter/material.dart';
import 'package:pusher_client/pusher_client.dart';

void main() {
  runApp(ChatsApp());
}

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

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Message> messages = [];
  late PusherClient pusher;
  late Channel channel; // Add a nullable type

  @override
  void initState() {
    super.initState();
    _initPusher();
  }

  void _initPusher() {
    pusher = new PusherClient(
      "PUSHER_APP_KEY", // Replace with your Pusher app key
      PusherOptions(
        cluster: "PUSHER_CLUSTER", // Replace with your Pusher cluster
        encrypted: true,
      ),
    );

    channel = pusher.subscribe('chat'); // Use the null-aware operator

    channel.bind('new-message', (data) {
      // var message = Message(
      // );
      setState(() {
        //  messages.add(message);
      });
    });

    pusher.connect(); // Use the null-aware operator
  }

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
          ChatInputField(
            onSendMessage: addMessage,
            pusher: pusher,
            channel: channel,
          ),
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
  final PusherClient pusher;
  final Channel channel;

  ChatInputField(
      {required this.onSendMessage,
      required this.pusher,
      required this.channel});

  @override
  _ChatInputFieldState createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  TextEditingController textEditingController = TextEditingController();

  void _sendMessage(String messageContent) {
    if (messageContent.isNotEmpty) {
      widget.onSendMessage(Message(sender: 'Me', content: messageContent));

      // Send the message through Pusher if 'widget.pusher' is not null
      widget.channel.trigger('new-message', {
        'sender': 'Me',
        'content': messageContent,
      });

      textEditingController.clear();
    }
  }

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
              onSubmitted: _sendMessage,
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              String messageContent = textEditingController.text;
              _sendMessage(messageContent);
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

