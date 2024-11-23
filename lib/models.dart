class Quiz {
  final int id;
  final String title;
  final int? userMarks;
  final String? submittedAt;

  Quiz({required this.id, required this.title, this.userMarks, this.submittedAt});



  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['quiz_id'],
      title: json['title'],
      userMarks: json['user_marks'],
      submittedAt: json['submitted_at'],
    );
  }
}

class Question {
  final int id;
  final String questionText;
  final List<String> answers;
  final int correctAnswer;
  final int mark;

  Question({
    required this.id,
    required this.questionText,
    required this.answers,
    required this.correctAnswer,
    required this.mark,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      questionText: json['question_text'],
      answers: [
        json['answer1'],
        json['answer2'],
        json['answer3'],
        json['answer4'],
      ],
      correctAnswer: json['correct_answer'],
      mark: json['mark'],
    );
  }
}
