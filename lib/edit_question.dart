import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EditQuestionScreen extends StatefulWidget {
  final int questionId;

  EditQuestionScreen({required this.questionId});

  @override
  _EditQuestionScreenState createState() => _EditQuestionScreenState();
}

class _EditQuestionScreenState extends State<EditQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final _answer1Controller = TextEditingController();
  final _answer2Controller = TextEditingController();
  final _answer3Controller = TextEditingController();
  final _answer4Controller = TextEditingController();
  final _correctAnswerController = TextEditingController();
  final _markController = TextEditingController();

  Future<void> _fetchQuestionDetails() async {
    final response = await http.get(Uri.parse('http://your-server-path/get_question.php?id=${widget.questionId}'));

    if (response.statusCode == 200) {
      final question = json.decode(response.body);
      setState(() {
        _questionController.text = question['question_text'];
        _answer1Controller.text = question['answer1'];
        _answer2Controller.text = question['answer2'];
        _answer3Controller.text = question['answer3'];
        _answer4Controller.text = question['answer4'];
        _correctAnswerController.text = question['correct_answer'];
        _markController.text = question['mark'].toString();
      });
    } else {
      throw Exception('فشل في تحميل السؤال');
    }
  }

  Future<void> _editQuestion() async {
    final response = await http.post(
      Uri.parse('http://your-server-path/edit_question.php'),
      body: {
        'id': widget.questionId.toString(),
        'question_text': _questionController.text,
        'answer1': _answer1Controller.text,
        'answer2': _answer2Controller.text,
        'answer3': _answer3Controller.text,
        'answer4': _answer4Controller.text,
        'correct_answer': _correctAnswerController.text,
        'mark': _markController.text,
      },
    );

    if (response.statusCode == 200) {
      Navigator.pop(context);
    } else {
      throw Exception('فشل في تعديل السؤال');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchQuestionDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تعديل سؤال'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _questionController,
                decoration: InputDecoration(labelText: 'نص السؤال'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال نص السؤال';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _answer1Controller,
                decoration: InputDecoration(labelText: 'الإجابة 1'),
              ),
              TextFormField(
                controller: _answer2Controller,
                decoration: InputDecoration(labelText: 'الإجابة 2'),
              ),
              TextFormField(
                controller: _answer3Controller,
                decoration: InputDecoration(labelText: 'الإجابة 3'),
              ),
              TextFormField(
                controller: _answer4Controller,
                decoration: InputDecoration(labelText: 'الإجابة 4'),
              ),
              TextFormField(
                controller: _correctAnswerController,
                decoration: InputDecoration(labelText: 'الإجابة الصحيحة'),
              ),
              TextFormField(
                controller: _markController,
                decoration: InputDecoration(labelText: 'العلامة'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _editQuestion();
                  }
                },
                child: Text('تعديل السؤال'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
