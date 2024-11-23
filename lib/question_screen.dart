import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/solarized-light.dart';
import 'models.dart';
import 'api_service.dart';

class QuestionScreen extends StatefulWidget {
  final int quizId;

  QuestionScreen({required this.quizId});

  @override
  _QuestionScreenState createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  int? _selectedAnswer;
  int _totalMarks = 0;
  Map<int, int?> _userAnswers = {};
  bool examEnd = false;
  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  Future<void> fetchQuestions() async {
    final questions = await ApiService.fetchQuestions(widget.quizId);
    setState(() {
      _questions = questions;
    });
  }

  void _goToNextQuestion() {
    if (_selectedAnswer != null) {
      _userAnswers[_currentQuestionIndex] = _selectedAnswer;
      if (_selectedAnswer! + 1 ==
          _questions[_currentQuestionIndex].correctAnswer) {
        _totalMarks += _questions[_currentQuestionIndex].mark;
      }
      if (_currentQuestionIndex < _questions.length - 1) {
        setState(() {
          _currentQuestionIndex++;
          _selectedAnswer = null;
        });
      } else {
        _showResults();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار إجابة قبل المتابعة.')),
      );
    }
  }

  void _showResults() {
    setState(() {
      examEnd = true;
    });
    int totalPossibleMarks =
        _questions.fold(0, (sum, question) => sum + question.mark);
    _totalMarks=0;
for(int i=0;i<_userAnswers.length;i++){
  print(_userAnswers[i].toString()+" "+_questions[i].correctAnswer.toString()+" "+_totalMarks.toString());
  if(_userAnswers[i]!+1 ==_questions[i].correctAnswer){
    _totalMarks +=_questions[i].mark;
  }
}
    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 10),
                Text('الاختبار مكتمل'),
              ],
            ),
            content: Text(
              'إجمالي العلامات: $_totalMarks / $totalPossibleMarks',
              style: const TextStyle(fontSize: 18),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('حسناً'),
              ),
            ],
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    bool allAnswered = _userAnswers.length == _questions.length;

    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop){
        Navigator.pushReplacementNamed(context, '/quizList');

      },
      child: Directionality(
        textDirection: TextDirection.rtl, // النص من اليمين إلى اليسار
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              'أسئلة الاختبار ${widget.quizId}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Colors.white70),
            ),
            centerTitle: true,
            backgroundColor: Colors.indigo,
            elevation: 4,
          ),
          body: _questions.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                children: [
                  // Progress indicator
                  LinearProgressIndicator(
                    value: (_currentQuestionIndex + 1) / _questions.length,
                    backgroundColor: Colors.grey[300],
                    color: Colors.indigo,
                  ),
                  const SizedBox(height: 20),
                
                  // Question card
                  Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'السؤال رقم: ${_currentQuestionIndex + 1}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          buildQuestionText(
                              _questions[_currentQuestionIndex].questionText),
                          const SizedBox(height: 10),
                          Text(
                            'العلامة: ${_questions[_currentQuestionIndex].mark}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.blueGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                
                  const SizedBox(height: 20),
                
                  // Answer options
                  ListView.builder(
                  shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount:
                    _questions[_currentQuestionIndex].answers.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: RadioListTile<int>(
                          title: Text(
                            _questions[_currentQuestionIndex].answers[index],
                            textAlign: TextAlign.right,
                            style: const TextStyle(fontSize: 16),
                          ),
                          value: index,
                          groupValue: _userAnswers[_currentQuestionIndex],
                          onChanged: (value) {
                            setState(() {
                              _userAnswers[_currentQuestionIndex] = value;
                              _selectedAnswer = value;
                            });
                          },
                          controlAffinity:
                          ListTileControlAffinity.trailing, // الراديو على اليمين
                        ),
                      );
                    },
                  ),
                
                  const SizedBox(height: 20),
                
                  // Navigation buttons
                  Row(
                    children: [
                      if (_currentQuestionIndex > 0 && !examEnd)
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _currentQuestionIndex--;
                              _selectedAnswer =
                              _userAnswers[_currentQuestionIndex];
                            });
                          },
                          icon: const Icon(Icons.arrow_back_ios,color: Colors.white),
                          label: const Text('السابق',style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                          ),
                        ),
                      const Spacer(),
                      if (_currentQuestionIndex < _questions.length - 1)
                        ElevatedButton.icon(
                          onPressed: _selectedAnswer != null
                              ? _goToNextQuestion
                              : null,
                          icon: const Icon(Icons.arrow_forward_ios,color: Colors.white),
                          label: const Text('التالي',style: TextStyle(color: Colors.white),),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            _selectedAnswer != null ? Colors.indigo : Colors.grey,
                          ),
                        ),
                    ],
                  ),
                
                  const SizedBox(height: 20),
                
                  // Show results button if all questions are answered
                  if (allAnswered)
                    Center(
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await _submitQuizResults();
                          },
                          icon: const Icon(Icons.check_circle,color: Colors.white,),
                          label: const Text(
                            'إرسال النتائج وإظهار العلامة',
                            style: TextStyle(fontSize: 18,color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                            backgroundColor: Colors.indigo,
                          ),
                        ),
                      ),
                    ),
                ],
                          ),
                        ),
              ),
        ),
      ),
    );
  }

  Future<void> _submitQuizResults() async {
    setState(() {
      examEnd = true;
    });
    final apiUrl = 'https://sawa-aid.com/quizApp/submit_quize.php';

    final List<Map<String, dynamic>> answers = [];
    int fullMark = 0;  // Initialize full mark

    // Calculate the full mark based on correct answers (sum of the marks for correct answers)
    for (int i = 0; i < _questions.length; i++) {
      answers.add({
        'question_id': _questions[i].id,
        'answer_num': _userAnswers[i] != null ? _userAnswers[i]! + 1 : null,
      });

      // Add mark for correct answers
      if (_userAnswers[i] != null &&
          _userAnswers[i]! + 1 == _questions[i].correctAnswer) {
        fullMark += _questions[i].mark;
      }
    }

    final response = await ApiService.submitQuizResults(apiUrl, answers, widget.quizId, fullMark);

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      if (result['success']) {
        _showResults();
        _showMessage('تم إرسال الاختبار بنجاح!', isError: false);
      } else {
        _showMessage('فشل إرسال الاختبار. حاول مرة أخرى.', isError: true);
      }
    } else {
      _showMessage('حدث خطأ أثناء إرسال الاختبار.', isError: true);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }
  String _extractCode(String questionText) {
    final RegExp codeRegex = RegExp(r'```(.*?)```', dotAll: true);
    final match = codeRegex.firstMatch(questionText);
    if (match != null) {
      return match.group(1)!.trim(); // استخراج النص المحصور بين العلامات
    }
    return ''; // إذا لم يوجد كود، إرجاع نص فارغ
  }
  Widget buildQuestionText(String questionText) {
    final code = _extractCode(questionText); // استخراج الكود
    final normalText = questionText.replaceAll(RegExp(r'```.*?```', dotAll: true), '').trim(); // إزالة الكود

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // النص العادي
        if (normalText.isNotEmpty)
          Text(
            normalText,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.right,
          ),
        const SizedBox(height: 10),

        // النص المنسق ككود
        if (code.isNotEmpty)
          Directionality(
            textDirection: TextDirection.ltr,
            child: Container(
              width: double.infinity, // لجعل عرض الكود كاملاً
              alignment: Alignment.centerLeft, // لضبط النص إلى اليسار
              child: HighlightView(
                code,
                language: 'dart', // أو لغة أخرى
                theme: solarizedLightTheme, // اختيار الثيم
                padding: const EdgeInsets.all(12),
                textStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight:FontWeight.bold,
                  fontFamily: 'Courier New',
                ),
              ),
            ),
          ),
      ],
    );
  }
}
