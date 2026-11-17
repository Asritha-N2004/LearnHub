// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:material_ui/material_ui.dart';
import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:learnhub/main.dart';
import 'package:learnhub/certificates/certificate_store.dart';
import 'package:learnhub/interview/interview_question_catalog.dart';
import 'package:learnhub/interview/interview_progress.dart';
import 'package:learnhub/settings/learnhub_settings.dart';
import 'package:learnhub/settings/local_account_service.dart';
import 'package:learnhub/study_material_pdf.dart';

final Map<String, String> secureStorageValues = <String, String>{};

Future<void> enterAsGuest(WidgetTester tester) async {
  await tester.pumpWidget(const LearnHubApp());
  await tester.tap(find.text('Get Started'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Continue as Guest'));
  await tester.pumpAndSettle();
}

Future<void> openLogin(WidgetTester tester) async {
  await tester.pumpWidget(const LearnHubApp());
  await tester.tap(find.text('Get Started'));
  await tester.pumpAndSettle();
}

Future<void> registerUser(
  WidgetTester tester, {
  required String fullName,
  required String email,
  required String password,
}) async {
  await tester.ensureVisible(find.text('Create account').first);
  await tester.tap(find.text('Create account').first);
  await tester.pumpAndSettle();
  await tester.enterText(find.byKey(const ValueKey('register-name')), fullName);
  await tester.enterText(find.byKey(const ValueKey('register-email')), email);
  await tester.enterText(
    find.byKey(const ValueKey('register-password')),
    password,
  );
  await tester.enterText(
    find.byKey(const ValueKey('register-confirm-password')),
    password,
  );
  final submit = find.byKey(const ValueKey('register-submit'));
  await tester.ensureVisible(submit);
  await tester.tap(submit);
  await tester.pumpAndSettle();
}

Future<void> loginUser(
  WidgetTester tester, {
  required String email,
  required String password,
}) async {
  await tester.enterText(find.byKey(const ValueKey('login-email')), email);
  await tester.enterText(
    find.byKey(const ValueKey('login-password')),
    password,
  );
  await tester.tap(find.text('Sign in'));
  await tester.pumpAndSettle();
}

Future<void> restartToLogin(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpWidget(const LearnHubApp());
  await tester.pumpAndSettle();
  await tester.tap(find.text('Get Started'));
  await tester.pumpAndSettle();
}

Future<void> openAssessments(WidgetTester tester) async {
  final card = find.byKey(const ValueKey('home-assessments-card'));
  await tester.ensureVisible(card);
  await tester.tap(card);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    FlutterSecureStoragePlatform.instance = TestFlutterSecureStoragePlatform(
      secureStorageValues,
    );
  });

  test('interview catalog has 50 complete questions per subject', () {
    expect(allInterviewQuestions, hasLength(400));
    expect(validateInterviewQuestionCatalog(), isEmpty);
    for (final subject in interviewSubjectOrder) {
      expect(interviewQuestionsBySubject[subject], hasLength(50));
    }
  });

  test('interview bookmarks and completion state persist', () async {
    final question = allInterviewQuestions.last;
    final progress = InterviewProgressStore.instance;
    await progress.toggleBookmark(question.id);
    await progress.toggleCompleted(question.id);
    await progress.recordViewed(question.id);

    final preferences = await SharedPreferences.getInstance();
    expect(
      preferences.getStringList('interview_bookmarked_question_ids'),
      contains(question.id),
    );
    expect(
      preferences.getStringList('interview_completed_question_ids'),
      contains(question.id),
    );
    expect(
      preferences.getStringList('interview_recent_question_ids'),
      contains(question.id),
    );

    await progress.toggleBookmark(question.id);
    await progress.toggleCompleted(question.id);
  });

  testWidgets('interview search, difficulty filter, and navigation work', (
    WidgetTester tester,
  ) async {
    await enterAsGuest(tester);
    await tester.tap(find.byType(NavigationDestination).at(2));
    await tester.pumpAndSettle();

    final searchQuestion = allInterviewQuestions.last;
    await tester.enterText(
      find.byType(TextField).first,
      searchQuestion.question,
    );
    await tester.pumpAndSettle();
    expect(find.text('Search results (1)'), findsOneWidget);
    expect(
      find.byKey(ValueKey('open-interview-question-${searchQuestion.id}')),
      findsOneWidget,
    );
    await tester.tap(find.byTooltip('Clear search'));
    await tester.pumpAndSettle();

    final pythonSubjectCard = find.byKey(
      const ValueKey('interview-subject-Python Programming'),
    );
    await tester.ensureVisible(pythonSubjectCard);
    await tester.pumpAndSettle();
    await tester.tap(pythonSubjectCard);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilterChip, 'Advanced'));
    await tester.pumpAndSettle();
    expect(find.text('10 questions'), findsOneWidget);

    final advancedQuestions = interviewQuestionsBySubject['Python Programming']!
        .where((question) => question.difficulty.name == 'advanced')
        .toList();
    await tester.tap(
      find.byKey(
        ValueKey('open-interview-question-${advancedQuestions.first.id}'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('1 of 10'), findsOneWidget);
    await tester.ensureVisible(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('2 of 10'), findsOneWidget);
    await tester.ensureVisible(find.text('Previous'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Previous'));
    await tester.pumpAndSettle();
    expect(find.text('1 of 10'), findsOneWidget);
  });

  testWidgets('LearnHub app loads welcome screen', (WidgetTester tester) async {
    await tester.pumpWidget(const LearnHubApp());

    expect(find.text('LearnHub'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });

  testWidgets('welcome screen scrolls on short viewports', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(820, 411);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const LearnHubApp());
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.ensureVisible(find.text('Get Started'));
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    expect(find.text('Login'), findsOneWidget);
    await tester.ensureVisible(find.text('Continue as Guest'));
    await tester.tap(find.text('Continue as Guest'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome!'), findsOneWidget);
  });

  testWidgets('registration collects a name and signs in with it', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const LearnHubApp());
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    expect(
      find.text('Sign in to continue your learning journey.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password must be at least 6 characters'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('login-email')),
      'not-an-email',
    );
    await tester.enterText(
      find.byKey(const ValueKey('login-password')),
      'short',
    );
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid email address'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('login-email')),
      'learner@example.com',
    );
    await tester.enterText(
      find.byKey(const ValueKey('login-password')),
      'learnhub123',
    );
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    expect(
      find.text('Exception: No account found. Create an account to continue.'),
      findsOneWidget,
    );
    await registerUser(
      tester,
      fullName: 'Asritha Reddy',
      email: 'learner@example.com',
      password: 'learnhub123',
    );
    expect(find.text('Hi Asritha Reddy 👋'), findsOneWidget);
  });

  test('all courses have complete lesson and quiz data', () {
    expect(availableCourses.map((course) => course.title), [
      'Python Programming',
      'SQL / Database Management',
      'Machine Learning',
      'Data Science',
      'Generative AI',
      'Agentic AI',
      'Azure DevOps',
      'Data Engineering',
    ]);
    expect(availableCourses, hasLength(8));
    expect(courseLevels, ['Beginner', 'Intermediate', 'Advanced']);
    expect(
      learningProjects.map((project) => project.subject).toList(),
      courseSubjectOrder,
    );

    for (final course in availableCourses) {
      expect(course.learningObjectives, isNotEmpty, reason: course.title);
      expect(
        course.topics.map((topic) => topic.title),
        containsAll(courseSyllabus[course.title]!),
        reason: course.title,
      );
      expect(
        course.topics.map((topic) => topic.level),
        containsAll(courseLevels),
        reason: course.title,
      );
      expect(course.topics, isNotEmpty, reason: course.title);
      for (final topic in course.topics) {
        expect(topic.introduction.trim(), isNotEmpty, reason: topic.title);
        expect(topic.explanation.trim(), isNotEmpty, reason: topic.title);
        expect(topic.importantConcepts, isNotEmpty, reason: topic.title);
        expect(topic.code.trim(), isNotEmpty, reason: topic.title);
        expect(topic.expectedOutput.trim(), isNotEmpty, reason: topic.title);
        expect(
          topic.realWorldApplications.trim(),
          isNotEmpty,
          reason: topic.title,
        );
        expect(topic.practiceExercises, isNotEmpty, reason: topic.title);
        expect(topic.assignmentText.trim(), isNotEmpty, reason: topic.title);
        expect(topic.quizQuestions, isNotEmpty, reason: topic.title);

        for (final question in topic.quizQuestions) {
          expect(question.options, isNotEmpty, reason: question.question);
          expect(
            question.correctIndex,
            inInclusiveRange(0, question.options.length - 1),
            reason: question.question,
          );
        }
      }
    }
  });

  test('study material PDF generator returns a PDF document', () async {
    final chapter = StudyMaterialChapter(
      title: 'Variables',
      level: 'Beginner',
      introduction: 'Variables store named values.',
      explanation: 'Assign a value and use its name in an expression.',
      concepts: const ['assignment', 'names'],
      example: 'score = 4\nprint(score)',
      expectedOutput: '4',
      applications: 'Programs store user input and calculation results.',
      exercises: const ['Change the value and print it.'],
      assignment: 'Write a small program that stores and reports a score.',
    );
    final bytes = await createStudyMaterialPdf(
      courseTitle: 'Python Programming',
      introduction: 'Study Python fundamentals.',
      objectives: const ['Write and validate small programs.'],
      chapters: [chapter],
    );

    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
  });

  test('every mock-test difficulty supports 20 and 40 questions', () {
    for (final course in availableCourses) {
      for (final difficulty in courseLevels) {
        for (final count in [20, 40]) {
          final questions = buildMockTestQuestions(course, difficulty, count);
          expect(questions, hasLength(count), reason: course.title);
          expect(
            questions.every((question) => question.difficulty == difficulty),
            isTrue,
            reason: '${course.title} / $difficulty',
          );
          for (final item in questions) {
            expect(item.question.options, hasLength(4));
            expect(
              item.question.correctIndex,
              inInclusiveRange(0, item.question.options.length - 1),
            );
            expect(item.question.explanation.trim(), isNotEmpty);
          }
        }
      }
    }
  });

  testWidgets('primary navigation opens each existing module', (
    WidgetTester tester,
  ) async {
    await enterAsGuest(tester);

    final destinations = find.byType(NavigationDestination);
    expect(destinations, findsNWidgets(5));
    expect(find.text('Learn'), findsOneWidget);
    expect(
      find.descendant(of: destinations.at(3), matching: find.text('Projects')),
      findsOneWidget,
    );

    await tester.tap(destinations.at(1));
    await tester.pumpAndSettle();
    expect(find.text('My Courses 📚'), findsOneWidget);

    await tester.tap(destinations.at(2));
    await tester.pumpAndSettle();
    expect(find.text('Interview Preparation 🎯'), findsOneWidget);
    final pythonSubjectCard = find.byKey(
      const ValueKey('interview-subject-Python Programming'),
    );
    await tester.ensureVisible(pythonSubjectCard);
    await tester.pumpAndSettle();
    await tester.tap(pythonSubjectCard);
    await tester.pumpAndSettle();
    final firstPythonQuestion =
        interviewQuestionsBySubject['Python Programming']!.first;
    await tester.tap(
      find.byKey(ValueKey('open-interview-question-${firstPythonQuestion.id}')),
    );
    await tester.pumpAndSettle();
    expect(find.text(firstPythonQuestion.question), findsOneWidget);
    expect(find.text('Detailed answer'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(destinations.at(4));
    await tester.pumpAndSettle();
    expect(find.text('My Profile'), findsOneWidget);
    expect(
      find.text(
        '${availableCourses.fold<int>(0, (total, course) => total + course.topics.length)}',
      ),
      findsOneWidget,
    );
    expect(find.text('0%'), findsOneWidget);
  });

  testWidgets('course catalog search and category filters work', (
    WidgetTester tester,
  ) async {
    await enterAsGuest(tester);
    await tester.tap(find.byType(NavigationDestination).at(1));
    await tester.pumpAndSettle();

    final searchField = find.byKey(const ValueKey('courses-search'));
    await tester.enterText(searchField, 'azure');
    await tester.pumpAndSettle();
    expect(find.text('Azure DevOps'), findsOneWidget);
    expect(find.text('Machine Learning'), findsNothing);

    await tester.enterText(searchField, '');
    await tester.pumpAndSettle();
    final dataCategory = find.byKey(const ValueKey('course-category-Data'));
    await tester.ensureVisible(dataCategory);
    await tester.tap(dataCategory);
    await tester.pumpAndSettle();
    expect(find.text('Data Science'), findsOneWidget);
    expect(find.text('Data Engineering'), findsOneWidget);
    expect(find.text('Azure DevOps'), findsNothing);

    final allCategory = find.byKey(const ValueKey('course-category-All'));
    await tester.ensureVisible(allCategory);
    await tester.tap(allCategory);
    await tester.pumpAndSettle();
    for (final subject in courseSubjectOrder) {
      expect(find.text(subject), findsOneWidget);
    }
  });

  testWidgets('Home dashboard actions open their modules', (
    WidgetTester tester,
  ) async {
    await enterAsGuest(tester);
    expect(find.text('LearnHub'), findsOneWidget);
    expect(find.text('Welcome!'), findsOneWidget);
    expect(find.text('Continue your learning journey'), findsOneWidget);
    expect(find.text('0%'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('home-progress-card')));
    await tester.pumpAndSettle();
    expect(find.text('My Learning'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('home-notifications')));
    await tester.pumpAndSettle();
    expect(find.text('You are all caught up.'), findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    final coursesCard = find.byKey(const ValueKey('home-courses-card'));
    await tester.ensureVisible(coursesCard);
    await tester.tap(coursesCard);
    await tester.pumpAndSettle();
    expect(find.text('My Courses 📚'), findsOneWidget);
    for (final subject in courseSubjectOrder) {
      expect(find.text(subject), findsOneWidget);
    }
    await tester.pageBack();
    await tester.pumpAndSettle();

    final interviewCard = find.byKey(const ValueKey('home-interview-card'));
    await tester.ensureVisible(interviewCard);
    await tester.tap(interviewCard);
    await tester.pumpAndSettle();
    expect(find.text('Interview Preparation 🎯'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    final assessmentsCard = find.byKey(const ValueKey('home-assessments-card'));
    await tester.ensureVisible(assessmentsCard);
    await tester.tap(assessmentsCard);
    await tester.pumpAndSettle();
    expect(find.text('Practice Tests'), findsOneWidget);
    for (final course in availableCourses) {
      final mockButton = find.byKey(ValueKey('start-mock-${course.title}'));
      await tester.scrollUntilVisible(
        mockButton,
        250,
        scrollable: find.descendant(
          of: find.byKey(const ValueKey('practice-tests-list')),
          matching: find.byType(Scrollable),
        ),
      );
      await tester.ensureVisible(mockButton);
      expect(mockButton, findsOneWidget);
    }
    await tester.pageBack();
    await tester.pumpAndSettle();

    final projectsCard = find.byKey(const ValueKey('home-projects-card'));
    await tester.ensureVisible(projectsCard);
    await tester.tap(projectsCard);
    await tester.pumpAndSettle();
    expect(
      find.text('Build practical projects across all 8 subjects.'),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('project-Data Engineering')),
      300,
      scrollable: find.descendant(
        of: find.byKey(const ValueKey('projects-list')),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.ensureVisible(
      find.byKey(const ValueKey('project-Data Engineering')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('project-Data Engineering')));
    await tester.pumpAndSettle();
    expect(find.text('Daily Data Quality Pipeline'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.ensureVisible(
      find.byKey(const ValueKey('home-interview-banner')),
    );
    await tester.tap(find.byKey(const ValueKey('home-interview-banner')));
    await tester.pumpAndSettle();
    expect(find.text('Interview Preparation 🎯'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byType(NavigationDestination).at(3));
    await tester.pumpAndSettle();
    expect(
      find.text('Build practical projects across all 8 subjects.'),
      findsOneWidget,
    );
  });

  testWidgets('practice tests score answers and can be restarted', (
    WidgetTester tester,
  ) async {
    testAttempts.clear();
    learningDataRevision.value++;
    await enterAsGuest(tester);
    await openAssessments(tester);
    expect(find.text('Practice Tests'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('start-practice-Python Programming')),
    );
    await tester.pumpAndSettle();
    final questions = buildCoursePracticeQuestions(availableCourses.first);
    expect(questions.length, greaterThanOrEqualTo(20));

    for (var index = 0; index < questions.length; index++) {
      final correctIndex = questions[index].question.correctIndex;
      final option = find.byKey(
        ValueKey('practice-option-$index-$correctIndex'),
      );
      await tester.ensureVisible(option);
      await tester.tap(option);
      await tester.pump();
    }

    final submitButton = find.byKey(const ValueKey('submit-practice-test'));
    await tester.ensureVisible(submitButton);
    expect(tester.widget<ElevatedButton>(submitButton).onPressed, isNotNull);
    await tester.tap(submitButton);
    await tester.pumpAndSettle();
    expect(find.text('Test Results'), findsOneWidget);
    expect(
      find.text('Score: ${questions.length} / ${questions.length}'),
      findsOneWidget,
    );
    expect(find.text('Accuracy: 100%'), findsOneWidget);
    expect(testAttempts, hasLength(1));
    expect(find.text('Answer Review'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Retake Test'),
      300,
      scrollable: find.descendant(
        of: find.byKey(const ValueKey('test-results-list')),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.tap(find.text('Retake Test'));
    await tester.pumpAndSettle();
    expect(find.text('0 of ${questions.length} answered'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byType(NavigationDestination).at(4));
    await tester.pumpAndSettle();
    await tester.drag(
      find.byKey(const ValueKey('profile-list')),
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Learning History'));
    await tester.pumpAndSettle();
    expect(find.text('Test History'), findsOneWidget);
    expect(
      find.textContaining('${questions.length}/${questions.length} correct'),
      findsOneWidget,
    );
    await tester.tap(
      find.textContaining('${questions.length}/${questions.length} correct'),
    );
    await tester.pumpAndSettle();
    expect(find.text('Test Results'), findsOneWidget);
  });

  testWidgets('profile My Courses opens the course curriculum', (
    WidgetTester tester,
  ) async {
    await enterAsGuest(tester);
    await tester.tap(find.byType(NavigationDestination).at(4));
    await tester.pumpAndSettle();
    await tester.tap(find.text('My Courses'));
    await tester.pumpAndSettle();

    expect(find.text('My Courses 📚'), findsOneWidget);
    await tester.tap(find.text('Python Programming'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Chapter-wise Syllabus'),
      200,
      scrollable: find.descendant(
        of: find.byKey(const ValueKey('course-curriculum-list')),
        matching: find.byType(Scrollable),
      ),
    );
    expect(find.text('Chapter-wise Syllabus'), findsOneWidget);
  });

  testWidgets('study materials open chapter notes and the lesson', (
    WidgetTester tester,
  ) async {
    await enterAsGuest(tester);
    await tester.tap(find.byType(NavigationDestination).at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Python Programming'));
    await tester.pumpAndSettle();

    final studyMaterialsButton = find.byKey(
      const ValueKey('open-study-materials-Python Programming'),
    );
    await tester.scrollUntilVisible(
      studyMaterialsButton,
      200,
      scrollable: find.descendant(
        of: find.byKey(const ValueKey('course-curriculum-list')),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.ensureVisible(studyMaterialsButton);
    await tester.tap(studyMaterialsButton);
    await tester.pumpAndSettle();
    expect(find.text('Study Materials'), findsOneWidget);
    expect(find.text('Chapter-wise Materials'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('download-study-pdf-Python Programming')),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('PDF download is available in the LearnHub web app.'),
      findsOneWidget,
    );
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    final variablesMaterial = find.byKey(
      const ValueKey('study-material-Variables'),
    );
    await tester.scrollUntilVisible(
      variablesMaterial,
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.ensureVisible(variablesMaterial);
    await tester.tap(variablesMaterial);
    await tester.pumpAndSettle();
    expect(find.text('Variables'), findsNWidgets(2));
    expect(find.text('Important Concepts'), findsOneWidget);
    final continueButton = find.byKey(const ValueKey('continue-study-lesson'));
    await tester.scrollUntilVisible(
      continueButton,
      200,
      scrollable: find
          .descendant(
            of: find.byKey(const ValueKey('study-material-chapter-list')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(continueButton, findsOneWidget);
    expect(find.text('Assignment'), findsOneWidget);
    await tester.tap(continueButton);
    await tester.pumpAndSettle();
    expect(find.text('Practical Code Example'), findsOneWidget);
    expect(find.byKey(const ValueKey('lesson-level')), findsOneWidget);
  });

  testWidgets('timed mock test submits automatically when time expires', (
    WidgetTester tester,
  ) async {
    testAttempts.clear();
    learningDataRevision.value++;
    await enterAsGuest(tester);
    await openAssessments(tester);
    await tester.tap(
      find.byKey(const ValueKey('start-mock-Python Programming')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Mock Test Setup'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('start-configured-mock')));
    await tester.pumpAndSettle();

    expect(find.text('Timed Mock Test'), findsOneWidget);
    expect(find.text('Time remaining: 20:00'), findsOneWidget);

    await tester.pump(const Duration(minutes: 20));
    await tester.pumpAndSettle();
    expect(
      find.text('Time limit reached. Answers were auto-submitted.'),
      findsOneWidget,
    );
    expect(find.text('Score: 0 / 20'), findsOneWidget);
    expect(testAttempts, hasLength(1));
    expect(testAttempts.single.endedByTimeout, isTrue);
    expect(testAttempts.single.isMockTest, isTrue);
    expect(testAttempts.single.difficulty, 'Beginner');
    expect(testAttempts.single.questionCount, 20);
  });

  testWidgets(
    'mock tests navigate, review, score, and retain setup on retake',
    (WidgetTester tester) async {
      testAttempts.clear();
      learningDataRevision.value++;
      await enterAsGuest(tester);
      await openAssessments(tester);
      final startGenerativeMock = find.byKey(
        const ValueKey('start-mock-Generative AI'),
      );
      await tester.scrollUntilVisible(
        startGenerativeMock,
        250,
        scrollable: find
            .descendant(
              of: find.byKey(const ValueKey('practice-tests-list')),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.tap(startGenerativeMock);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('mock-level-Advanced')));
      await tester.tap(find.byKey(const ValueKey('mock-count-40')));
      await tester.tap(find.byKey(const ValueKey('start-configured-mock')));
      await tester.pumpAndSettle();

      final questions = buildMockTestQuestions(
        availableCourses[4],
        'Advanced',
        40,
      );
      expect(find.text('Advanced • 40 questions'), findsOneWidget);
      expect(find.text('Question 1 of 40'), findsOneWidget);
      expect(find.text('Mark for Review'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('mark-review-0')));
      final correctOption = find.byKey(
        ValueKey('practice-option-0-${questions.first.question.correctIndex}'),
      );
      await tester.tap(correctOption);
      final nextQuestion = find.byKey(const ValueKey('mock-next-question'));
      final testScrollable = find
          .descendant(
            of: find.byKey(const ValueKey('practice-test-list')),
            matching: find.byType(Scrollable),
          )
          .first;
      await tester.scrollUntilVisible(
        nextQuestion,
        150,
        scrollable: testScrollable,
      );
      await tester.tap(nextQuestion);
      await tester.pumpAndSettle();
      expect(find.text('Question 2 of 40'), findsOneWidget);
      final previousQuestion = find.byKey(
        const ValueKey('mock-previous-question'),
      );
      await tester.scrollUntilVisible(
        previousQuestion,
        150,
        scrollable: testScrollable,
      );
      await tester.tap(previousQuestion);
      await tester.pumpAndSettle();
      expect(find.text('Marked for Review'), findsOneWidget);

      final submitButton = find.byKey(const ValueKey('submit-mock-test'));
      await tester.scrollUntilVisible(
        submitButton,
        250,
        scrollable: find
            .descendant(
              of: find.byKey(const ValueKey('practice-test-list')),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.tap(submitButton);
      await tester.pumpAndSettle();
      expect(find.text('Score: 1 / 40'), findsOneWidget);
      expect(find.text('Advanced Mock Test • 40 questions'), findsOneWidget);
      expect(find.text('Marked for review: 1'), findsOneWidget);
      expect(testAttempts.single.reviewedQuestionIndices, {0});

      await tester.scrollUntilVisible(
        find.text('Topic Analysis'),
        300,
        scrollable: find.descendant(
          of: find.byKey(const ValueKey('test-results-list')),
          matching: find.byType(Scrollable),
        ),
      );
      expect(find.text('Topic Analysis'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Retake Test'),
        300,
        scrollable: find.descendant(
          of: find.byKey(const ValueKey('test-results-list')),
          matching: find.byType(Scrollable),
        ),
      );
      await tester.tap(find.text('Retake Test'));
      await tester.pumpAndSettle();
      expect(find.text('Advanced • 40 questions'), findsOneWidget);
      expect(find.text('0 of 40 answered'), findsOneWidget);
    },
  );

  testWidgets('interview answers can be saved and unsaved', (
    WidgetTester tester,
  ) async {
    bookmarkedInterviewQuestions.clear();
    learningDataRevision.value++;
    await enterAsGuest(tester);
    await tester.tap(find.byType(NavigationDestination).at(2));
    await tester.pumpAndSettle();
    final pythonSubjectCard = find.byKey(
      const ValueKey('interview-subject-Python Programming'),
    );
    await tester.ensureVisible(pythonSubjectCard);
    await tester.pumpAndSettle();
    await tester.tap(pythonSubjectCard);
    await tester.pumpAndSettle();
    final firstPythonQuestion =
        interviewQuestionsBySubject['Python Programming']!.first;
    await tester.tap(
      find.byKey(ValueKey('open-interview-question-${firstPythonQuestion.id}')),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Bookmark question'));
    await tester.pumpAndSettle();
    expect(
      bookmarkedInterviewQuestions.containsKey(firstPythonQuestion.question),
      isTrue,
    );
    expect(find.byTooltip('Remove bookmark'), findsOneWidget);

    await tester.tap(find.byTooltip('Remove bookmark'));
    await tester.pumpAndSettle();
    expect(
      bookmarkedInterviewQuestions.containsKey(firstPythonQuestion.question),
      isFalse,
    );

    await tester.tap(find.byTooltip('Bookmark question'));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byType(NavigationDestination).at(4));
    await tester.pumpAndSettle();
    await tester.drag(
      find.byKey(const ValueKey('profile-list')),
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Saved Questions'));
    await tester.pumpAndSettle();
    expect(find.text('My Learning'), findsOneWidget);
    expect(find.text(firstPythonQuestion.question), findsOneWidget);
  });

  testWidgets('completing a lesson updates subject and overall progress', (
    WidgetTester tester,
  ) async {
    completedLessonIds.clear();
    completedLessonRevision.value++;
    await enterAsGuest(tester);
    await tester.tap(find.byType(NavigationDestination).at(1));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Python Programming'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Variables'),
      200,
      scrollable: find.descendant(
        of: find.byKey(const ValueKey('course-curriculum-list')),
        matching: find.byType(Scrollable),
      ),
    );
    final variablesChapter = find.text('Variables');
    await tester.ensureVisible(variablesChapter);
    await tester.pumpAndSettle();
    await tester.tap(variablesChapter);
    await tester.pumpAndSettle();
    expect(find.text('Practical Code Example'), findsOneWidget);

    await tester.ensureVisible(find.text('Mark as Completed'));
    await tester.tap(find.text('Mark as Completed'));
    await tester.pumpAndSettle();
    expect(find.text('Lesson Completed'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    final pythonTopicCount = availableCourses.first.topics.length;
    await tester.drag(
      find.byKey(const ValueKey('course-curriculum-list')),
      const Offset(0, 500),
    );
    await tester.pumpAndSettle();
    expect(find.text('1/$pythonTopicCount topics completed'), findsOneWidget);
    expect(find.text('${(100 / pythonTopicCount).round()}%'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byType(NavigationDestination).at(0));
    await tester.pumpAndSettle();
    final totalTopicCount = availableCourses.fold<int>(
      0,
      (total, course) => total + course.topics.length,
    );
    final expectedOverallProgress = '${(100 / totalTopicCount).round()}%';
    expect(find.text(expectedOverallProgress), findsOneWidget);

    await tester.tap(find.byType(NavigationDestination).at(4));
    await tester.pumpAndSettle();
    expect(find.text(expectedOverallProgress), findsOneWidget);
    expect(find.text('$totalTopicCount'), findsOneWidget);
  });

  test('certificates are awarded only after completion or passing', () async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.clear();
    final store = CertificateStore.instance;
    store.resetInMemory();
    await store.load();

    expect(
      await store.awardCourseIfComplete(
        courseName: 'Python Programming',
        learnerName: 'Alex',
        requiredLessonIds: const ['lesson-1', 'lesson-2'],
        completedLessonIds: const {'lesson-1'},
      ),
      isNull,
    );
    final earned = await store.awardCourseIfComplete(
      courseName: 'Python Programming',
      learnerName: 'Alex',
      requiredLessonIds: const ['lesson-1', 'lesson-2'],
      completedLessonIds: const {'lesson-1', 'lesson-2'},
    );
    expect(earned, isNotNull);
    expect(earned!.learnerName, 'Alex');
    expect(earned.kind, CertificateKind.course);
    expect(store.certificates.value, hasLength(1));
    expect(
      preferences.getString('learnhub_earned_certificates_v1'),
      contains(earned.id),
    );

    expect(
      await store.awardAssessmentIfPassed(
        courseName: 'SQL',
        assessmentName: 'Final Exam',
        learnerName: 'Alex',
        score: 6,
        totalQuestions: 10,
      ),
      isNull,
    );
    final assessment = await store.awardAssessmentIfPassed(
      courseName: 'SQL',
      assessmentName: 'Final Exam',
      learnerName: 'Alex',
      score: 7,
      totalQuestions: 10,
    );
    expect(assessment, isNotNull);
    expect(assessment!.kind, CertificateKind.assessment);
    expect(store.certificates.value, hasLength(2));
    await store.renameLearner(previousName: 'Alex', newName: 'Alex Rivera');
    expect(
      store.certificates.value.every(
        (certificate) => certificate.learnerName == 'Alex Rivera',
      ),
      isTrue,
    );
  });

  test(
    'settings and local password persist and account deletion clears them',
    () async {
      final preferences = await SharedPreferences.getInstance();
      await preferences.clear();
      secureStorageValues.clear();
      final store = LearnHubSettingsStore.instance;
      store.resetInMemory();
      await store.load();
      await store.save(
        LearnHubSettings(
          learnerName: 'Taylor',
          email: 'taylor@example.com',
          themeMode: ThemeMode.dark,
          preferredSubjects: const ['Python Programming'],
          dailyLearningGoalMinutes: 45,
        ),
      );

      store.resetInMemory();
      await store.load();
      expect(store.settings.value.learnerName, 'Taylor');
      expect(store.settings.value.email, 'taylor@example.com');
      expect(store.settings.value.themeMode, ThemeMode.dark);
      expect(store.settings.value.preferredSubjects, ['Python Programming']);

      await LocalPasswordStore.instance.changePassword(
        currentPassword: null,
        newPassword: 'new-password-123',
      );
      expect(
        await LocalPasswordStore.instance.verifyPassword('wrong-password'),
        isFalse,
      );
      expect(
        await LocalPasswordStore.instance.verifyPassword('new-password-123'),
        isTrue,
      );
      await deleteLocalLearnHubData();
      expect(secureStorageValues, isEmpty);
      expect(preferences.getKeys(), isEmpty);
      expect(store.settings.value.learnerName, isEmpty);
    },
  );

  testWidgets('Profile opens the Certificates and Settings modules', (
    WidgetTester tester,
  ) async {
    await enterAsGuest(tester);
    await tester.tap(find.byType(NavigationDestination).at(4));
    await tester.pumpAndSettle();

    final profileList = find.byKey(const ValueKey('profile-list'));
    final profileScrollable = find.descendant(
      of: profileList,
      matching: find.byType(Scrollable),
    );
    await tester.scrollUntilVisible(
      find.text('Certificates'),
      250,
      scrollable: profileScrollable,
    );
    await tester.tap(find.text('Certificates'));
    await tester.pumpAndSettle();
    expect(find.text('Your achievements'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Settings'),
      250,
      scrollable: profileScrollable,
    );
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Account Settings'), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Notifications'),
      250,
      scrollable: find.descendant(
        of: find.byType(Scaffold).last,
        matching: find.byType(Scrollable),
      ),
    );
    expect(find.text('Notifications'), findsOneWidget);
  });

  testWidgets('each account keeps its personalized greeting after restart', (
    WidgetTester tester,
  ) async {
    await deleteLocalLearnHubData();
    secureStorageValues.clear();

    await openLogin(tester);
    await registerUser(
      tester,
      fullName: 'Asritha Reddy',
      email: 'asritha@example.com',
      password: 'asritha-pass-1',
    );
    expect(find.text('Hi Asritha Reddy 👋'), findsOneWidget);

    await tester.tap(find.byType(NavigationDestination).at(4));
    await tester.pumpAndSettle();
    final profileList = find.byKey(const ValueKey('profile-list'));
    final profileScrollable = find.descendant(
      of: profileList,
      matching: find.byType(Scrollable),
    );
    await tester.scrollUntilVisible(
      find.text('Settings'),
      250,
      scrollable: profileScrollable,
    );
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit Name'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField).last,
      'Asritha Reddy Updated',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byType(NavigationDestination).at(0));
    await tester.pumpAndSettle();
    expect(find.text('Hi Asritha Reddy Updated 👋'), findsOneWidget);
    await tester.tap(find.byType(NavigationDestination).at(4));
    await tester.pumpAndSettle();
    expect(find.text('Asritha Reddy Updated'), findsOneWidget);

    await restartToLogin(tester);
    await loginUser(
      tester,
      email: 'asritha@example.com',
      password: 'asritha-pass-1',
    );
    expect(find.text('Hi Asritha Reddy Updated 👋'), findsOneWidget);

    await restartToLogin(tester);
    await registerUser(
      tester,
      fullName: 'Jordan Lee',
      email: 'jordan@example.com',
      password: 'jordan-pass-1',
    );
    expect(find.text('Hi Jordan Lee 👋'), findsOneWidget);

    await restartToLogin(tester);
    await loginUser(
      tester,
      email: 'asritha@example.com',
      password: 'asritha-pass-1',
    );
    expect(find.text('Hi Asritha Reddy Updated 👋'), findsOneWidget);

    await restartToLogin(tester);
    await loginUser(
      tester,
      email: 'jordan@example.com',
      password: 'jordan-pass-1',
    );
    expect(find.text('Hi Jordan Lee 👋'), findsOneWidget);
  });
}
