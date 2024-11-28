import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EditQuizScreen extends StatefulWidget {
  final String quizId;
  final String initialTitle;

  EditQuizScreen({required this.quizId, required this.initialTitle});

  @override
  _EditQuizScreenState createState() => _EditQuizScreenState();
}

class _EditQuizScreenState extends State<EditQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  late String title;

  @override
  void initState() {
    super.initState();
    title = widget.initialTitle;
  }

  Future<void> updateQuiz() async {
    final url = Uri.parse('http://sawa-aid.com/quizApp/edit_quiz.php');
    final response = await http.post(url, body: {
      'id': widget.quizId,
      'title': title,
    });

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Quiz updated successfully!')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to update quiz.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Quiz')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: title,
                decoration: InputDecoration(labelText: 'Quiz Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                onChanged: (value) {
                  title = value;
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    updateQuiz();
                  }
                },
                child: Text('Update Quiz'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
