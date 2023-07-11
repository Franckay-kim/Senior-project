import 'package:MeChat/schedules_page.dart';
import 'package:MeChat/screens/Login/login_screen.dart';
import 'package:MeChat/users_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase/supabase.dart';
import 'package:intl/intl.dart';

import 'messages.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chat App',
      home: const EventsPage(),
    );
  }
}

class EventsPage extends StatefulWidget {
  const EventsPage({Key? key}) : super(key: key);

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  final GlobalKey<ScaffoldState> _globalKey = GlobalKey();

  final supabaseUrl = 'https://lvpjqqiicmztxjpdbgdz.supabase.co';
  final supabaseKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx2cGpxcWlpY216dHhqcGRiZ2R6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2ODg2MDA2NzEsImV4cCI6MjAwNDE3NjY3MX0.cF8vWd-cgMED4DM6WK19r69VM_uXrrMXb7guyDxJq7U';
  final tableName = 'events';

  late SupabaseClient supabaseClient;
  List<Map<String, dynamic>> events = [];

  @override
  void initState() {
    super.initState();
    supabaseClient = SupabaseClient(supabaseUrl, supabaseKey);
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    final response = await supabaseClient
        .from(tableName)
        .select('event_name, event_date')
        .order('created_at', ascending: false)
        .limit(10)
        .execute();

    if (response.status != 200) {
      // Handle error
      throw Error();
    } else {
      setState(() {
        events = (response.data as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .toList();
      });
    }
  }

  Widget _buildEventList() {
    if (events.isEmpty) {
      return Center(
        child: Text(
          'No events',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(left: 25),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        final eventContent = event['event_name'] as String;
        final eventDate = DateTime.parse(event['event_date'] as String);

        return Column(
          children: [
            ListTile(
              leading: CircleAvatar(
                child: Text('E'),
              ),
              title: Row(
                children: [
                  Text(
                    eventContent,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${eventDate.year}/${eventDate.month}/${eventDate.day}',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Divider(
              indent: 70,
              height: 20,
            ),
          ],
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
                            bottom: 5), // Add padding at the bottom
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.transparent,
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
                      width: 20,
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(
                            bottom: 5), // Add padding at the bottom
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
                      width: 20,
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(
                            bottom: 5), // Add padding at the bottom
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.white,
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
                                    return EventsPage();
                                  },
                                ),
                              );
                            },
                            child: Text(
                              "Events".toUpperCase(),
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
                      width: 20,
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
              child: _buildEventList(),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
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
