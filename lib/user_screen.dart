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
    final response = await http.get(Uri.parse('https://sawa-aid.com/quizApp/get_users.php'));
    if (response.statusCode == 200) {
      setState(() {
        print(response.body+"Sssssaa");
        users = jsonDecode(response.body);
      });
    } else {
      throw Exception('Failed to load users');
    }
  }

  // حذف مستخدم
  Future<void> deleteUser(String id) async {
    final response = await http.post(
      Uri.parse('https://sawa-aid.com/quizApp/delete_user.php'),
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'المستخدمون',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddUserScreen()),
              ).then((value) => fetchUsers());
            },
          )
        ],
      ),
      body: users.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'لا يوجد مستخدمون',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      )
          : ListView.separated(
        itemCount: users.length,
        separatorBuilder: (_, __) => Divider(height: 1),
        itemBuilder: (context, index) {
          final user = users[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.teal,
              child: Text(
                user['full_name']![0].toUpperCase(),
                style: TextStyle(color: Colors.white),
              ),
            ),
            title: Text(
              user['full_name']!,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(user['email']!),
            trailing: Wrap(
              spacing: 8,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
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
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => deleteUser(user['id']!),
                ),
              ],
            ),
            tileColor: Colors.grey[50],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          );
        },
      ),
    );
  }
}


