import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

class ApiService {
  static Future<List<Quiz>> fetchQuizzes() async {
    final prefs = await SharedPreferences.getInstance();
    // Check if the user is logged in by checking a flag or token
    int? userId = prefs.getInt('user_id') ;
    final response = await http.get(Uri.parse('https://sawa-aid.com/quizApp/get_quizzes.php?user_id=$userId'));
    if (response.statusCode == 200) {
      if (kDebugMode) {
        print("${response.body}sssss");
      }
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((quiz) => Quiz.fromJson(quiz)).toList();
    } else {
      throw Exception('فشل تحميل قائمة الاختبارات');
    }
  }

  static Future<List<Question>> fetchQuestions(int quizId) async {
    final response = await http.get(
      Uri.parse('https://sawa-aid.com/quizApp/get_questions.php?quiz_id=$quizId'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((question) => Question.fromJson(question)).toList();
    } else {
      throw Exception('فشل تحميل الأسئلة');
    }
  }

  static Future<http.Response> submitQuizResults(String apiUrl, List<Map<String, dynamic>> answers, int quizId, int fullMark) async {
    final prefs = await SharedPreferences.getInstance();
    // Check if the user is logged in by checking a flag or token
    int? userId = prefs.getInt('user_id') ;
    final Map<String, dynamic> body = {
      'user_id': userId,
      'quiz_id': quizId,
      'answers': answers,
      'full_mark': fullMark,  // Include the full mark in the body
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    return response;
  }
}
