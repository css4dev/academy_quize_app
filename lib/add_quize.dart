import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class QuizManagementScreen extends StatefulWidget {
  final int userId; // معرف المستخدم

  const QuizManagementScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _QuizManagementScreenState createState() => _QuizManagementScreenState();
}

class _QuizManagementScreenState extends State<QuizManagementScreen> {
  List<Map<String, dynamic>> quizzes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchQuizzes();
  }

  // دالة لجلب الاختبارات
  Future<void> _fetchQuizzes() async {
    try {
      final response = await http.get(
        Uri.parse('https://sawa-aid.com/quizApp/get_quizzes.php?user_id=${widget.userId}'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        setState(() {
          quizzes = jsonData.map((quiz) => quiz as Map<String, dynamic>).toList();
          isLoading = false;
        });
      } else {
        throw Exception('فشل تحميل قائمة الاختبارات');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء تحميل الاختبارات: $error')),
      );
    }
  }

  // دالة لإضافة اختبار جديد
  Future<void> _addNewQuiz() async {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('إضافة اختبار جديد'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'عنوان الاختبار'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'وصف الاختبار'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                final String title = titleController.text.trim();
                final String description = descriptionController.text.trim();

                if (title.isEmpty || description.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('يرجى ملء جميع الحقول')),
                  );
                  return;
                }

                Navigator.of(context).pop(); // إغلاق مربع الحوار
                _submitNewQuiz(title, description);
              },
              child: Text('إضافة'),
            ),
          ],
        );
      },
    );
  }

  // دالة إرسال اختبار جديد إلى الخادم
  Future<void> _submitNewQuiz(String title, String description) async {
    try {
      final response = await http.post(
        Uri.parse('https://sawa-aid.com/quizApp/add_quiz.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'title': title,
          'description': description,
          'user_id': widget.userId,
        }),
      );

      if (response.statusCode == 200) {
        _fetchQuizzes(); // إعادة تحميل قائمة الاختبارات
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تمت إضافة الاختبار بنجاح')),
        );
      } else {
        throw Exception('فشل إضافة الاختبار');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء إضافة الاختبار: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إدارة الاختبارات'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : quizzes.isEmpty
          ? Center(child: Text('لا يوجد اختبارات حتى الآن'))
          : ListView.builder(
        itemCount: quizzes.length,
        itemBuilder: (context, index) {
          final quiz = quizzes[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text(quiz['title'] ?? 'بدون عنوان'),
              subtitle: Text(quiz['description'] ?? 'بدون وصف'),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                // التنقل إلى شاشة تفاصيل الاختبار
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewQuiz,
        child: Icon(Icons.add),
        tooltip: 'إضافة اختبار جديد',
      ),
    );
  }
}
