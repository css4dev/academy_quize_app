import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'add_question.dart';
import 'edit_question.dart';

class QuizQuestionsScreen extends StatefulWidget {
  final quizId;
  const QuizQuestionsScreen(this.quizId);
  @override
  _QuizQuestionsScreenState createState() => _QuizQuestionsScreenState();
}

class _QuizQuestionsScreenState extends State<QuizQuestionsScreen> {
  List<dynamic> questions = [];

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  // استرجاع الأسئلة من الخادم
  Future<void> _fetchQuestions() async {
    final response = await http.get(Uri.parse('https://sawa-aid.com/quizApp/get_questions.php?quiz_id=${widget.quizId}'));

    if (response.statusCode == 200) {
      setState(() {
        questions = json.decode(response.body);
      });
    } else {
      throw Exception('فشل في تحميل الأسئلة');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('أسئلة الاختبار'),
      ),
      body: ListView.builder(
        itemCount: questions.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(questions[index]['question_text']),
            subtitle: Text('العلامة: ${questions[index]['mark']}'),
            onTap: () {
              // التوجه إلى شاشة التعديل مع تمرير معرّف السؤال
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditQuestionScreen(questionId: questions[index]['id']),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // التوجه إلى شاشة إضافة سؤال
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddQuestionScreen(quizId: widget.quizId,)),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
