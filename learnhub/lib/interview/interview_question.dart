enum InterviewDifficulty { basic, intermediate, advanced }

typedef InterviewQuestionDraft = ({
  String question,
  String answer,
  String example,
  String code,
  String output,
  String useCase,
  String keyPoints,
});

InterviewQuestionDraft questionDraft(
  String question,
  String answer,
  String example,
  String useCase,
  String keyPoints, {
  String code = '',
  String output = '',
}) {
  return (
    question: question,
    answer: answer,
    example: example,
    code: code,
    output: output,
    useCase: useCase,
    keyPoints: keyPoints,
  );
}

class InterviewQuestion {
  final String id;
  final String subject;
  final InterviewDifficulty difficulty;
  final String question;
  final String answer;
  final String example;
  final String code;
  final String output;
  final String useCase;
  final String keyPoints;

  const InterviewQuestion({
    required this.id,
    required this.subject,
    required this.difficulty,
    required this.question,
    required this.answer,
    required this.example,
    required this.code,
    required this.output,
    required this.useCase,
    required this.keyPoints,
  });

  String get difficultyLabel => switch (difficulty) {
    InterviewDifficulty.basic => 'Basic',
    InterviewDifficulty.intermediate => 'Intermediate',
    InterviewDifficulty.advanced => 'Advanced',
  };
}

List<InterviewQuestion> buildInterviewQuestions({
  required String subject,
  required String idPrefix,
  required List<InterviewQuestionDraft> basic,
  required List<InterviewQuestionDraft> intermediate,
  required List<InterviewQuestionDraft> advanced,
}) {
  if (basic.length != 20 ||
      intermediate.length != 20 ||
      advanced.length != 10) {
    throw ArgumentError(
      '$subject must contain 20 basic, 20 intermediate, and 10 advanced questions.',
    );
  }

  final questions = <InterviewQuestion>[];
  void append(
    List<InterviewQuestionDraft> drafts,
    InterviewDifficulty difficulty,
    String level,
  ) {
    for (var index = 0; index < drafts.length; index++) {
      final draft = drafts[index];
      questions.add(
        InterviewQuestion(
          id: '$idPrefix-$level-${(index + 1).toString().padLeft(2, '0')}',
          subject: subject,
          difficulty: difficulty,
          question: draft.question,
          answer: draft.answer,
          example: draft.example,
          code: draft.code,
          output: draft.output,
          useCase: draft.useCase,
          keyPoints: draft.keyPoints,
        ),
      );
    }
  }

  append(basic, InterviewDifficulty.basic, 'basic');
  append(intermediate, InterviewDifficulty.intermediate, 'intermediate');
  append(advanced, InterviewDifficulty.advanced, 'advanced');
  return questions;
}
