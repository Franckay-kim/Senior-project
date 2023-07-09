// ignore_for_file: unused_import

import 'package:MeChat/constants.dart';
import 'package:MeChat/messages.dart';
import 'package:MeChat/schedule.dart';
import 'package:MeChat/screens/Login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase/supabase.dart';
import 'package:intl/intl.dart';

import 'chats.dart';
import 'status.dart';

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
      home: const SchedulePage(),
    );
  }
}

class SchedulePage extends StatefulWidget {
  const SchedulePage({Key? key}) : super(key: key);

  @override
  State<SchedulePage> createState() => _SchedulePageState();

  static Route<Object?> route() {
    return MaterialPageRoute(builder: (context) => const SchedulePage());
  }
}

class _SchedulePageState extends State<SchedulePage> {
  final GlobalKey<ScaffoldState> _globalKey = GlobalKey();

  final supabaseUrl = 'https://lvpjqqiicmztxjpdbgdz.supabase.co';
  final supabaseKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx2cGpxcWlpY216dHhqcGRiZ2R6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2ODg2MDA2NzEsImV4cCI6MjAwNDE3NjY3MX0.cF8vWd-cgMED4DM6WK19r69VM_uXrrMXb7guyDxJq7U';
  final tableName = 'schedules';
  final loggedInUserId = supabase.auth.currentSession?.user.id ?? '';

  late SupabaseClient supabaseClient;
  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    supabaseClient = SupabaseClient(supabaseUrl, supabaseKey);
    fetchMessages();
  }

  Future<void> fetchMessages() async {
    print(loggedInUserId);
    final response = await supabaseClient
        .from('schedules')
        .select('id,sender_id,recipient_ids,scheduled_time,content, delivered,created_at')
        .execute();

    if (response.status != 200) {
      // Handle error
      throw Error();
    } else {
      setState(() {
        messages = (response.data as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .toList();
      });
    }
  }

  Future<String> getSenderInitials(String senderId) async {
    print(senderId);
    // ignore: unnecessary_null_comparison
    if (senderId == null) {
      return 'N/A'; // Provide a fallback value when senderId is null
    }

    final response = await supabaseClient
        .from('profiles')
        .select('username')
        .eq('id', loggedInUserId)
        .execute();

    if (response.status != 200) {
      // Handle error
      throw Error();
    } else {
      final username = response.data?[0]['username'] as String? ?? 'Unknown';
      print(username);
      if (username.isNotEmpty) {
        final initials = username.trim().split(' ').map((e) => e[0]).join('');
        return initials.toUpperCase();
      } else {
        return 'N/A'; // Fallback value for initials when username is null or empty
      }
    }
  }

  Widget _buildMessageList() {
    return ListView.builder(
      padding: const EdgeInsets.only(left: 25),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final senderId = message['sender_id'] as String;
        final messageContent = message['content'] as String;
        final createdAt = DateTime.parse(message['created_at'] as String);
        final isSentMessage = senderId == loggedInUserId;

        final isDelivered = createdAt.isBefore(DateTime.now());

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return SendMessagePage(senderId: loggedInUserId);
                },
              ),
            );
          },
          child: Column(
            children: [
              ListTile(
                leading: FutureBuilder<String>(
                  future: getSenderInitials(senderId),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return CircleAvatar(
                        child: Text(snapshot.data ?? ''),
                      );
                    } else if (snapshot.hasError) {
                      return Icon(Icons.error);
                    } else {
                      return CircularProgressIndicator();
                    }
                  },
                ),
                title: Text(
                  isSentMessage ? 'Sent to ' : 'Received from',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  messageContent,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: isDelivered ? Text('Delivered') : null,
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
                    Hero(
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
                          style: TextStyle(color: Colors.amber, fontSize: 20),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 35,
                    ),
                    /*Hero(
            tag: "btn8",
            child: TextButton(
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
              child: Text(
                "Scheduler".toUpperCase(),
                style: TextStyle(color: Colors.amber, fontSize: 20),
              ),
            ),
          ),*/
                    Hero(
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
                          style: TextStyle(color: Colors.amber, fontSize: 20),
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
                builder: (context) {
                  return SendMessagePage(senderId: loggedInUserId);
                },
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
                                return MyHomePage();
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
                    icon: Icon(Icons.logout),
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
                      "Logout".toUpperCase(),
                      style: TextStyle(color: Colors.red, fontSize: 16),
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

  Column buildConversationRow(
      String name, String message, String filename, int msgCount) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                UserAvatar(filename: filename),
                const SizedBox(
                  width: 15,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      message,
                      style: const TextStyle(color: Colors.black),
                    ),
                  ],
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: 25, top: 5),
              child: Column(
                children: [
                  const Text(
                    '16:35',
                    style: TextStyle(fontSize: 10),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  if (msgCount > 0)
                    CircleAvatar(
                      radius: 7,
                      backgroundColor: Colors.green,
                      child: Text(
                        msgCount.toString(),
                        style:
                            const TextStyle(fontSize: 10, color: Colors.white),
                      ),
                    )
                ],
              ),
            )
          ],
        ),
        const Divider(
          indent: 70,
          height: 20,
        )
      ],
    );
  }

  Padding buildContactAvatar(String name, String filename) {
    return Padding(
      padding: const EdgeInsets.only(right: 20.0),
      child: Column(
        children: [
          UserAvatar(
            filename: filename,
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            name,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          )
        ],
      ),
    );
  }
}

class DrawerItem extends StatelessWidget {
  final String title;
  final IconData icon;
  const DrawerItem({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.only(bottom: 25),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(
              width: 40,
            ),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class UserAvatar extends StatelessWidget {
  final String filename;
  const UserAvatar({
    super.key,
    required this.filename,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 32,
      backgroundColor: Colors.blueGrey,
      child: CircleAvatar(
        radius: 29,
        backgroundImage: Image.asset('assets/images/$filename').image,
      ),
    );
  }
}
