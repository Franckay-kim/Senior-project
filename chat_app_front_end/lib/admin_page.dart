import 'dart:math';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'constants.dart';
import 'screens/Login/login_screen.dart';

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
      home: AdminPage(),
    );
  }
}

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();

  static Route<Object?> route() {
    return MaterialPageRoute(builder: (context) => AdminPage());
  }
}

class _AdminPageState extends State<AdminPage> {
  List<Message> messages = [];
  List<Profile> profiles = [];

  @override
  void initState() {
    super.initState();
    fetchScheduledMessages();
    fetchProfiles();
  }

  Future<void> fetchScheduledMessages() async {
    final response = await supabase
        .from('schedules')
        .select()
        .order('created_at', ascending: false)
        .execute();

    if (response.status != 200) {
      throw Error();
    }

    final messagesData = response.data as List<dynamic>;
    setState(() {
      messages = messagesData.map((data) => Message.fromMap(data)).toList();
    });
  }

  Future<void> fetchProfiles() async {
    final response = await supabase.from('profiles').select().execute();

    if (response.status != 200) {
      throw Error();
    }

    final profilesData = response.data as List<dynamic>;
    setState(() {
      profiles = profilesData.map((data) => Profile.fromMap(data)).toList();
    });
  }

  Future<void> deleteMessage(String messageId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this message?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final response = await supabase
            .from('schedules')
            .delete()
            .eq('id', messageId)
            .execute();

        if (response.status != 200) {
          throw Error();
        }

        setState(() {
          messages.removeWhere((message) => message.id == messageId);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Message deleted successfully.'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (error) {
        print('Error deleting message: $error');
      }
    }
  }

  String getSenderInitials(String senderId) {
    final senderProfile =
        profiles.firstWhere((profile) => profile.id == senderId);
    final senderUsername = senderProfile.username;
    final initialsList = senderUsername.split(' ').map((word) => word[0]);
    final initials = initialsList.join('').toUpperCase();
    return initials;
  }

  Color getColorBlend(String senderId) {
    final random = Random(senderId.hashCode);
    final color = Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
    return color;
  }

  Widget buildMessageListView() {
    return ListView.builder(
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final senderInitials = getSenderInitials(message.senderId);
        final colorBlend = getColorBlend(message.senderId);

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: colorBlend,
            child: ClipOval(
              child: FutureBuilder<List<String>>(
                future: fetchRecipientNames(message.recipientIds),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    );
                  }
                  if (snapshot.hasError) {
                    return Icon(Icons.error, color: Colors.white);
                  }
                  final recipientNames = snapshot.data;
                  final formattedNames = recipientNames?.join(', ') ?? '';
                  return Text(
                    senderInitials,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
          ),
          title: Text(message.text),
          subtitle: FutureBuilder<List<String>>(
            future: fetchRecipientNames(message.recipientIds),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {}
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              final recipientNames = snapshot.data;
              final formattedNames = recipientNames?.join(', ') ?? '';
              return Text('Recipients: $formattedNames');
            },
          ),
          trailing: IconButton(
            color: Colors.red,
            icon: const Icon(Icons.delete),
            onPressed: () => deleteMessage(message.id),
          ),
        );
      },
    );
  }

  Future<List<String>> fetchRecipientNames(List<String> recipientIds) async {
    final recipientNames = <String>[];

    for (final recipientId in recipientIds) {
      final response = await supabase
          .from('profiles')
          .select('username')
          .eq('id', recipientId)
          .single()
          .execute();

      if (response.status != 200) {
        throw Error();
      }

      final recipientData = response.data as Map<String, dynamic>;
      final recipientName = recipientData['username'] as String;
      recipientNames.add(recipientName);
    }

    return recipientNames;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Page'),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              title: const Text('Manage Messages'),
              onTap: () {
                setState(() {
                  fetchScheduledMessages();
                  Navigator.pop(context);
                });
// Implement navigation to manage messages page
              },
            ),
            ListTile(
              title: const Text('Add New Users'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserManagementPage()),
                );
              },
            ),
            ListTile(
              title: const Text('Logout'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return LoginScreen();
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: buildMessageListView(),
    );
  }
}

class Message {
  final String id;
  final String text;
  final String senderId;
  final List<String> recipientIds;

  Message({
    required this.id,
    required this.text,
    required this.senderId,
    required this.recipientIds,
  });

  factory Message.fromMap(Map<String, dynamic> map) {
    final recipientIds = (map['recipient_ids'] as List<dynamic>)
        .map((id) => id.toString())
        .toList();

    return Message(
      id: map['id'] as String,
      text: map['content'] as String,
      senderId: map['sender_id'] as String,
      recipientIds: recipientIds,
    );
  }
}

class Profile {
  final String id;
  final String email;
  final String username;

  Profile({required this.id, required this.email, required this.username});

  factory Profile.fromMap(Map<String, dynamic> map) {
    final id = map['id'] as String? ?? '';
    final email = map['email'] as String? ?? '';
    final username = map['username'] as String? ?? '';
    return Profile(id: id, email: email, username: username);
  }

  static Profile empty() {
    return Profile(id: '', email: '', username: '');
  }
}

class UserManagementPage extends StatefulWidget {
  @override
  _UserManagementPageState createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  List<Profile> profiles = [];

  @override
  void initState() {
    super.initState();
    fetchProfiles();
  }

  Future<void> fetchProfiles() async {
    final response = await supabase.from('profiles').select().execute();

    if (response.status != 200) {
      throw Error();
    }

    final profilesData = response.data as List<dynamic>;
    setState(() {
      profiles = profilesData.map((data) => Profile.fromMap(data)).toList();
    });
  }

  String getInitials(String username) {
    final initialsList = username.split(' ').map((word) => word[0]);
    final initials = initialsList.join('').toUpperCase();
    return initials;
  }

  Color getRandomColor(String id) {
    final random = Random(id.hashCode);
    final color = Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
    return color;
  }

  void editUser(Profile profile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserFormPage(profile: profile),
      ),
    );
  }

  void addUser() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserFormPage(profile: Profile.empty()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
      ),
      body: ListView.builder(
        itemCount: profiles.length,
        itemBuilder: (context, index) {
          final profile = profiles[index];
          return ListTile(
            leading: CircleAvatar(
              child: Text(
                getInitials(profile.username),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: getRandomColor(profile.id),
            ),
            title: Text(profile.username),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  color: Colors.blue,
                  onPressed: () => editUser(profile),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  color: Colors.red,
                  onPressed: () => deleteUser(profile.id),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addUser,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> deleteUser(String userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final response =
            await supabase.from('profiles').delete().eq('id', userId).execute();

        if (response.status != 200) {
          throw Error();
        }

        setState(() {
          profiles.removeWhere((profile) => profile.id == userId);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User deleted successfully.'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (error) {
        print('Error deleting user: $error');
      }
    }
  }
}

class UserFormPage extends StatefulWidget {
  final Profile profile;

  UserFormPage({required this.profile});

  @override
  _UserFormPageState createState() => _UserFormPageState();
}

class _UserFormPageState extends State<UserFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.profile.email;
    _usernameController.text = widget.profile.username;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _retrieveUser() async {
    try {
      final User? user = supabase.auth.currentUser;
      if (user != null) {
        final response = await supabase
            .from('profiles')
            .select()
            .eq('id', user.id)
            .limit(1)
            .execute();
        final List<dynamic> data = response.data as List<dynamic>;
        if (data.isNotEmpty) {
          final profileData = data.first;
          final email = profileData['email'] as String;
          final username = profileData['username'] as String;
          setState(() {
            _emailController.text = email;
            _usernameController.text = username;
          });
        }
      }
    } catch (error) {
      print('Error retrieving user: $error');
      // Handle the error, show an error message, or perform other actions as needed
    }
  }

  Future<void> _addUser(String username, String password) async {
    try {
      final response = await supabase.from('profiles').insert([
        {'username': username, 'password': password}
      ]).execute();

      if (response.status != 201) {
        throw Error();
      }
    } catch (error) {
      print('Error adding user: $error');
      // Handle the error, show an error message, or perform other actions as needed
    }
  }

  Future<void> _updateUser(String username) async {
    try {
      final User? user = supabase.auth.currentUser;
      if (user != null) {
        await supabase
            .from('profiles')
            .update({'username': username})
            .eq('id', user.id)
            .execute();
      }
    } catch (error) {
      print('Error updating user: $error');
      // Handle the error, show an error message, or perform other actions as needed
    }
  }

  Future<void> _signUp(String email, String password, String username) async {
    try {
      final AuthResponse res = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'username': username},
      );
      final Session? session = res.session;
      final User? user = res.user;
      // Perform additional actions or show success message if needed
    } on AuthException catch (error) {
      print('AuthException while signing up: $error');
      // Handle the specific auth exception, show an error message, or perform other actions as needed
    } catch (error) {
      print('Error signing up: $error');
      // Handle the error, show an error message, or perform other actions as needed
    }
  }

  void saveUser() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }

    final email = _emailController.text;
    final username = _usernameController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (password != confirmPassword) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Password Mismatch'),
          content: Text('The password and confirmation do not match.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    try {
      if (widget.profile.id.isNotEmpty) {
        // Update existing user in 'profiles' table
        await _updateUser(username);
      } else {
        // Insert new user into 'profiles' table
        await _addUser(username, password);
      }

      if (email.isNotEmpty) {
        // Update user email if provided
        await _updateUser(email);
      }

      if (email.isNotEmpty && password.isNotEmpty) {
        // Perform sign up with email, password, and username
        await _signUp(email, password, username);
      }

      final updatedProfile = Profile(
        id: widget.profile.id.isNotEmpty ? widget.profile.id : '',
        email: email,
        username: username,
      );

      // Return the updated profile to the previous page
      Navigator.pop(context, updatedProfile);
    } catch (error) {
      print('Error saving user: $error');
      // Handle the error, show an error message, or perform other actions as needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.profile.id.isNotEmpty ? 'Edit User' : 'Add New User'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email.';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(labelText: 'Username'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a username.';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: 'Password'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password.';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: 'Confirm Password'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a confirmation password.';
                    }
                    return null;
                  },
                ),
              ),
              ElevatedButton(
                onPressed: saveUser,
                child: Text(
                  widget.profile.id.isNotEmpty ? 'Save Changes' : 'Add User',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
