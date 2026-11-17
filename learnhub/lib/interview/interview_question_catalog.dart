import 'agentic_ai_questions.dart';
import 'azure_devops_questions.dart';
import 'data_engineering_questions.dart';
import 'data_science_questions.dart';
import 'generative_ai_questions.dart';
import 'interview_question.dart';
import 'machine_learning_questions.dart';
import 'python_questions.dart';
import 'sql_questions.dart';

const List<String> interviewSubjectOrder = [
  'Python Programming',
  'SQL / Database Management',
  'Machine Learning',
  'Data Science',
  'Generative AI',
  'Agentic AI',
  'Azure DevOps',
  'Data Engineering',
];

final Map<String, List<InterviewQuestion>> interviewQuestionsBySubject = {
  'Python Programming': pythonInterviewQuestions,
  'SQL / Database Management': sqlInterviewQuestions,
  'Machine Learning': machineLearningInterviewQuestions,
  'Data Science': dataScienceInterviewQuestions,
  'Generative AI': generativeAiInterviewQuestions,
  'Agentic AI': agenticAiInterviewQuestions,
  'Azure DevOps': azureDevOpsInterviewQuestions,
  'Data Engineering': dataEngineeringInterviewQuestions,
};

final List<InterviewQuestion> allInterviewQuestions = [
  for (final subject in interviewSubjectOrder)
    ...interviewQuestionsBySubject[subject]!,
];

final Map<String, InterviewQuestion> interviewQuestionsById = {
  for (final question in allInterviewQuestions) question.id: question,
};

List<String> validateInterviewQuestionCatalog() {
  final errors = <String>[];
  final ids = <String>{};
  final questionTexts = <String>{};
  final answers = <String>{};

  for (final subject in interviewSubjectOrder) {
    final questions = interviewQuestionsBySubject[subject];
    if (questions == null) {
      errors.add('$subject has no dataset.');
      continue;
    }
    if (questions.length != 50) {
      errors.add('$subject has ${questions.length} questions; expected 50.');
    }
    if (questions.any((question) => question.subject != subject)) {
      errors.add('$subject contains a question labeled with another subject.');
    }
    for (final difficulty in InterviewDifficulty.values) {
      final expected = difficulty == InterviewDifficulty.advanced ? 10 : 20;
      final actual = questions
          .where((question) => question.difficulty == difficulty)
          .length;
      if (actual != expected) {
        errors.add(
          '$subject has $actual ${difficulty.name} questions; expected $expected.',
        );
      }
    }
  }

  for (final question in allInterviewQuestions) {
    if (!ids.add(question.id)) {
      errors.add('Duplicate question ID: ${question.id}.');
    }
    final normalizedQuestion = question.question.trim().toLowerCase();
    if (normalizedQuestion.isEmpty || !questionTexts.add(normalizedQuestion)) {
      errors.add('Empty or duplicate question: ${question.question}.');
    }
    if (question.answer.trim().length < 60) {
      errors.add('Answer is too brief: ${question.id}.');
    } else if (!answers.add(question.answer.trim().toLowerCase())) {
      errors.add('Duplicate answer: ${question.id}.');
    }
    if (question.example.trim().isEmpty ||
        question.useCase.trim().isEmpty ||
        question.keyPoints.trim().isEmpty) {
      errors.add('Missing example or interview notes: ${question.id}.');
    }
  }

  if (allInterviewQuestions.length < 400) {
    errors.add(
      'Catalog has ${allInterviewQuestions.length} questions; expected at least 400.',
    );
  }
  return errors;
}
