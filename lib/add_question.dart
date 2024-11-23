import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddQuestionScreen extends StatefulWidget {
  final int quizId;

  const AddQuestionScreen({Key? key, required this.quizId}) : super(key: key);

  @override
  _AddQuestionScreenState createState() => _AddQuestionScreenState();
}

class _AddQuestionScreenState extends State<AddQuestionScreen> {
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _markController = TextEditingController();
  final List<TextEditingController> _answerControllers = List.generate(
    4,
        (_) => TextEditingController(),
  );

  int? _correctAnswerIndex;
  bool _isLoading = false;

  Future<void> _submitQuestion() async {
    final String questionText = _questionController.text.trim();
    final String markText = _markController.text.trim();
    final List<String> answers = _answerControllers.map((c) => c.text.trim()).toList();

    if (questionText.isEmpty || markText.isEmpty || answers.any((a) => a.isEmpty) || _correctAnswerIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يرجى ملء جميع الحقول وتحديد الإجابة الصحيحة')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // إرسال السؤال إلى الخادم
      final responseQuestion = await http.post(
        Uri.parse('https://sawa-aid.com/quizApp/add_question.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'quiz_id': widget.quizId,
          'question_text': questionText,
          'mark': int.parse(markText),
        }),
      );

      if (responseQuestion.statusCode == 200) {
        final responseData = json.decode(responseQuestion.body);

        if (responseData['status'] == 'success') {
          final int questionId = responseData['question_id'];

          // إرسال الإجابات إلى الخادم
          for (int i = 0; i < answers.length; i++) {
            await http.post(
              Uri.parse('https://sawa-aid.com/quizApp/add_answer.php'),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                'question_id': questionId,
                'answer_text': answers[i],
                'is_correct': i == _correctAnswerIndex ? 1 : 0,
              }),
            );
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('تمت إضافة السؤال والأجوبة بنجاح')),
          );
          Navigator.of(context).pop(); // العودة إلى الشاشة السابقة
        } else {
          throw Exception('فشل إضافة السؤال');
        }
      } else {
        throw Exception('فشل الاتصال بالخادم لإضافة السؤال');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: $error')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إضافة سؤال جديد'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _questionController,
                decoration: InputDecoration(
                  labelText: 'نص السؤال',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _markController,
                decoration: InputDecoration(
                  labelText: 'العلامة',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              const Text(
                'الإجابات:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Column(
                children: List.generate(
                  4,
                      (index) => Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _answerControllers[index],
                          decoration: InputDecoration(
                            labelText: 'الإجابة ${index + 1}',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      Radio<int>(
                        value: index,
                        groupValue: _correctAnswerIndex,
                        onChanged: (value) {
                          setState(() {
                            _correctAnswerIndex = value;
                          });
                        },
                      ),
                      const Text('صحيحة'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitQuestion,
                  child: Text('إضافة السؤال'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
