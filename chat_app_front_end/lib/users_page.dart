import 'package:flutter/material.dart';
import 'package:supabase/supabase.dart';

import 'chats.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({Key? key}) : super(key: key);

  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final supabaseUrl = 'https://lvpjqqiicmztxjpdbgdz.supabase.co';
  final supabaseKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx2cGpxcWlpY216dHhqcGRiZ2R6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2ODg2MDA2NzEsImV4cCI6MjAwNDE3NjY3MX0.cF8vWd-cgMED4DM6WK19r69VM_uXrrMXb7guyDxJq7U';
  final tableName = 'profiles';

  late SupabaseClient supabaseClient;
  List<Map<String, dynamic>> users = [];

  @override
  void initState() {
    super.initState();
    supabaseClient = SupabaseClient(supabaseUrl, supabaseKey);
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    final response = await supabaseClient.from(tableName).select('*').execute();

    if (response.status != 200) {
      // Handle error
      throw Error();
    } else {
      setState(() {
        users = (response.data as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .toList();
      });
    }
  }

  String getInitials(String name) {
    final names = name.split(' ');
    if (names.length > 1) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    } else {
      return '${names[0][0]}'.toUpperCase();
    }
  }

  void navigateToChatPage(String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatsPage(recipientId: userId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          final username = user['username'] as String;
          final initials = getInitials(username);

          return ListTile(
            onTap: () => navigateToChatPage(user['id'] as String),
            leading: CircleAvatar(
              child: Text(
                initials,
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.blueGrey,
            ),
            title: Text(username),
          );
        },
      ),
    );
  }
}
