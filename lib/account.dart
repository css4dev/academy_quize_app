import 'package:academy_quize_app/quiz_list_admin.dart';
import 'package:academy_quize_app/user_screen.dart';
import 'package:flutter/material.dart';

class AccountPage extends StatefulWidget {
  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  int _currentIndex = 0;

  // عناوين الصفحات
  final List<String> _titles = [
    'عرض المستخدمين',

    'عرض الاختبارات',

  ];

  // الصفحات الخاصة بالوظائف
  final List<Widget> _pages = [
    UserScreen(),
    QuizListAdminScreen(),

  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
      ),
      body: _pages[_currentIndex],
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'لوحة التحكم',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            // قائمة الصفحات
            ListTile(
              leading: Icon(Icons.people),
              title: Text('عرض المستخدمين'),
              onTap: () {
                setState(() {
                  _currentIndex = 0;
                });
                Navigator.pop(context);
              },
            ),

            Divider(),
            ListTile(
              leading: Icon(Icons.quiz),
              title: Text('عرض الاختبارات'),
              onTap: () {
                setState(() {
                  _currentIndex = 1;
                });
                Navigator.pop(context);
              },
            ),


          ],
        ),
      ),
    );
  }
}
