import 'dart:convert';
import 'package:academy_quize_app/qustions_admin.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'add_quiz.dart';
import 'edit_quiz.dart';

class QuizListAdminScreen extends StatefulWidget {
  @override
  _QuizListAdminScreenState createState() => _QuizListAdminScreenState();
}

class _QuizListAdminScreenState extends State<QuizListAdminScreen> {
  List quizzes = [];

  @override
  void initState() {
    super.initState();
    fetchQuizzes();
  }

  // دالة لجلب البيانات من API
  Future<void> fetchQuizzes() async {
    final url = Uri.parse('https://sawa-aid.com/quizApp/get_quizzes_admin.php');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        quizzes = json.decode(response.body);
      });
    } else {
      print('Failed to load quizzes');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quizzes List'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: ()async {
              final prefs = await SharedPreferences.getInstance();
              // Check if the user is logged in by checking a flag or token
              int? userId = prefs.getInt('user_id') ;

              if(userId==1) {
                Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddQuizScreen()),
              ).then((_) => fetchQuizzes());
              }
            },
          )
        ],
      ),
      body: quizzes.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: quizzes.length,
        itemBuilder: (context, index) {
          final quiz = quizzes[index];
          return GestureDetector(
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuizQuestionsScreen(
                      quiz['id']
                  ),
                ),
              );
            },
            child: ListTile(
              title: Text(quiz['title']),
              subtitle: Text(quiz['created_at']),
              trailing: IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditQuizScreen(
                        quizId: quiz['id'],
                        initialTitle: quiz['title'],
                      ),
                    ),
                  ).then((_) => fetchQuizzes());
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
