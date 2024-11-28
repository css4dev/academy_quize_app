import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'add_user.dart';
import 'edit_user.dart';

class UserScreen extends StatefulWidget {
  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  List users = []; // لتخزين المستخدمين

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  // دالة لجلب المستخدمين من API
  Future<void> fetchUsers() async {
    final response = await http.get(Uri.parse('http://sawa-aid.com/quizApp/get_users.php'));
    if (response.statusCode == 200) {
      setState(() {
        users = jsonDecode(response.body);
      });
    } else {
      throw Exception('Failed to load users');
    }
  }

  // حذف مستخدم
  Future<void> deleteUser(String id) async {
    final response = await http.post(
      Uri.parse('http://sawa-aid.com/quizApp/delete_user.php'),
      body: {'id': id.toString()},
    );
    if (kDebugMode) {
      print(response.body+"jjjjhj"+id.toString());
    }
    if (response.statusCode == 200) {
      fetchUsers(); // تحديث القائمة
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Users'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => AddUserScreen())).then((value) => fetchUsers());
            },
          )
        ],
      ),
      body: users.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return ListTile(
            title: Text(user['full_name']),
            subtitle: Text(user['email']),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditUserScreen(user: user),
                      ),
                    ).then((value) => fetchUsers());
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => deleteUser(user['id']),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
