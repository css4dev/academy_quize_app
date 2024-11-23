import 'package:flutter/material.dart';
import 'constants.dart';
import 'question_screen.dart';
import 'models.dart';
import 'api_service.dart';

class QuizListScreen extends StatefulWidget {
  @override
  _QuizListScreenState createState() => _QuizListScreenState();
}

class _QuizListScreenState extends State<QuizListScreen> {
  List<Quiz> _quizzes = [];

  @override
  void initState() {
    super.initState();
    fetchQuizzes();
  }

  Future<void> fetchQuizzes() async {
    final quizzes = await ApiService.fetchQuizzes();
    setState(() {
      _quizzes = quizzes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'الاختبارات المتوفرة',
            style: TextStyle(fontSize: AppFontSizes.large),
          ),
          backgroundColor: AppColors.secondaryColor,
        ),
        body: ListView.builder(
          itemCount: _quizzes.length,
          itemBuilder: (context, index) {
            final quiz = _quizzes[index];

            if (quiz.userMarks != null) {
              // إذا كان لدى المستخدم علامات (اختبار مكتمل)
              return Card(
                color: AppColors.successLightColor,
                elevation: 5,
                margin: EdgeInsets.symmetric(
                  horizontal: AppMargins.horizontal,
                  vertical: AppMargins.vertical,
                ),
                child: ListTile(
                  leading: Icon(AppIcons.completedIcon, color: AppColors.successColor),
                  title: Text(
                    quiz.title,
                    style: TextStyle(
                      fontSize: AppFontSizes.large,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'العلامات: ${quiz.userMarks}',
                        style: TextStyle(fontSize: AppFontSizes.medium, color: AppColors.textColor),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'تاريخ الإنهاء: ${quiz.submittedAt}',
                        style: TextStyle(fontSize: AppFontSizes.small, color: AppColors.subtitleColor),
                      ),
                    ],
                  ),
                  trailing: Icon(AppIcons.lockIcon, color: AppColors.errorColor),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('لا يمكنك إعادة الدخول إلى هذا الاختبار.')),
                    );
                  },
                ),
              );
            } else {
              // إذا لم يتم إكمال الاختبار
              return Card(
                elevation: 5,
                margin: EdgeInsets.symmetric(
                  horizontal: AppMargins.horizontal,
                  vertical: AppMargins.vertical,
                ),
                child: ListTile(
                  leading: Icon(AppIcons.quizIcon, color: AppColors.primaryColor),
                  title: Text(
                    quiz.title,
                    style: TextStyle(
                      fontSize: AppFontSizes.large,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: Icon(AppIcons.forwardIcon, color: AppColors.primaryColor),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuestionScreen(quizId: quiz.id),
                      ),
                    );
                  },
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
