import 'package:academy_quize_app/account.dart';
import 'package:flutter/material.dart';
import 'constants.dart';
import 'question_screen.dart';
import 'models.dart';
import 'api_service.dart';

class QuizListScreen extends StatefulWidget {
  const QuizListScreen({super.key});

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
          title: const Text(
            'الاختبارات المتوفرة',
            style: TextStyle(fontSize: AppFontSizes.large),
          ),
          backgroundColor: AppColors.secondaryColor,
          leading: GestureDetector(
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AccountPage()),
              );
            },
              child: Icon(Icons.manage_accounts)),
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
                margin: const EdgeInsets.symmetric(
                  horizontal: AppMargins.horizontal,
                  vertical: AppMargins.vertical,
                ),
                child: ListTile(
                  leading: const Icon(AppIcons.completedIcon, color: AppColors.successColor),
                  title: Text(
                    quiz.title,
                    style: const TextStyle(
                      fontSize: AppFontSizes.large,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'العلامات: ${quiz.userMarks}',
                        style: const TextStyle(fontSize: AppFontSizes.medium, color: AppColors.textColor),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'تاريخ الإنهاء: ${quiz.submittedAt}',
                        style: const TextStyle(fontSize: AppFontSizes.small, color: AppColors.subtitleColor),
                      ),
                    ],
                  ),
                  trailing: const Icon(AppIcons.lockIcon, color: AppColors.errorColor),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('لا يمكنك إعادة الدخول إلى هذا الاختبار.')),
                    );
                  },
                ),
              );
            } else {
              // إذا لم يتم إكمال الاختبار
              return Card(
                elevation: 5,
                margin: const EdgeInsets.symmetric(
                  horizontal: AppMargins.horizontal,
                  vertical: AppMargins.vertical,
                ),
                child: ListTile(
                  leading: const Icon(AppIcons.quizIcon, color: AppColors.primaryColor),
                  title: Text(
                    quiz.title,
                    style: const TextStyle(
                      fontSize: AppFontSizes.large,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: const Icon(AppIcons.forwardIcon, color: AppColors.primaryColor),
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
