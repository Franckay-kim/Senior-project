// ignore_for_file: unused_import

import 'package:MeChat/constants.dart';
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
        .order('created_at', ascending: false)
        .limit(1)
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
    print(loggedInUserId);
    // ignore: unnecessary_null_comparison
    if (senderId == null) {
      return 'N/A'; // Provide a fallback value when senderId is null
    }

    final response = await supabaseClient
        .from('profiles')
        .select('username')
        .eq('id', senderId)
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
                                return HomePages();
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
              child: GestureDetector(
                onTap: () {
                  // Navigate to a new screen when an item is tapped
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return ChatsApp();
                      },
                    ),
                  );
                },
                child: ListView.builder(
                  padding: const EdgeInsets.only(left: 25),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final senderId = message['sender_id'] as String;
                    final receiverId = message['receiver_id'] as String;
                    final messageContent = message['content'] as String;
                    final createdAt =
                        DateTime.parse(message['created_at'] as String);
                    final isSentMessage = senderId == loggedInUserId;
                    final otherUserId = isSentMessage ? receiverId : senderId;

                    return Column(
                      children: [
                        ListTile(
                          leading: FutureBuilder<String>(
                            future: getSenderInitials(otherUserId),
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
                            isSentMessage ? 'Sent to' : 'Received from',
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
                        const Divider(
                          indent: 70,
                          height: 20,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
