import 'dart:js_interop';

import 'package:MeChat/constants.dart';
import 'package:MeChat/screens/Login/login_screen.dart';
import 'package:MeChat/users_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase/supabase.dart';
import 'package:intl/intl.dart';

import 'chats.dart';
import 'schedules_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        drawerTheme: const DrawerThemeData(scrimColor: Colors.transparent),
      ),
      title: 'Chat App',
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();

  static Route<Object?> route() {
    return MaterialPageRoute(builder: (context) => const MyHomePage());
  }
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<ScaffoldState> _globalKey = GlobalKey();

  final supabaseUrl = 'https://lvpjqqiicmztxjpdbgdz.supabase.co';
  final supabaseKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx2cGpxcWlpY216dHhqcGRiZ2R6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2ODg2MDA2NzEsImV4cCI6MjAwNDE3NjY3MX0.cF8vWd-cgMED4DM6WK19r69VM_uXrrMXb7guyDxJq7U';
  final tableName = 'messages';
  final loggedInUserId = supabase.auth.currentSession?.user.id;

  late SupabaseClient supabaseClient;
  List<Map<String, dynamic>> messages = [];
  bool hasMessages = false;

  @override
  void initState() {
    super.initState();
    supabaseClient = SupabaseClient(supabaseUrl, supabaseKey);
    fetchMessages();
  }

  Future<void> fetchMessages() async {
    final response = await supabaseClient
        .from(tableName)
        .select('sender_id, receiver_id, content, created_at')
        .or(
          'sender_id.eq.$loggedInUserId,receiver_id.eq.$loggedInUserId',
        )
        .order('created_at', ascending: false)
        .limit(10)
        .execute();

    if (response.status != 200) {
      // Handle error
      throw Error();
    } else {
      setState(() {
        messages = (response.data as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .toList();

        final latestMessage = messages.isNotEmpty ? messages[0] : null;
        final recipientId = latestMessage?['receiver_id'] as String?;
        if (messages.isNotEmpty) {
          messages[0]['recipient_id'] = recipientId ?? '';
        }
        hasMessages = messages.isNotEmpty;
      });
    }
  }

  Future<String> getUsername(String? userId) async {
    if (userId == null) {
      return 'N/A'; // Provide a fallback value when userId is null
    } else {
      final response = await supabaseClient
          .from('profiles')
          .select('username')
          .eq('id', userId)
          .execute();

      if (response.status != 200) {
        // Handle error
        throw Error();
      } else {
        final data = response.data as List<dynamic>?;
        if (data != null && data.isNotEmpty) {
          final username = data[0]['username'] as String? ?? 'Unknown';
          return username;
        } else {
          return 'Unknown'; // Fallback value when response data is null or empty
        }
      }
    }
  }

  Widget _buildMessageList() {
    if (messages.isEmpty) {
      return Center(
        child: Text(
          'No messages yet. Click on the button at the bottom left to start chatting!',
          style: TextStyle(fontSize: 18),
        ),
      );
    }
    final lastMessages = <String, Map<String, dynamic>>{};

    for (final message in messages) {
      final senderId = message['sender_id'] as String;
      final receiverId = message['receiver_id'] as String;
      final isSentMessage = senderId == loggedInUserId;
      final otherUserId = isSentMessage ? receiverId : senderId;

      final existingMessage = lastMessages[otherUserId];
      if (existingMessage == null ||
          DateTime.parse(message['created_at'] as String).isAfter(
              DateTime.parse(existingMessage['created_at'] as String))) {
        lastMessages[otherUserId] = message;
      }
    }

    final sortedMessages = lastMessages.values.toList()
      ..sort((a, b) => DateTime.parse(b['created_at'] as String)
          .compareTo(DateTime.parse(a['created_at'] as String)));

    return ListView.builder(
      padding: const EdgeInsets.only(left: 25),
      itemCount: sortedMessages.length,
      itemBuilder: (context, index) {
        final message = sortedMessages[index];
        final senderId = message['sender_id'] as String;
        final receiverId = message['receiver_id'] as String;
        final messageContent = message['content'] as String;
        final createdAt = DateTime.parse(message['created_at'] as String);
        final isSentMessage = senderId == loggedInUserId;
        final otherUserId = isSentMessage ? receiverId : senderId;

        return GestureDetector(
          onTap: () {
            final String recipientId = (receiverId == loggedInUserId)
                ? message['sender_id'] as String
                : message['receiver_id'] as String;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return ChatsPage(recipientId: recipientId);
                },
              ),
            );
          },
          child: Column(
            children: [
              ListTile(
                leading: FutureBuilder<String>(
                  future: getUsername(otherUserId),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final username = snapshot.data;
                      return CircleAvatar(
                        child: Text(username!),
                      );
                    } else if (snapshot.hasError) {
                      return Icon(Icons.error);
                    } else {
                      return CircularProgressIndicator();
                    }
                  },
                ),
                title: FutureBuilder<String>(
                  future: getUsername(otherUserId),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final username = snapshot.data!;

                      return Text(
                        isSentMessage
                            ? 'Sent to $username'
                            : 'Received from $username',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          decoration: isSentMessage
                              ? TextDecoration.none
                              : TextDecoration.none,
                        ),
                      );
                    } else {
                      return Text(
                        isSentMessage ? '' : '',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          decoration: isSentMessage
                              ? TextDecoration.none
                              : TextDecoration.none,
                        ),
                      );
                    }
                  },
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
              const Divider(
                indent: 70,
                height: 20,
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      backgroundColor: const Color.fromARGB(255, 11, 168, 92),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 70, left: 5, right: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        _globalKey.currentState!.openDrawer();
                      },
                      icon: const Icon(
                        Icons.menu,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.search,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 10),
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(
                            bottom: 10), // Add padding at the bottom
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.white,
                              width: 2.0,
                            ),
                          ),
                        ),
                        child: Hero(
                          tag: "btn7",
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return MyHomePage();
                                  },
                                ),
                              );
                            },
                            child: Text(
                              "Chats".toUpperCase(),
                              style: TextStyle(
                                color:
                                    Colors.white, // Change text color to white
                                fontSize: 20,
                                decoration:
                                    TextDecoration.none, // Remove underline
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 35,
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(
                            bottom: 10), // Add padding at the bottom
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.transparent,
                              width: 2.0,
                            ),
                          ),
                        ),
                        child: Hero(
                          tag: "btn9",
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return SchedulePage();
                                  },
                                ),
                              );
                            },
                            child: Text(
                              "Schedules".toUpperCase(),
                              style: TextStyle(
                                color:
                                    Colors.white, // Change text color to white
                                fontSize: 20,
                                decoration:
                                    TextDecoration.none, // Remove underline
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 35,
                    ),
                  ],
                ),
              )
            ],
          ),
          Positioned(
            top: 200,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40)),
                color: Color(0xFFEFFFFC),
              ),
              child: _buildMessageList(),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: SizedBox(
        height: 65,
        width: 65,
        child: FloatingActionButton(
          backgroundColor: const Color(0xFF27c1a9),
          child: const Icon(
            Icons.edit_outlined,
            size: 30,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UsersPage(),
              ),
            );
          },
        ),
      ),
      drawer: Drawer(
        width: 275,
        elevation: 30,
        backgroundColor: Color(0xF3393838),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.horizontal(right: Radius.circular(40))),
        child: Container(
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.horizontal(right: Radius.circular(40)),
              boxShadow: [
                BoxShadow(
                    color: Color(0x3D000000), spreadRadius: 30, blurRadius: 20)
              ]),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Row(
                      children: const [
                        Icon(
                          Icons.arrow_back_ios,
                          color: Color.fromRGBO(255, 255, 255, 1),
                          size: 20,
                        ),
                        SizedBox(
                          width: 56,
                        ),
                        Text(
                          'Settings',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      children: const [
                        UserAvatar(filename: 'img3.jpeg'),
                        SizedBox(
                          width: 12,
                        ),
                        Text(
                          'Tom Brenan',
                          style: TextStyle(color: Colors.white),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 35,
                    ),
                    Hero(
                      tag: "btn4",
                      child: TextButton.icon(
                        icon: Icon(Icons.account_box),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return LoginScreen();
                              },
                            ),
                          );
                        },
                        label: Text(
                          "Account".toUpperCase(),
                          style: TextStyle(
                              color: Colors.amberAccent, fontSize: 16),
                        ),
                      ),
                    ),
                    Hero(
                      tag: "btn5",
                      child: TextButton.icon(
                        icon: Icon(Icons.messenger),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return MyHomePage();
                              },
                            ),
                          );
                        },
                        label: Text(
                          "Chats".toUpperCase(),
                          style: TextStyle(
                              color: Colors.amberAccent, fontSize: 16),
                        ),
                      ),
                    ),
                    Hero(
                      tag: "btn6",
                      child: TextButton.icon(
                        icon: Icon(Icons.notification_important_rounded),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return SchedulePage();
                              },
                            ),
                          );
                        },
                        label: Text(
                          "Notifications".toUpperCase(),
                          style: TextStyle(
                              color: Colors.amberAccent, fontSize: 16),
                        ),
                      ),
                    ),
                    const Divider(
                      height: 35,
                      color: Colors.green,
                    ),
                  ],
                ),
                Hero(
                  tag: "btn3",
                  child: TextButton.icon(
                    icon: Icon(Icons.exit_to_app),
                    onPressed: () {},
                    label: Text(
                      "Logout".toUpperCase(),
                      style: TextStyle(color: Colors.amberAccent, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
