// ignore_for_file: unused_import

import 'package:MeChat/Screens/Login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../../schedule.dart';
<<<<<<< HEAD
import '../../../status.dart';
import '../../../chats.dart';

=======
import 'screens/Login/login_screen.dart';
//import '../../../models/status_model.dart';
>>>>>>> 04075f8bb7240d394db4865663beb295f21e4a20

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          drawerTheme: const DrawerThemeData(scrimColor: Colors.transparent)),
      title: 'Chat App',
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<ScaffoldState> _globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      backgroundColor: Color.fromARGB(255, 11, 168, 92),
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
                        )),
                    IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.search,
                          color: Colors.white,
                        )),
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
          
<<<<<<< HEAD
           Positioned(
              top: 200,
=======
          Positioned(
              top: 365,
>>>>>>> 04075f8bb7240d394db4865663beb295f21e4a20
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
            onTap: (){
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
            child:ListView(
                  padding: const EdgeInsets.only(left: 25),
                  children: [
                    buildConversationRow(
                        'Laura', 'Hello, how are you', 'img1.jpeg', 0),
                    buildConversationRow(
                        'Kalya', 'Will you visit me', 'img2.jpeg', 2),
                    buildConversationRow(
                        'Mary', 'I ate your ...', 'img3.jpeg', 6),
                    buildConversationRow(
                        'Hellen', 'Are you with Kayla again', 'img5.jpeg', 0),
                    buildConversationRow(
                        'Louren', 'Barrow money please', 'img6.jpeg', 3),
                    buildConversationRow('Tom', 'Hey, whatsup', 'img7.jpeg', 0),
                    buildConversationRow(
                        'Laura', 'Helle, how are you', 'img1.jpeg', 0),
                    buildConversationRow(
                        'Laura', 'Helle, how are you', 'img1.jpeg', 0),
                  ],
                ),
              )
            )
          )
        ]  
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
          onPressed: () {},
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
                style: TextStyle(color: Colors.amberAccent, fontSize: 16),
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
                style: TextStyle(color: Colors.amberAccent, fontSize: 16),
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
                    return HomePages();
                  },
                ),
              );
              },
              label: Text(
                "Notifications".toUpperCase(),
                style: TextStyle(color: Colors.amberAccent, fontSize: 16),
              ),
            ),
          ),
                    
                    const Divider(
                      height: 35,
                      color: Colors.green,
                    ),
                  ],
                ),
<<<<<<< HEAD
                Hero(
            tag: "btn3",
            child: TextButton.icon(
              icon: Icon(Icons.logout),
=======
                 Hero(
            tag: "btn4",
            child: TextButton(
>>>>>>> 04075f8bb7240d394db4865663beb295f21e4a20
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
<<<<<<< HEAD
              label: Text(
                "Logout".toUpperCase(),
                style: TextStyle(color:Colors.red, fontSize: 16),
=======
              child: Text(
                "logout".toUpperCase(),
                style: TextStyle(color: Colors.grey, fontSize: 20),
>>>>>>> 04075f8bb7240d394db4865663beb295f21e4a20
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
