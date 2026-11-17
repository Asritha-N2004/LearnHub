import 'dart:async';

import 'package:material_ui/material_ui.dart';

import 'certificates/certificate_store.dart';
import 'certificates/certificates_page.dart';
import 'interview/interview_progress.dart';
import 'interview/interview_question.dart';
import 'interview/interview_question_catalog.dart';
import 'pdf_downloader.dart';
import 'settings/course_progress_store.dart';
import 'settings/learnhub_settings.dart';
import 'settings/local_account_service.dart';
import 'settings/registration_page.dart';
import 'settings/settings_page.dart';
import 'study_material_pdf.dart';

final ValueNotifier<String?> appStartupError = ValueNotifier<String?>(null);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LearnHubApp());
  unawaited(_initializeInterviewProgress());
}

Future<void> _initializeInterviewProgress() async {
  try {
    await Future.wait<void>([
      InterviewProgressStore.instance.load(),
      LearnHubSettingsStore.instance.load(),
      CertificateStore.instance.load(),
    ]);
    final savedLessonIds = await CourseProgressStore.instance.load();
    completedLessonIds
      ..clear()
      ..addAll(savedLessonIds);
    _syncInterviewBookmarks();
    await _restoreCompletedCourseCertificates();
    learningDataRevision.value++;
    completedLessonRevision.value++;
    appStartupError.value = null;
  } on Exception catch (error, stackTrace) {
    debugPrint(
      'LearnHub saved data could not be initialized: $error\n$stackTrace',
    );
    appStartupError.value = 'Saved LearnHub data could not be loaded: $error';
  }
}

Future<void> _restoreCompletedCourseCertificates() async {
  final settings = LearnHubSettingsStore.instance.settings.value;
  for (final course in availableCourses) {
    await CertificateStore.instance.awardCourseIfComplete(
      courseName: course.title,
      learnerName: settings.learnerName,
      requiredLessonIds: course.topics.map(
        (topic) => buildLessonKey(course.title, topic.title),
      ),
      completedLessonIds: completedLessonIds,
    );
  }
}

Future<void> _deleteLocalAccountData() async {
  await deleteLocalLearnHubData();
  completedLessonIds.clear();
  bookmarkedInterviewQuestions.clear();
  testAttempts.clear();
  _syncInterviewBookmarks();
  completedLessonRevision.value++;
  learningDataRevision.value++;
}

const Color primaryColor = Color(0xFF2457D6);
const Color backgroundColor = Color(0xFFF5F7FC);

String _homeGreeting(String fullName) {
  final name = fullName.trim();
  return name.isEmpty ? 'Welcome!' : 'Hi $name 👋';
}

class LearnHubApp extends StatelessWidget {
  const LearnHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<LearnHubSettings>(
      valueListenable: LearnHubSettingsStore.instance.settings,
      builder: (context, settings, child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'LearnHub',
        themeMode: settings.themeMode,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: backgroundColor,
          colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
          appBarTheme: const AppBarTheme(
            backgroundColor: backgroundColor,
            elevation: 0,
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(
            seedColor: primaryColor,
            brightness: Brightness.dark,
          ),
          scaffoldBackgroundColor: const Color(0xFF10141D),
        ),
        home: const WelcomeScreen(),
      ),
    );
  }
}

// WELCOME SCREEN

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF102D70), Color(0xFF3478E5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.school_rounded,
                          size: 95,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'LearnHub',
                          style: TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Learn • Practice • Interview • Get Hired',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70, fontSize: 15),
                        ),
                        ValueListenableBuilder<String?>(
                          valueListenable: appStartupError,
                          builder: (context, error, child) {
                            if (error == null) {
                              return const SizedBox.shrink();
                            }
                            return Column(
                              children: [
                                const SizedBox(height: 12),
                                Text(
                                  error,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    appStartupError.value = null;
                                    unawaited(_initializeInterviewProgress());
                                  },
                                  child: const Text(
                                    'Retry saved progress',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 60),
                        const Icon(
                          Icons.laptop_mac_rounded,
                          size: 110,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 55),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: primaryColor,
                            ),
                            child: const Text(
                              'Get Started',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Your journey to success starts here!',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _signInError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _enterApp() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainScreen()),
      (route) => false,
    );
  }

  Future<void> _activateAccount(LearnHubUserAccount account) async {
    final settingsStore = LearnHubSettingsStore.instance;
    await settingsStore.load();
    await settingsStore.save(
      settingsStore.settings.value.copyWith(
        learnerName: account.fullName,
        email: account.email,
      ),
    );
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<void> _signIn() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    try {
      final account = await LocalAccountService.authenticate(
        email: _emailController.text,
        password: _passwordController.text,
      );
      await _activateAccount(account);
      if (!mounted) {
        return;
      }
      _enterApp();
    } on Exception catch (error) {
      if (mounted) {
        setState(() => _signInError = error.toString());
      }
    }
  }

  Future<void> _register() async {
    final account = await Navigator.of(context).push<LearnHubUserAccount>(
      MaterialPageRoute<LearnHubUserAccount>(
        builder: (_) => const RegistrationPage(),
      ),
    );
    if (account == null || !mounted) {
      return;
    }
    try {
      await _activateAccount(account);
      if (mounted) {
        _enterApp();
      }
    } on Exception catch (error) {
      if (mounted) {
        setState(() => _signInError = 'Account created but sign-in failed: $error');
      }
    }
  }

  Future<void> _continueAsGuest() async {
    try {
      final settingsStore = LearnHubSettingsStore.instance;
      await settingsStore.load();
      await settingsStore.save(
        settingsStore.settings.value.copyWith(learnerName: '', email: ''),
      );
      if (mounted) {
        _enterApp();
      }
    } on Exception catch (error) {
      if (mounted) {
        setState(() => _signInError = 'Could not continue as guest: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  const Icon(
                    Icons.school_rounded,
                    color: primaryColor,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Welcome to LearnHub',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Sign in to continue your learning journey.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  TextFormField(
                    key: const ValueKey('login-email'),
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: _validateEmail,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    key: const ValueKey('login-password'),
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.password],
                    onFieldSubmitted: (_) => _signIn(),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        tooltip: _obscurePassword
                            ? 'Show password'
                            : 'Hide password',
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                    validator: _validatePassword,
                  ),
                  if (_signInError != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _signInError!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ],
                  const SizedBox(height: 22),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _signIn,
                      child: const Text('Sign in'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: _continueAsGuest,
                    icon: const Icon(Icons.explore_outlined),
                    label: const Text('Continue as Guest'),
                  ),
                  TextButton(
                    onPressed: _register,
                    child: const Text('Create account'),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Your account is stored securely on this device.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// MAIN NAVIGATION

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;

  final List<Widget> pages = [
    const HomePage(),
    const CoursesPage(),
    const InterviewPage(),
    const ProjectsPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: selectedIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Learn',
          ),
          NavigationDestination(
            icon: Icon(Icons.mic_none),
            selectedIcon: Icon(Icons.mic),
            label: 'Interview',
          ),
          NavigationDestination(
            icon: Icon(Icons.layers_outlined),
            selectedIcon: Icon(Icons.layers),
            label: 'Projects',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// COURSE DATA

final Set<String> completedLessonIds = <String>{};
final ValueNotifier<int> completedLessonRevision = ValueNotifier<int>(0);
final Map<String, String> bookmarkedInterviewQuestions = <String, String>{};
final ValueNotifier<int> learningDataRevision = ValueNotifier<int>(0);

void _syncInterviewBookmarks() {
  bookmarkedInterviewQuestions
    ..clear()
    ..addEntries(
      InterviewProgressStore.instance.bookmarkedQuestionIds
          .where(interviewQuestionsById.containsKey)
          .map((id) {
            final question = interviewQuestionsById[id]!;
            return MapEntry(question.question, question.answer);
          }),
    );
}

String buildLessonKey(String courseTitle, String topicTitle) {
  return '$courseTitle|$topicTitle';
}

Future<void> markLessonCompleted(String lessonId) async {
  if (completedLessonIds.contains(lessonId)) {
    return;
  }
  if (await CourseProgressStore.instance.markCompleted(lessonId)) {
    completedLessonIds.add(lessonId);
    completedLessonRevision.value++;
  }
}

Future<void> toggleInterviewBookmark(String question) async {
  final item = allInterviewQuestions.firstWhere(
    (item) => item.question == question,
    orElse: () => throw StateError('Interview question was not found.'),
  );
  await InterviewProgressStore.instance.toggleBookmark(item.id);
  _syncInterviewBookmarks();
  learningDataRevision.value++;
}

class LessonQuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  LessonQuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}

class CourseTopic {
  final String title;
  final String level;
  final String introduction;
  final String explanation;
  final List<String> importantConcepts;
  final String code;
  final String expectedOutput;
  final String realWorldApplications;
  final List<String> practiceExercises;
  final String assignment;
  final List<LessonQuizQuestion> quizQuestions;
  final bool isSyllabusChapter;

  CourseTopic({
    required this.title,
    this.level = 'Beginner',
    required this.introduction,
    required this.explanation,
    required this.importantConcepts,
    required this.code,
    required this.expectedOutput,
    required this.realWorldApplications,
    required this.practiceExercises,
    this.assignment = '',
    required this.quizQuestions,
    this.isSyllabusChapter = false,
  });

  String get assignmentText =>
      assignment.isEmpty ? practiceExercises.last : assignment;
}

class Course {
  final String title;
  final String subtitle;
  final String category;
  final String level;
  final String duration;
  final String lessons;
  final IconData icon;
  final Color color;
  final List<CourseTopic> topics;

  String get introduction => courseIntroductions[title] ?? subtitle;
  List<String> get learningObjectives =>
      courseLearningObjectives[title] ?? const <String>[];

  Course({
    required this.title,
    required this.subtitle,
    required this.category,
    required this.level,
    required this.duration,
    required this.lessons,
    required this.icon,
    required this.color,
    required this.topics,
  });

  int get completedTopicsCount {
    return topics
        .where(
          (topic) =>
              completedLessonIds.contains(buildLessonKey(title, topic.title)),
        )
        .length;
  }

  double get progressValue {
    if (topics.isEmpty) {
      return 0;
    }
    return completedTopicsCount / topics.length;
  }

  String get progressText {
    return '$completedTopicsCount/${topics.length} topics completed';
  }
}

class CourseAssessmentQuestion {
  final String topicTitle;
  final LessonQuizQuestion question;
  final String difficulty;

  const CourseAssessmentQuestion({
    required this.topicTitle,
    required this.question,
    this.difficulty = 'Beginner',
  });
}

List<CourseAssessmentQuestion> buildCoursePracticeQuestions(Course course) {
  return [
    for (final topic in course.topics)
      for (final question in topic.quizQuestions)
        CourseAssessmentQuestion(
          topicTitle: topic.title,
          question: question,
          difficulty: topic.level,
        ),
  ];
}

List<CourseAssessmentQuestion> buildMockTestQuestions(
  Course course,
  String difficulty,
  int questionCount,
) {
  const stems = {
    'Beginner': [
      'Which is a clear first example of',
      'What should a learner recognize about',
      'Which outcome best demonstrates',
      'What is a useful first check when learning',
      'Which statement best introduces',
    ],
    'Intermediate': [
      'How should a practitioner validate',
      'Which step best handles a changed input for',
      'What is the best way to apply',
      'Which check helps compare two approaches to',
      'How can a team make its use of',
    ],
    'Advanced': [
      'Which practice best prepares',
      'What should be evaluated before deploying',
      'Which approach best addresses edge cases in',
      'How should a team assess trade-offs when using',
      'What makes a production use of',
    ],
  };
  final correctChoices = {
    'Beginner': [
      'Build a small ${course.title} example using the topic and inspect its output.',
      'Identify the topic inputs and describe the expected result.',
      'Change one simple input and observe how the topic behaves.',
      'Connect the topic to a clear example from ${course.title}.',
      'Check that the example output matches the stated expectation.',
    ],
    'Intermediate': [
      'Test a changed input and compare the result with a stated expectation.',
      'Validate normal and boundary inputs before relying on the result.',
      'Compare alternatives using the same representative input data.',
      'Investigate unexpected output and isolate the changed assumption.',
      'Document the workflow and verify its output with a repeatable check.',
    ],
    'Advanced': [
      'Validate assumptions, edge cases, and limitations; document trade-offs.',
      'Assess reliability and performance with representative data before deployment.',
      'Add monitoring and a recovery plan for failures in the workflow.',
      'Review security, data quality, and downstream impacts before release.',
      'Compare alternatives against measurable requirements and known constraints.',
    ],
  };
  const distractors = [
    'Assume the first output is correct without checking the inputs.',
    'Use an unrelated technique and skip testing its result.',
    'Change several variables at once and guess which change mattered.',
  ];

  final questions = <CourseAssessmentQuestion>[
    for (final item in buildCoursePracticeQuestions(course))
      if (item.difficulty == difficulty) item,
  ];
  final questionStems = stems[difficulty]!;
  final correctAnswers = correctChoices[difficulty]!;

  for (final topic in course.topics) {
    for (var variant = 0; variant < questionStems.length; variant++) {
      final correctIndex = variant % 4;
      final choices = <String>[correctAnswers[variant], ...distractors];
      final options = List<String>.generate(
        choices.length,
        (index) =>
            choices[(index - correctIndex + choices.length) % choices.length],
      );
      final subject = topic.title;
      questions.add(
        CourseAssessmentQuestion(
          topicTitle: subject,
          difficulty: difficulty,
          question: LessonQuizQuestion(
            question: '${questionStems[variant]} $subject?',
            options: options,
            correctIndex: correctIndex,
            explanation:
                'For $subject in ${course.title}, use the correct workflow for the chosen level and verify the result rather than relying on assumptions.',
          ),
        ),
      );
    }
  }
  return questions.take(questionCount).toList();
}

class QuestionAttemptResult {
  final CourseAssessmentQuestion assessmentQuestion;
  final int selectedIndex;

  const QuestionAttemptResult({
    required this.assessmentQuestion,
    required this.selectedIndex,
  });
}

class TestAttempt {
  final Course course;
  final bool isTimed;
  final bool endedByTimeout;
  final bool isMockTest;
  final String difficulty;
  final Set<int> reviewedQuestionIndices;
  final int score;
  final DateTime completedAt;
  final Duration elapsed;
  final List<QuestionAttemptResult> answers;
  final int questionCount;

  const TestAttempt({
    required this.course,
    required this.isTimed,
    required this.endedByTimeout,
    required this.score,
    required this.completedAt,
    required this.elapsed,
    required this.answers,
    this.isMockTest = false,
    this.difficulty = 'All levels',
    this.reviewedQuestionIndices = const {},
    this.questionCount = 0,
  });

  int get totalQuestions => answers.length;

  int get accuracyPercent =>
      totalQuestions == 0 ? 0 : (score * 100 / totalQuestions).round();
}

final List<TestAttempt> testAttempts = <TestAttempt>[];

const List<String> courseSubjectOrder = [
  'Python Programming',
  'SQL / Database Management',
  'Machine Learning',
  'Data Science',
  'Generative AI',
  'Agentic AI',
  'Azure DevOps',
  'Data Engineering',
];

const List<String> courseLevels = ['Beginner', 'Intermediate', 'Advanced'];

const Map<String, String> courseIntroductions = {
  'Python Programming': 'Learn Python from core syntax through reusable programs, file handling, and commonly used libraries.',
  'SQL / Database Management': 'Learn to design relational data, query it accurately, and improve database performance.',
  'Machine Learning': 'Build a practical understanding of machine learning workflows, algorithms, and evaluation.',
  'Data Science': 'Turn raw data into useful evidence through cleaning, analysis, visualization, and modeling.',
  'Generative AI': 'Explore the foundations of generative models and build grounded, useful AI applications.',
  'Agentic AI': 'Learn how agents plan, call tools, use memory, and operate within evaluated workflows.',
  'Azure DevOps': 'Use source control, work tracking, CI/CD pipelines, releases, and monitoring in Azure DevOps.',
  'Data Engineering': 'Design dependable data platforms and pipelines for batch, streaming, and analytical workloads.',
};

const Map<String, List<String>> courseLearningObjectives = {
  'Python Programming': [
    'Write readable Python programs using core language features.',
    'Organize code with functions, collections, modules, and libraries.',
    'Handle files and errors and verify results with practical exercises.',
  ],
  'SQL / Database Management': [
    'Model relational data and use SQL to create and modify database objects.',
    'Query related data with joins, CTEs, and window functions.',
    'Apply indexes and query plans to reason about performance.',
  ],
  'Machine Learning': [
    'Explain the supervised and unsupervised learning workflows.',
    'Choose common algorithms for regression, classification, and clustering.',
    'Evaluate models and improve input features responsibly.',
  ],
  'Data Science': [
    'Move through a data-science lifecycle from question to evidence.',
    'Clean, explore, summarize, and visualize data with common tools.',
    'Build analysis and communicate conclusions for business decisions.',
  ],
  'Generative AI': [
    'Explain LLMs, transformers, embeddings, and generative AI limits.',
    'Write structured prompts and ground answers with retrieval.',
    'Compare application patterns including RAG and fine-tuning.',
  ],
  'Agentic AI': [
    'Distinguish an agent workflow from a single LLM response.',
    'Design bounded planning, tool-calling, and memory patterns.',
    'Evaluate and deploy agent workflows with suitable safeguards.',
  ],
  'Azure DevOps': [
    'Manage source, branches, and work items with Azure DevOps tools.',
    'Create YAML pipelines for continuous integration and delivery.',
    'Plan testing, releases, and operational monitoring.',
  ],
  'Data Engineering': [
    'Compare ETL and ELT and select a suitable processing pattern.',
    'Design warehouses, lakes, and data pipelines for analytics.',
    'Reason about batch, streaming, orchestration, and data quality.',
  ],
};

const Map<String, List<String>> courseSyllabus = {
  'Python Programming': [
    'Variables',
    'Data Types',
    'Operators',
    'Conditions',
    'Loops',
    'Functions',
    'OOP',
    'Collections',
    'File Handling',
    'Exception Handling',
    'Modules',
    'Libraries',
  ],
  'SQL / Database Management': [
    'Database Fundamentals',
    'SQL Queries',
    'DDL',
    'DML',
    'Joins',
    'Subqueries',
    'CTEs',
    'Window Functions',
    'Stored Procedures',
    'Indexes',
    'Query Optimization',
  ],
  'Machine Learning': [
    'ML Fundamentals',
    'Supervised Learning',
    'Unsupervised Learning',
    'Regression',
    'Classification',
    'Clustering',
    'Decision Trees',
    'Random Forest',
    'SVM',
    'Model Evaluation',
    'Feature Engineering',
  ],
  'Data Science': [
    'Data Science Lifecycle',
    'NumPy',
    'Pandas',
    'Data Cleaning',
    'EDA',
    'Statistics',
    'Data Visualization',
    'Feature Engineering',
    'Model Building',
    'Business Analytics',
  ],
  'Generative AI': [
    'Generative AI Fundamentals',
    'LLMs',
    'Transformers',
    'Prompt Engineering',
    'Embeddings',
    'Vector Databases',
    'RAG',
    'Fine-tuning',
    'AI Applications',
  ],
  'Agentic AI': [
    'Agent Fundamentals',
    'Agents vs LLMs',
    'Tool Calling',
    'Planning',
    'Memory',
    'Multi-Agent Systems',
    'LangChain',
    'LangGraph',
    'Agentic RAG',
    'Evaluation and Deployment',
  ],
  'Azure DevOps': [
    'Azure Fundamentals',
    'Azure Repos',
    'Git',
    'Branching',
    'Azure Pipelines',
    'CI/CD',
    'YAML Pipelines',
    'Azure Boards',
    'Test Plans',
    'Releases',
    'Monitoring',
  ],
  'Data Engineering': [
    'Data Engineering Fundamentals',
    'ETL',
    'ELT',
    'Data Warehousing',
    'Data Lakes',
    'Apache Spark',
    'Databricks',
    'Snowflake',
    'Airflow',
    'Data Pipelines',
    'Batch Processing',
    'Streaming',
    'Data Quality',
  ],
};

final List<Course> availableCourses = _buildAvailableCourses();

List<Course> _buildAvailableCourses() {
  final courses = [
    Course(
      title: 'Python Programming',
      subtitle: 'Build logic, syntax, and real-world Python skills',
      category: 'Programming',
      level: 'Beginner',
      duration: '8 Weeks',
      lessons: '4 Lessons',
      icon: Icons.code,
      color: Colors.blue,
      topics: [
        CourseTopic(
          title: 'Python Fundamentals',
          introduction: 'Python is a beginner-friendly language used for websites, automation, data science, and AI.',
          explanation: 'Python is a high-level, interpreted programming language. It focuses on readability and simple syntax, so learners can write logic quickly without complicated setup. In real projects, Python is used for building apps, automating workflow, cleaning data, and creating machine learning models.',
          importantConcepts: [
            'Variables',
            'Data types',
            'Operators',
            'Input and output',
            'Basic syntax',
          ],
          code: 'name = "LearnHub"\nprint(f"Welcome to {name}!")\nprint(5 + 3)',
          expectedOutput: 'Welcome to LearnHub!\n8',
          realWorldApplications: 'Python powers automation scripts, web backends, analytics dashboards, and AI tooling.',
          practiceExercises: [
            'Create a variable for your name and print it.',
            'Write a small script that adds two numbers.',
            'Print two statements using one variable.',
          ],
          quizQuestions: [
            LessonQuizQuestion(
              question: 'Which keyword is used to define a function in Python?',
              options: ['fun', 'def', 'function', 'lambda'],
              correctIndex: 1,
              explanation:
                  'Functions in Python are created with the def keyword.',
            ),
            LessonQuizQuestion(
              question: 'What does print() do?',
              options: [
                'Creates a file',
                'Displays output',
                'Saves data',
                'Deletes variables',
              ],
              correctIndex: 1,
              explanation: 'The print() function displays text or values in the console.',
            ),
          ],
        ),
        CourseTopic(
          title: 'Variables and Data Types',
          introduction: 'Variables store information, and Python data types decide how that data behaves.',
          explanation: 'In Python, variables are created when you assign a value. Data types include integers, floats, strings, booleans, and lists. These types help the language understand whether values should be counted, compared, or displayed.',
          importantConcepts: ['int', 'float', 'str', 'bool', 'type conversion'],
          code: 'age = 21\nscore = 95.5\nname = "Aisha"\nactive = True\nprint(type(age), type(score), type(name), type(active))',
          expectedOutput: '<class \'int\'> <class \'float\'> <class \'str\'> <class \'bool\'>',
          realWorldApplications: 'Data types are used in forms, business logic, dashboards, and scientific calculations.',
          practiceExercises: [
            'Create a variable storing your age.',
            'Convert a string number to an integer.',
            'Check the type of a boolean variable.',
          ],
          quizQuestions: [
            LessonQuizQuestion(
              question: 'Which type is best for decimal numbers?',
              options: ['int', 'str', 'float', 'list'],
              correctIndex: 2,
              explanation: 'A float stores decimal values such as 8.5 or 3.14.',
            ),
            LessonQuizQuestion(
              question: 'What is a boolean value?',
              options: ['Text', 'True or False', 'Decimal', 'Date'],
              correctIndex: 1,
              explanation:
                  'Boolean values represent true/false conditions in Python.',
            ),
          ],
        ),
        CourseTopic(
          title: 'Control Flow and Functions',
          introduction: 'Logic in Python is controlled using conditions and loops so programs can make decisions.',
          explanation: 'Python uses if, elif, and else statements to decide which block of code runs. Functions help organize repeated tasks, making code cleaner and reusable. Loops allow a program to repeat actions without writing the same code many times.',
          importantConcepts: [
            'if/else',
            'for loops',
            'while loops',
            'functions',
            'return values',
          ],
          code: 'def is_even(number):\n    return number % 2 == 0\n\nfor n in [2, 5, 8]:\n    print(f"{n} is even: {is_even(n)}")',
          expectedOutput: '2 is even: True\n5 is even: False\n8 is even: True',
          realWorldApplications: 'Control flow is used in validation, bots, dashboards, and decision-based systems.',
          practiceExercises: [
            'Write a function that checks if a number is positive.',
            'Use a loop to print numbers 1 through 5.',
            'Write an if condition for pass/fail logic.',
          ],
          quizQuestions: [
            LessonQuizQuestion(
              question: 'What does a for loop do?',
              options: [
                'Runs code once',
                'Repeats code over a sequence',
                'Ends the program',
                'Creates a variable',
              ],
              correctIndex: 1,
              explanation: 'A for loop iterates through each item in a sequence or collection.',
            ),
            LessonQuizQuestion(
              question: 'Which statement handles a false condition?',
              options: ['else', 'print', 'return', 'break'],
              correctIndex: 0,
              explanation:
                  'The else block runs when the if condition is false.',
            ),
          ],
        ),
        CourseTopic(
          title: 'Lists, Dictionaries, and OOP',
          introduction: 'Python data structures and objects help manage real-world information efficiently.',
          explanation: 'Lists and dictionaries are powerful ways to store multiple values. Object-oriented programming (OOP) organizes code into classes and objects. This is useful when building apps, models, or reusable modules.',
          importantConcepts: [
            'lists',
            'dictionaries',
            'classes',
            'objects',
            'methods',
          ],
          code: 'student = {"name": "Sam", "score": 90}\nprint(student["name"])\n\nclass Student:\n    def __init__(self, name):\n        self.name = name\n\nprint(Student("Ava").name)',
          expectedOutput: 'Sam\nAva',
          realWorldApplications: 'These patterns are used in product catalogs, student records, and data-driven software systems.',
          practiceExercises: [
            'Create a list of three favorite courses.',
            'Store a student profile in a dictionary.',
            'Create a simple class with one method.',
          ],
          quizQuestions: [
            LessonQuizQuestion(
              question: 'What is a dictionary used for?',
              options: [
                'Sequential values',
                'Key-value data',
                'Mathematical formulas',
                'File reading',
              ],
              correctIndex: 1,
              explanation: 'A dictionary stores data as key-value pairs for quick lookup.',
            ),
            LessonQuizQuestion(
              question: 'What is a class in Python?',
              options: [
                'A loop',
                'A blueprint for objects',
                'A file handle',
                'A list',
              ],
              correctIndex: 1,
              explanation:
                  'A class defines a template from which objects are created.',
            ),
          ],
        ),
      ],
    ),
    Course(
      title: 'SQL / Database Management',
      subtitle: 'Query, organize, and understand structured data',
      category: 'Database',
      level: 'Beginner to Advanced',
      duration: '6 Weeks',
      lessons: '4 Lessons',
      icon: Icons.storage,
      color: Colors.orange,
      topics: [
        CourseTopic(
          title: 'SQL Fundamentals',
          introduction: 'SQL is the standard language for interacting with relational databases.',
          explanation: 'SQL lets you create tables, insert data, fetch records, and update information. It is used in business apps, analytics, and reporting systems where data is stored in rows and tables.',
          importantConcepts: ['SELECT', 'FROM', 'WHERE', 'ORDER BY', 'LIMIT'],
          code: 'SELECT name, score\nFROM students\nWHERE score > 80\nORDER BY score DESC;',
          expectedOutput: 'name | score\nAsha | 95\nRiya | 88',
          realWorldApplications: 'SQL powers dashboards, backend data access, user management, and reporting tools.',
          practiceExercises: [
            'Write a query to list all students.',
            'Filter students scoring above 75.',
            'Sort records by descending score.',
          ],
          quizQuestions: [
            LessonQuizQuestion(
              question: 'What does SELECT do in SQL?',
              options: [
                'Creates a table',
                'Reads data',
                'Deletes records',
                'Adds a column',
              ],
              correctIndex: 1,
              explanation: 'SELECT retrieves data from one or more tables.',
            ),
            LessonQuizQuestion(
              question: 'Which clause filters records?',
              options: ['GROUP BY', 'WHERE', 'JOIN', 'DELETE'],
              correctIndex: 1,
              explanation: 'WHERE filters rows before they are returned.',
            ),
          ],
        ),
        CourseTopic(
          title: 'Joins and Relationships',
          introduction:
              'Joins connect data across different tables using shared keys.',
          explanation: 'Relationships between tables are essential in relational databases. INNER JOIN, LEFT JOIN, and RIGHT JOIN allow developers to combine rows from different tables and answer complex business questions.',
          importantConcepts: [
            'primary key',
            'foreign key',
            'INNER JOIN',
            'LEFT JOIN',
            'relationships',
          ],
          code: 'SELECT students.name, courses.course_name\nFROM students\nINNER JOIN courses ON students.course_id = courses.id;',
          expectedOutput: 'name | course_name\nAsha | Data Science\nRiya | SQL',
          realWorldApplications: 'Joins are used in reporting, user profiles, and order and customer analytics.',
          practiceExercises: [
            'Join students to their departments.',
            'Find customers and their orders.',
            'Use LEFT JOIN to show all records even without matches.',
          ],
          quizQuestions: [
            LessonQuizQuestion(
              question: 'What is a foreign key?',
              options: [
                'A unique login ID',
                'A value that references another table',
                'A SQL function',
                'A data type',
              ],
              correctIndex: 1,
              explanation: 'A foreign key links a row in one table to a row in another table.',
            ),
            LessonQuizQuestion(
              question: 'What does INNER JOIN do?',
              options: [
                'Shows all rows from both tables',
                'Shows only matching rows',
                'Deletes duplicates',
                'Sorts data',
              ],
              correctIndex: 1,
              explanation: 'INNER JOIN returns only rows that have matching values in both tables.',
            ),
          ],
        ),
        CourseTopic(
          title: 'Aggregations and Grouping',
          introduction:
              'SQL aggregation helps summarize large datasets quickly.',
          explanation: 'Aggregation functions such as COUNT, SUM, AVG, MIN, and MAX help answer business questions like how many customers bought a product or what the average sales value is. GROUP BY organizes result sets by a category.',
          importantConcepts: [
            'COUNT()',
            'SUM()',
            'AVG()',
            'GROUP BY',
            'HAVING',
          ],
          code: 'SELECT department, AVG(score) AS avg_score\nFROM students\nGROUP BY department\nHAVING AVG(score) > 80;',
          expectedOutput: 'department | avg_score\nAI | 89.5\nData | 84.1',
          realWorldApplications: 'This is used in sales summaries, attendance reports, and performance dashboards.',
          practiceExercises: [
            'Find total revenue per category.',
            'Count customers by city.',
            'Show average marks grouped by course.',
          ],
          quizQuestions: [
            LessonQuizQuestion(
              question: 'Which function calculates the average value?',
              options: ['SUM()', 'AVG()', 'MAX()', 'COUNT()'],
              correctIndex: 1,
              explanation:
                  'AVG() returns the arithmetic mean of a numeric column.',
            ),
            LessonQuizQuestion(
              question: 'Why use GROUP BY?',
              options: [
                'To delete rows',
                'To summarize rows by category',
                'To update values',
                'To create indexes',
              ],
              correctIndex: 1,
              explanation: 'GROUP BY arranges rows into groups so aggregate functions can summarize each group.',
            ),
          ],
        ),
        CourseTopic(
          title: 'Transactions and Constraints',
          introduction: 'Database reliability comes from transactions and rules that protect data integrity.',
          explanation: 'Transactions ensure that a group of database changes either all succeed or all fail together. Constraints such as NOT NULL, UNIQUE, and CHECK keep data valid and consistent across the system.',
          importantConcepts: [
            'BEGIN TRANSACTION',
            'COMMIT',
            'ROLLBACK',
            'UNIQUE',
            'CHECK',
          ],
          code: 'BEGIN;\nINSERT INTO accounts (id, balance) VALUES (101, 500);\nUPDATE accounts SET balance = balance - 100 WHERE id = 101;\nCOMMIT;',
          expectedOutput: 'Transaction committed successfully',
          realWorldApplications: 'Transactions protect banking, shopping carts, and payroll systems from partial updates.',
          practiceExercises: [
            'Write a transaction that updates inventory after a sale.',
            'Add a UNIQUE constraint to an email field.',
            'Explain what ROLLBACK does.',
          ],
          quizQuestions: [
            LessonQuizQuestion(
              question: 'What does COMMIT do?',
              options: [
                'Cancels a query',
                'Saves a transaction permanently',
                'Deletes rows',
                'Skips validation',
              ],
              correctIndex: 1,
              explanation: 'COMMIT finalizes the transaction and makes the changes permanent.',
            ),
            LessonQuizQuestion(
              question: 'Why use CHECK constraints?',
              options: [
                'To speed up joins',
                'To enforce valid data rules',
                'To create reports',
                'To format strings',
              ],
              correctIndex: 1,
              explanation: 'CHECK constraints ensure values satisfy specific rules before being saved.',
            ),
          ],
        ),
      ],
    ),
    Course(
      title: 'Data Science',
      subtitle: 'Analyze data, uncover patterns, and communicate insights',
      category: 'Data',
      level: 'Intermediate',
      duration: '12 Weeks',
      lessons: '4 Lessons',
      icon: Icons.analytics,
      color: Colors.teal,
      topics: [
        CourseTopic(
          title: 'Data Collection and Cleaning',
          introduction: 'Good analysis starts with clean, trusted data from the right source.',
          explanation: 'Data science begins by collecting data from files, APIs, logs, forms, and databases. Cleaning removes duplicates, fills missing values, and converts inconsistent values into a consistent format before analysis starts.',
          importantConcepts: [
            'missing values',
            'duplicates',
            'data types',
            'normalization',
            'quality checks',
          ],
          code: 'import pandas as pd\n\ndf = pd.DataFrame({"age": [25, None, 35, 25], "score": [80, 90, 85, 95]})\ndf["age"] = df["age"].fillna(df["age"].mean())\nprint(df)',
          expectedOutput:
              '   age score\n0 25.0 80\n1 30.0 90\n2 35.0 85\n3 25.0 95',
          realWorldApplications: 'Cleaning is essential in healthcare, finance, customer analytics, and operations.',
          practiceExercises: [
            'Fill missing age values with the mean.',
            'Drop duplicate rows from a dataset.',
            'Convert a text date column to datetime.',
          ],
          quizQuestions: [
            LessonQuizQuestion(
              question: 'Why is data cleaning important?',
              options: [
                'It reduces model speed',
                'It improves accuracy and trust',
                'It creates graphs',
                'It writes SQL',
              ],
              correctIndex: 1,
              explanation: 'Clean data reduces noise and improves the reliability of analysis.',
            ),
            LessonQuizQuestion(
              question: 'What is a duplicate row?',
              options: [
                'A missing value',
                'A repeated record',
                'An outlier',
                'A new variable',
              ],
              correctIndex: 1,
              explanation: 'Duplicate rows repeat the same information and can distort results.',
            ),
          ],
        ),
        CourseTopic(
          title: 'Exploratory Data Analysis',
          introduction: 'EDA helps you understand patterns, relationships, and anomalies before modeling.',
          explanation: 'Exploratory Data Analysis uses summary statistics and visualizations to understand distributions, trends, and problems in the data. It helps decide which features matter and which assumptions are valid.',
          importantConcepts: [
            'summary statistics',
            'correlation',
            'outliers',
            'distribution',
            'patterns',
          ],
          code: 'import pandas as pd\n\ndf = pd.DataFrame({"hours": [1, 2, 5, 8], "score": [50, 55, 85, 95]})\nprint(df.corr())',
          expectedOutput: '      hours     score\nhours 1.000000 0.979....',
          realWorldApplications: 'EDA is used in market research, performance analysis, and customer segmentation.',
          practiceExercises: [
            'Calculate the mean of a feature column.',
            'Plot a histogram of student marks.',
            'Inspect correlation between sales and ads spend.',
          ],
          quizQuestions: [
            LessonQuizQuestion(
              question: 'What is EDA?',
              options: [
                'A model-building technique',
                'A data exploration process',
                'A SQL command',
                'A deployment step',
              ],
              correctIndex: 1,
              explanation: 'EDA means exploring the dataset to understand patterns and quality before modeling.',
            ),
            LessonQuizQuestion(
              question: 'What does correlation show?',
              options: [
                'The missing values count',
                'How strongly values move together',
                'The file size',
                'The number of rows',
              ],
              correctIndex: 1,
              explanation: 'Correlation measures how strongly two variables move together.',
            ),
          ],
        ),
        CourseTopic(
          title: 'Statistics and Visualization',
          introduction: 'Statistics and charts turn raw numbers into meaningful stories and decisions.',
          explanation: 'Visualization is a powerful tool for understanding data distributions and trends. Measures like mean, median, variance, and standard deviation summarize the dataset and help explain how spread out values are.',
          importantConcepts: [
            'mean',
            'median',
            'variance',
            'standard deviation',
            'charts',
          ],
          code: 'import matplotlib.pyplot as plt\n\nvalues = [10, 12, 15, 18, 20]\nplt.plot(values)\nplt.title("Sample Trend")\nplt.show()',
          expectedOutput: 'A simple line chart with rising values',
          realWorldApplications: 'Visualization is used in business reports, scientific dashboards, and product analytics.',
          practiceExercises: [
            'Compute the median of a list of values.',
            'Plot a bar chart comparing sales by region.',
            'Explain what standard deviation means in plain language.',
          ],
          quizQuestions: [
            LessonQuizQuestion(
              question: 'Which metric shows the average value?',
              options: ['Median', 'Mode', 'Mean', 'Range'],
              correctIndex: 2,
              explanation: 'Mean is the sum of all values divided by the number of values.',
            ),
            LessonQuizQuestion(
              question: 'Why use visualization?',
              options: [
                'To increase storage',
                'To make patterns easier to understand',
                'To clean the data',
                'To write SQL',
              ],
              correctIndex: 1,
              explanation: 'Visualizations help people quickly understand trends, anomalies, and comparisons.',
            ),
          ],
        ),
        CourseTopic(
          title: 'Machine Learning Foundations',
          introduction: 'Data science often leads into machine learning, where models learn patterns from data.',
          explanation: 'Machine learning models are trained on historical data and then used to predict outcomes or classify new data. Understanding the relationship between features and labels is the foundation of supervised and unsupervised learning.',
          importantConcepts: [
            'features',
            'labels',
            'training',
            'prediction',
            'evaluation',
          ],
          code: 'from sklearn.linear_model import LinearRegression\nimport numpy as np\n\nX = np.array([[1], [2], [3], [4]])\ny = np.array([1, 3, 5, 7])\nmodel = LinearRegression()\nmodel.fit(X, y)\nprint(model.predict([[5]]))',
          expectedOutput: '[9.]',
          realWorldApplications: 'ML powers recommendations, fraud detection, demand forecasting, and image recognition.',
          practiceExercises: [
            'Train a basic model on a small dataset.',
            'Compare actual and predicted outcomes.',
            'Describe the difference between feature and label.',
          ],
          quizQuestions: [
            LessonQuizQuestion(
              question: 'What is a feature?',
              options: [
                'The output value',
                'A measurable input used to predict',
                'A model class',
                'A database query',
              ],
              correctIndex: 1,
              explanation: 'Features are the input variables used by the model to make predictions.',
            ),
            LessonQuizQuestion(
              question: 'What does a model learn from data?',
              options: [
                'A file path',
                'Patterns and relationships',
                'A website layout',
                'A database schema',
              ],
              correctIndex: 1,
              explanation: 'Machine learning models learn patterns between input variables and target labels.',
            ),
          ],
        ),
      ],
    ),
    Course(
      title: 'Machine Learning',
      subtitle: 'Train models to predict outcomes and solve real problems',
      category: 'AI & Machine Learning',
      level: 'Advanced',
      duration: '10 Weeks',
      lessons: '4 Lessons',
      icon: Icons.psychology,
      color: Colors.purple,
      topics: [
        CourseTopic(
          title: 'Linear Regression',
          introduction: 'Linear regression finds a relationship between input values and a continuous target.',
          explanation: 'This algorithm models a line or plane that best fits the data. It is commonly used to predict prices, temperatures, and sales based on historical observations.',
          importantConcepts: [
            'response variable',
            'predictor variables',
            'best-fit line',
            'error',
            'loss function',
          ],
          code: 'from sklearn.linear_model import LinearRegression\nimport numpy as np\n\nX = np.array([[1], [2], [3], [4]])\ny = np.array([2, 4, 6, 8])\nmodel = LinearRegression()\nmodel.fit(X, y)\nprint(model.predict([[5]]))',
          expectedOutput: '[10.]',
          realWorldApplications:
              'Predicting house prices, sales forecasts, and energy demand.',
          practiceExercises: [
            'Fit a model for monthly sales data.',
            'Interpret the slope value.',
            'Predict a future value using the trained model.',
          ],
          quizQuestions: [
            LessonQuizQuestion(
              question: 'What is linear regression used for?',
              options: [
                'Grouping categories',
                'Predicting a continuous value',
                'Sorting data',
                'Reading SQL tables',
              ],
              correctIndex: 1,
              explanation: 'Linear regression predicts a continuous target such as price or temperature.',
            ),
            LessonQuizQuestion(
              question: 'What does the line represent?',
              options: [
                'A random guess',
                'The best-fit relationship',
                'A static value',
                'A dictionary',
              ],
              correctIndex: 1,
              explanation: 'The line represents the estimated relationship between inputs and output.',
            ),
          ],
        ),
        CourseTopic(
          title: 'Classification and Decision Trees',
          introduction: 'Classification groups data into categories such as spam or not spam.',
          explanation: 'Decision trees split data based on feature values to form rules. They are easy to understand and work well for many classification problems, including customer churn and credit scoring.',
          importantConcepts: [
            'classes',
            'splits',
            'entropy',
            'gini impurity',
            'decision boundary',
          ],
          code: 'from sklearn.tree import DecisionTreeClassifier\n\nX = [[1], [2], [3], [4]]\ny = [0, 0, 1, 1]\nmodel = DecisionTreeClassifier()\nmodel.fit(X, y)\nprint(model.predict([[2.5]]))',
          expectedOutput: '[0] or [1] depending on training split',
          realWorldApplications: 'Spam detection, loan approval, disease diagnosis, and churn prediction.',
          practiceExercises: [
            'Label a small dataset for spam detection.',
            'Build a decision tree using two features.',
            'Explain why a split is chosen.',
          ],
          quizQuestions: [
            LessonQuizQuestion(
              question: 'What does classification do?',
              options: [
                'Predicts a continuous value',
                'Assigns a category',
                'Creates a table',
                'Updates data',
              ],
              correctIndex: 1,
              explanation:
                  'Classification predicts which class an item belongs to.',
            ),
            LessonQuizQuestion(
              question: 'What is a decision tree?',
              options: [
                'A SQL join',
                'A tree of yes/no rules',
                'A dataset',
                'A chart type',
              ],
              correctIndex: 1,
              explanation: 'A decision tree splits the data using rule-based conditions to reach a prediction.',
            ),
          ],
        ),
        CourseTopic(
          title: 'Model Evaluation',
          introduction: 'A model is only useful if it is measured correctly on real data.',
          explanation: 'Model evaluation checks how well a model performs on unseen examples. Metrics such as accuracy, precision, recall, and F1-score show whether predictions are trustworthy and where errors occur.',
          importantConcepts: [
            'accuracy',
            'precision',
            'recall',
            'F1 score',
            'overfitting',
          ],
          code: 'from sklearn.metrics import accuracy_score\n\nactual = [1, 0, 1, 0]\npredicted = [1, 0, 0, 0]\nprint(accuracy_score(actual, predicted))',
          expectedOutput: '0.75',
          realWorldApplications: 'Model evaluation is used in healthcare, credit risk, and recommendation systems.',
          practiceExercises: [
            'Calculate accuracy using a confusion matrix.',
            'Explain the difference between precision and recall.',
            'Identify overfitting in a chart.',
          ],
          quizQuestions: [
            LessonQuizQuestion(
              question: 'What does accuracy measure?',
              options: [
                'Total training time',
                'Correct predictions divided by total predictions',
                'Input feature count',
                'Model complexity',
              ],
              correctIndex: 1,
              explanation:
                  'Accuracy tells how often the model is right overall.',
            ),
            LessonQuizQuestion(
              question: 'What is overfitting?',
              options: [
                'Using too little data',
                'Model learns noise instead of pattern',
                'A missing library',
                'Too few training steps',
              ],
              correctIndex: 1,
              explanation: 'Overfitting happens when a model memorizes training data and does poorly on new data.',
            ),
          ],
        ),
        CourseTopic(
          title: 'Feature Engineering and Deployment',
          introduction: 'Better features and clean deployment pipelines greatly improve a model’s value.',
          explanation: 'Feature engineering transforms raw data into useful signals for the model. Deployment moves the trained model into production, where it can serve predictions to users or applications in real time.',
          importantConcepts: [
            'feature scaling',
            'encoding',
            'pipeline',
            'monitoring',
            'deployment',
          ],
          code: 'from sklearn.preprocessing import StandardScaler\nimport numpy as np\n\nX = np.array([[10], [20], [30]])\nscaler = StandardScaler()\nprint(scaler.fit_transform(X))',
          expectedOutput: '[-1.22474487  0.          1.22474487]',
          realWorldApplications: 'Used in real-time recommendation engines, healthcare prediction tools, and intelligent search systems.',
          practiceExercises: [
            'Scale numeric data before training.',
            'Create a simple deployment workflow diagram.',
            'Explain why feature quality matters.',
          ],
          quizQuestions: [
            LessonQuizQuestion(
              question: 'What is feature scaling?',
              options: [
                'Removing data',
                'Adjusting values to a common range',
                'Adding labels',
                'Creating charts',
              ],
              correctIndex: 1,
              explanation: 'Feature scaling normalizes the range of values so algorithms perform more consistently.',
            ),
            LessonQuizQuestion(
              question: 'What does deployment mean?',
              options: [
                'Writing a model notebook',
                'Putting the model into a real application',
                'Collecting data',
                'Deleting the model',
              ],
              correctIndex: 1,
              explanation: 'Deployment makes the trained model available for live predictions in applications or services.',
            ),
          ],
        ),
      ],
    ),
    Course(
      title: 'Generative AI',
      subtitle: 'Understand LLMs, prompting, retrieval, and AI creativity',
      category: 'AI & Machine Learning',
      level: 'Advanced',
      duration: '8 Weeks',
      lessons: '4 Lessons',
      icon: Icons.auto_awesome,
      color: Colors.deepPurple,
      topics: [
        CourseTopic(
          title: 'Prompt Engineering',
          introduction: 'Prompt engineering shapes how an AI model responds to a user request.',
          explanation: 'The way a prompt is written strongly influences output quality. Good prompts include clear instructions, context, examples, and constraints. This helps the model give relevant and useful answers.',
          importantConcepts: [
            'instructions',
            'context',
            'examples',
            'constraints',
            'iteration',
          ],
          code: 'prompt = "Summarize this in 3 bullet points for a student. Keep it simple and practical."\nresponse = "AI helps automate tasks, supports decision-making, and improves productivity."',
          expectedOutput: 'Three short bullets explaining AI in simple student-friendly language',
          realWorldApplications: 'Used in copilots, writing assistants, search summaries, and educational tutors.',
          practiceExercises: [
            'Write a prompt to explain a concept to a beginner.',
            'Use a prompt that asks for a table of comparison.',
            'Refine a weak prompt to improve quality.',
          ],
          quizQuestions: [
            LessonQuizQuestion(
              question: 'What is prompt engineering?',
              options: [
                'Writing SQL queries',
                'Designing inputs that guide AI output',
                'Training a database',
                'Configuring routers',
              ],
              correctIndex: 1,
              explanation: 'Prompt engineering is the process of crafting instructions to improve model responses.',
            ),
            LessonQuizQuestion(
              question: 'Why add context in a prompt?',
              options: [
                'To reduce performance',
                'To help the model understand the task',
                'To delete output',
                'To make the code longer',
              ],
              correctIndex: 1,
              explanation: 'Context gives the model useful background so it can respond more accurately.',
            ),
          ],
        ),
        CourseTopic(
          title: 'LLMs and Transformers',
          introduction: 'Large Language Models (LLMs) generate text by learning patterns in data.',
          explanation: 'LLMs are trained on massive datasets and use transformer architectures to process language with attention. This allows them to generate text, summarize content, answer questions, and support many language tasks.',
          importantConcepts: [
            'LLM',
            'transformer',
            'attention',
            'token',
            'context window',
          ],
          code: 'prompt = "Explain transformer models in one sentence."\nprint(prompt)',
          expectedOutput: 'Explain transformer models in one sentence.',
          realWorldApplications: 'Used in chatbots, translation tools, code assistants, and knowledge search.',
          practiceExercises: [
            'Explain the purpose of attention in a transformer.',
            'Compare a language model to a search engine.',
            'Describe a token in your own words.',
          ],
          quizQuestions: [
            LessonQuizQuestion(
              question: 'What does LLM stand for?',
              options: [
                'Large Language Model',
                'Low-Level Memory',
                'Logic Language Method',
                'Large Learning Map',
              ],
              correctIndex: 0,
              explanation: 'LLM stands for Large Language Model, a model trained on large language datasets.',
            ),
            LessonQuizQuestion(
              question: 'What is attention in transformers?',
              options: [
                'A hardware button',
                'A mechanism that focuses on relevant input parts',
                'A database type',
                'A file extension',
              ],
              correctIndex: 1,
              explanation: 'Attention helps a model decide which words or tokens are most relevant at each step.',
            ),
          ],
        ),
        CourseTopic(
          title: 'RAG and Knowledge Retrieval',
          introduction: 'RAG improves AI answers by grounding them in external knowledge.',
          explanation: 'Retrieval-Augmented Generation (RAG) first searches relevant documents or databases, then uses that information to generate better responses. This reduces hallucination and makes answers more factual and domain-specific.',
          importantConcepts: [
            'retrieval',
            'vector search',
            'grounding',
            'hallucination',
            'RAG',
          ],
          code: 'question = "What is the latest policy on remote work?"\nretrieved_docs = ["Policy update: Employees may work remotely 3 days a week."]\nprint(retrieved_docs[0])',
          expectedOutput:
              'Policy update: Employees may work remotely 3 days a week.',
          realWorldApplications: 'Enterprise search assistants, legal research tools, support bots, and internal knowledge chat tools.',
          practiceExercises: [
            'Explain why RAG reduces hallucination.',
            'List steps in a basic RAG pipeline.',
            'Describe the role of vector search.',
          ],
          quizQuestions: [
            LessonQuizQuestion(
              question: 'What does RAG stand for?',
              options: [
                'Real-time AI Generation',
                'Retrieval-Augmented Generation',
                'Reasoning and Graphing',
                'Rapid Access Gateway',
              ],
              correctIndex: 1,
              explanation: 'RAG combines retrieval of relevant information with generation to produce better answers.',
            ),
            LessonQuizQuestion(
              question: 'Why use RAG?',
              options: [
                'To avoid all prompts',
                'To ground answers in real knowledge',
                'To increase code size',
                'To replace databases',
              ],
              correctIndex: 1,
              explanation: 'RAG improves answer quality by fetching relevant external context before generating a response.',
            ),
          ],
        ),
        CourseTopic(
          title: 'AI Agents and Multimodal Models',
          introduction: 'Generative AI is moving beyond simple chat into agents and multi-skill workflows.',
          explanation: 'AI agents can plan steps, use tools, and perform tasks such as searching the web, reading files, or writing code. Multimodal models can work with text, images, audio, and other inputs together.',
          importantConcepts: [
            'agents',
            'tool calling',
            'planning',
            'multimodal',
            'automation',
          ],
          code: 'task = "Find tickets, summarize issues, and suggest a fix"\nprint(task)',
          expectedOutput: 'Find tickets, summarize issues, and suggest a fix',
          realWorldApplications: 'Virtual assistants, code copilots, research bots, and workflow automation tools.',
          practiceExercises: [
            'Design a simple AI agent workflow for customer support.',
            'List tools an agent might use.',
            'Explain why multimodal models matter.',
          ],
          quizQuestions: [
            LessonQuizQuestion(
              question: 'What is an AI agent?',
              options: [
                'A database engine',
                'A system that can plan and act on tasks',
                'A type of SQL query',
                'A training loop',
              ],
              correctIndex: 1,
              explanation: 'An AI agent uses tools and reasoning to carry out tasks beyond a single response.',
            ),
            LessonQuizQuestion(
              question: 'What does multimodal mean?',
              options: [
                'One type of input only',
                'Multiple data types such as text and image',
                'A hardware module',
                'A coding style',
              ],
              correctIndex: 1,
              explanation: 'Multimodal models can understand or generate different input and output types together.',
            ),
          ],
        ),
      ],
    ),
    Course(
      title: 'Agentic AI',
      subtitle: 'Design agents that plan, use tools, and complete tasks',
      category: 'AI & Machine Learning',
      level: 'Intermediate',
      duration: '4 Weeks',
      lessons: '2 Lessons',
      icon: Icons.smart_toy_outlined,
      color: Colors.deepPurple,
      topics: [
        CourseTopic(
          title: 'Agent Planning and Tools',
          introduction: 'An AI agent combines a model with a goal, a plan, and tools it can use.',
          explanation: 'An agent breaks a request into steps, selects an appropriate tool, observes its result, and decides what to do next. Clear tool contracts and bounded tasks make agent workflows easier to understand and test.',
          importantConcepts: [
            'goals',
            'planning',
            'tool calls',
            'observations',
          ],
          code: 'tools = {"lookup": lambda item: f"Found {item}"}\nresult = tools["lookup"]("course notes")\nprint(result)',
          expectedOutput: 'Found course notes',
          realWorldApplications: 'Agents can triage support requests, search internal knowledge, and coordinate routine workflows.',
          practiceExercises: [
            'Break a support request into three agent steps.',
            'Define one tool input and output contract.',
          ],
          quizQuestions: [
            LessonQuizQuestion(
              question: 'What does a tool allow an agent to do?',
              options: [
                'Access a defined external capability',
                'Change its training data',
                'Skip every validation step',
                'Guarantee a correct answer',
              ],
              correctIndex: 0,
              explanation: 'A tool gives an agent a bounded capability such as searching or calculating.',
            ),
          ],
        ),
        CourseTopic(
          title: 'Reliable Agent Workflows',
          introduction: 'Reliable agents use guardrails, validate tool results, and stop when their task is complete.',
          explanation: 'Agent workflows should limit available actions, check inputs and outputs, and provide a clear stopping condition. Human review is useful for decisions with meaningful impact.',
          importantConcepts: [
            'guardrails',
            'validation',
            'stopping conditions',
            'human review',
          ],
          code: 'approved = {"read", "summarize"}\naction = "summarize"\nprint(action in approved)',
          expectedOutput: 'True',
          realWorldApplications: 'These practices help keep business automation predictable and auditable.',
          practiceExercises: [
            'Add a stopping rule to a multi-step agent task.',
            'Identify an action that should require human approval.',
          ],
          quizQuestions: [
            LessonQuizQuestion(
              question: 'Why should an agent validate a tool result?',
              options: [
                'To check that it is usable before continuing',
                'To make the workflow run forever',
                'To remove its stopping condition',
                'To avoid recording decisions',
              ],
              correctIndex: 0,
              explanation: 'Validation helps prevent incorrect or unexpected tool output from propagating.',
            ),
          ],
        ),
      ],
    ),
    Course(
      title: 'Azure DevOps',
      subtitle: 'Build and release software with collaborative DevOps tools',
      category: 'Cloud & DevOps',
      level: 'Beginner',
      duration: '4 Weeks',
      lessons: '2 Lessons',
      icon: Icons.cloud_outlined,
      color: Colors.blue,
      topics: [
        CourseTopic(
          title: 'CI Pipelines and YAML',
          introduction: 'A continuous integration pipeline builds and checks code whenever it changes.',
          explanation: 'Pipeline definitions describe repeatable stages such as installing dependencies, running tests, and publishing build artifacts. Keeping the pipeline with the source code makes changes reviewable.',
          importantConcepts: [
            'continuous integration',
            'pipeline stages',
            'YAML',
            'build artifacts',
          ],
          code: 'trigger:\n- main\nsteps:\n- script: echo "Run tests"\n  displayName: Test',
          expectedOutput:
              'The pipeline runs the test step for changes to main.',
          realWorldApplications: 'Teams use CI pipelines to catch regressions and produce consistent builds.',
          practiceExercises: [
            'Add a test stage to a sample pipeline.',
            'Explain why build steps should be repeatable.',
          ],
          quizQuestions: [
            LessonQuizQuestion(
              question: 'What is a main purpose of continuous integration?',
              options: [
                'Build and check changes frequently',
                'Skip code review',
                'Store passwords in source files',
                'Run production without tests',
              ],
              correctIndex: 0,
              explanation: 'CI automatically builds and checks code so problems are found earlier.',
            ),
          ],
        ),
        CourseTopic(
          title: 'Release and Deployment',
          introduction: 'Continuous delivery prepares tested software for a controlled release.',
          explanation: 'A release pipeline can publish a build to a test environment, run verification, and then promote it using approval gates. Separating environments reduces deployment risk.',
          importantConcepts: [
            'release stages',
            'environments',
            'approval gates',
            'rollback',
          ],
          code: 'stages:\n- stage: DeployTest\n  jobs:\n  - job: Verify\n    steps:\n    - script: echo "Deploy to test"',
          expectedOutput: 'A deployment stage runs a verification job in the test environment.',
          realWorldApplications: 'Release pipelines support predictable software delivery across development, test, and production.',
          practiceExercises: [
            'Draw a three-environment release flow.',
            'Choose where a manual approval should be required.',
          ],
          quizQuestions: [
            LessonQuizQuestion(
              question: 'Why use separate deployment environments?',
              options: [
                'To verify changes before production',
                'To avoid testing',
                'To duplicate source code manually',
                'To disable rollback options',
              ],
              correctIndex: 0,
              explanation: 'Separate environments allow a release to be checked before reaching users.',
            ),
          ],
        ),
      ],
    ),
    Course(
      title: 'Data Engineering',
      subtitle: 'Move, transform, and organize data for analytics',
      category: 'Data',
      level: 'Intermediate',
      duration: '4 Weeks',
      lessons: '2 Lessons',
      icon: Icons.storage_outlined,
      color: Colors.teal,
      topics: [
        CourseTopic(
          title: 'ETL Data Pipelines',
          introduction: 'Data pipelines collect source data, transform it, and deliver it to a useful destination.',
          explanation: 'An ETL workflow extracts records from a source, transforms them into a consistent shape, and loads them into a destination. Reliable pipelines validate data and report failures.',
          importantConcepts: ['extract', 'transform', 'load', 'validation'],
          code: 'records = [{"amount": 10}, {"amount": 15}]\ntotal = sum(row["amount"] for row in records)\nprint(total)',
          expectedOutput: '25',
          realWorldApplications: 'Pipelines combine application, sales, and operational data for reporting and analysis.',
          practiceExercises: [
            'Add a validation rule for missing amounts.',
            'Describe one retry strategy for a failed pipeline step.',
          ],
          quizQuestions: [
            LessonQuizQuestion(
              question: 'What does the transform step do in ETL?',
              options: [
                'Cleans or reshapes extracted data',
                'Deletes the source system',
                'Disables data checks',
                'Displays a user interface',
              ],
              correctIndex: 0,
              explanation: 'Transform applies needed cleaning and shaping before data is loaded.',
            ),
          ],
        ),
        CourseTopic(
          title: 'Warehousing and Data Quality',
          introduction: 'A data warehouse organizes trusted data so it can be queried for analysis.',
          explanation: 'Warehouse tables are designed for reliable querying and reporting. Data quality checks can catch missing values, duplicates, and unexpected changes before reports are refreshed.',
          importantConcepts: [
            'warehouse',
            'schemas',
            'data quality',
            'batch processing',
          ],
          code: 'SELECT region, SUM(amount) AS revenue\nFROM orders\nGROUP BY region;',
          expectedOutput:
              'One revenue total for each region in the orders table.',
          realWorldApplications: 'Warehouses support dashboards, financial reporting, and historical trend analysis.',
          practiceExercises: [
            'Write a check for duplicate order identifiers.',
            'Group a sample dataset by month and calculate totals.',
          ],
          quizQuestions: [
            LessonQuizQuestion(
              question: 'Why add data-quality checks to a pipeline?',
              options: [
                'To detect bad or unexpected data early',
                'To increase duplicate records',
                'To hide pipeline failures',
                'To prevent downstream analysis',
              ],
              correctIndex: 0,
              explanation: 'Checks catch data issues before they affect downstream reports and decisions.',
            ),
          ],
        ),
      ],
    ),
  ];
  courses.sort(
    (first, second) => courseSubjectOrder
        .indexOf(first.title)
        .compareTo(courseSubjectOrder.indexOf(second.title)),
  );
  addSyllabusChapters(courses);
  return courses;
}

void addSyllabusChapters(List<Course> courses) {
  for (final course in courses) {
    final chapterTitles = courseSyllabus[course.title]!;
    final supplementalTopics = List<CourseTopic>.of(course.topics);
    final syllabusTopics = chapterTitles.asMap().entries.map((entry) {
      return _buildSyllabusChapter(
        course,
        entry.value,
        entry.key,
        chapterTitles.length,
      );
    });

    course.topics
      ..clear()
      ..addAll(syllabusTopics)
      ..addAll(
        supplementalTopics.where(
          (topic) => !chapterTitles.contains(topic.title),
        ),
      );
  }
}

String _chapterLevel(int index, int total) {
  final intermediateStart = (total / 3).ceil();
  final advancedStart = (total * 2 / 3).ceil();
  if (index < intermediateStart) {
    return 'Beginner';
  }
  if (index < advancedStart) {
    return 'Intermediate';
  }
  return 'Advanced';
}

MapEntry<String, String> _chapterCodeExample(Course course, String chapter) {
  if (course.title == 'Python Programming') {
    switch (chapter) {
      case 'Variables':
        return const MapEntry(
          'learner = "Mina"\ncompleted = 3\nprint(learner, completed)',
          'Mina 3',
        );
      case 'Data Types':
        return const MapEntry(
          'score = 87.5\npassed = True\nprint(type(score).__name__, type(passed).__name__)',
          'float bool',
        );
      case 'Operators':
        return const MapEntry(
          'price = 12\nquantity = 3\nprint(price * quantity)',
          '36',
        );
      case 'Conditions':
        return const MapEntry(
          'score = 82\nif score >= 60:\n    print("Pass")\nelse:\n    print("Retry")',
          'Pass',
        );
      case 'Loops':
        return const MapEntry(
          'for chapter in range(1, 4):\n    print(chapter)',
          '1\n2\n3',
        );
      case 'Functions':
        return const MapEntry(
          'def course_label(name):\n    return f"Course: {name}"\nprint(course_label("Python"))',
          'Course: Python',
        );
      case 'OOP':
        return const MapEntry(
          'class Course:\n    def __init__(self, title):\n        self.title = title\nprint(Course("Python").title)',
          'Python',
        );
      case 'Collections':
        return const MapEntry(
          'scores = [72, 88, 91]\nprint(round(sum(scores) / len(scores), 1))',
          '83.7',
        );
      case 'File Handling':
        return const MapEntry(
          'from pathlib import Path\npath = Path("notes.txt")\npath.write_text("Learn Python")\nprint(path.read_text())',
          'Learn Python',
        );
      case 'Exception Handling':
        return const MapEntry(
          'try:\n    value = int("42")\nexcept ValueError:\n    value = 0\nprint(value)',
          '42',
        );
      case 'Modules':
        return const MapEntry(
          'from statistics import mean\nprint(mean([2, 4, 6]))',
          '4',
        );
      default:
        return const MapEntry('import math\nprint(round(math.sqrt(81)))', '9');
    }
  }
  if (course.title == 'SQL / Database Management') {
    switch (chapter) {
      case 'DDL':
        return const MapEntry(
          'CREATE TABLE learners (\n  id INTEGER PRIMARY KEY,\n  name VARCHAR(80) NOT NULL\n);',
          'A learners table is created with a primary key.',
        );
      case 'DML':
        return const MapEntry(
          'INSERT INTO learners (id, name) VALUES (1, \'Mina\');\nSELECT name FROM learners;',
          'name\nMina',
        );
      case 'Joins':
        return const MapEntry(
          'SELECT learners.name, courses.title\nFROM learners\nJOIN courses ON courses.learner_id = learners.id;',
          'Learner names paired with their course titles.',
        );
      case 'Subqueries':
        return const MapEntry(
          'SELECT name FROM learners\nWHERE id IN (SELECT learner_id FROM enrollments);',
          'Learners who have an enrollment.',
        );
      case 'CTEs':
        return const MapEntry(
          'WITH active AS (\n  SELECT id, name FROM learners WHERE active = TRUE\n)\nSELECT name FROM active;',
          'Names of active learners.',
        );
      case 'Window Functions':
        return const MapEntry(
          'SELECT name, score,\n  RANK() OVER (ORDER BY score DESC) AS position\nFROM results;',
          'Scores with a ranking that preserves ties.',
        );
      case 'Indexes':
        return const MapEntry(
          'CREATE INDEX idx_learners_email ON learners(email);',
          'An index is created for learner email lookups.',
        );
      case 'Query Optimization':
        return const MapEntry(
          'EXPLAIN SELECT name FROM learners WHERE active = TRUE;',
          'The database reports the query execution plan.',
        );
      case 'Stored Procedures':
        return const MapEntry(
          'CREATE PROCEDURE list_learners AS\nSELECT id, name FROM learners;',
          'A reusable procedure for listing learners.',
        );
      case 'Database Fundamentals':
        return const MapEntry(
          'CREATE TABLE courses (id INTEGER PRIMARY KEY, title VARCHAR(80));',
          'A relational table with a key and a course title.',
        );
      default:
        return const MapEntry(
          'SELECT name FROM learners WHERE active = TRUE ORDER BY name;',
          'Names of active learners in alphabetical order.',
        );
    }
  }
  if (course.title == 'Machine Learning') {
    final algorithmExample = chapter == 'Regression'
        ? 'from sklearn.linear_model import LinearRegression\nmodel = LinearRegression().fit([[1], [2], [3]], [2, 4, 6])\nprint(round(model.predict([[4]])[0], 1))'
        : 'from sklearn.model_selection import train_test_split\nX_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=7)\nprint(len(X_test))';
    return MapEntry(
      algorithmExample,
      chapter == 'Regression'
          ? '8.0'
          : 'The held-out test set contains one fifth of the observations.',
    );
  }
  if (course.title == 'Data Science') {
    if (chapter == 'NumPy') {
      return const MapEntry(
        'import numpy as np\nvalues = np.array([3, 5, 7])\nprint(values.mean())',
        '5.0',
      );
    }
    return const MapEntry(
      'import pandas as pd\ndf = pd.DataFrame({"region": ["N", "S"], "sales": [12, 18]})\nprint(df["sales"].sum())',
      '30',
    );
  }
  if (course.title == 'Generative AI') {
    return MapEntry(
      'topic = "$chapter"\ncontext = "Use trusted course notes as evidence."\nprompt = f"Explain {topic}. Context: {context}"\nprint(prompt)',
      'A prompt that names the chapter and provides grounding context.',
    );
  }
  if (course.title == 'Agentic AI') {
    return MapEntry(
      'tools = {"search_notes": lambda query: f"Notes for {query}"}\nresult = tools["search_notes"]("$chapter")\nprint(result)',
      'Notes for $chapter',
    );
  }
  if (course.title == 'Azure DevOps') {
    return MapEntry(
      'trigger:\n- main\nsteps:\n- script: echo "Validate $chapter"\n  displayName: Validate',
      'A pipeline step runs a validation command for $chapter.',
    );
  }
  return MapEntry(
    'records = [{"value": 10}, {"value": 20}]\ntotal = sum(row["value"] for row in records)\nprint(total)',
    '30',
  );
}

CourseTopic _buildSyllabusChapter(
  Course course,
  String title,
  int index,
  int total,
) {
  final example = _chapterCodeExample(course, title);
  final level = _chapterLevel(index, total);
  final introduction = switch (course.category) {
    'Programming' =>
      '$title is a core Python skill used to build clear and reusable programs.',
    'Database' =>
      '$title helps you define, query, relate, or improve data stored in relational databases.',
    'AI & Machine Learning' =>
      '$title is an important part of building, applying, or evaluating intelligent systems.',
    'Data' =>
      '$title helps transform raw data into dependable analysis and useful decisions.',
    'Cloud & DevOps' =>
      '$title supports collaborative software delivery and dependable cloud operations.',
    _ => '$title is a foundational practice in modern data engineering.',
  };
  final explanation = switch (course.category) {
    'Programming' =>
      'In this chapter, identify the inputs and expected result, apply $title with Python syntax, and verify behavior with normal and edge-case values. Prefer readable code and small checks so mistakes are easy to find.',
    'Database' =>
      'This chapter applies $title to relational data. Start from the table structure and the result you need, write a focused SQL statement, and inspect its output. Constraints and query plans help keep database behavior correct and efficient.',
    'AI & Machine Learning' =>
      'This chapter explores $title as part of a complete modeling workflow. Define the task and data first, establish a baseline, and use held-out evaluation rather than relying on training results alone. Record assumptions and limitations.',
    'Data' =>
      'This chapter uses $title to make analysis more reliable. Inspect the dataset and its schema, document cleaning choices, and connect calculations to the original question. Visual and statistical checks can reveal errors or unexpected patterns.',
    'Cloud & DevOps' =>
      'This chapter applies $title to a repeatable delivery workflow. Keep configuration reviewable, validate changes before promotion, and use clear environment boundaries and monitoring to detect failures.',
    _ =>
      'This chapter applies $title to a dependable data workflow. Define the source and output contracts, validate records at each step, and make processing repeatable so downstream analysis can trust the result.',
  };
  final quizCorrectAnswer =
      'Apply $title to a small ${course.title} example and verify the result.';

  return CourseTopic(
    title: title,
    level: level,
    introduction: introduction,
    explanation: explanation,
    importantConcepts: [title, course.category, 'validation and review'],
    code: example.key,
    expectedOutput: example.value,
    realWorldApplications:
        '${course.title} teams use $title in production workflows, analysis, and practical problem solving.',
    practiceExercises: [
      'Create a small example that demonstrates $title.',
      'Change one input and explain how the result changes.',
      'Add a validation check and describe one edge case.',
    ],
    assignment:
        'Create a small ${course.title} deliverable that applies $title. Include your example, expected result, a validation check, and a short note explaining one design decision.',
    isSyllabusChapter: true,
    quizQuestions: [
      LessonQuizQuestion(
        question: 'Which activity best demonstrates $title?',
        options: [
          quizCorrectAnswer,
          'Skip validation and assume every result is correct.',
          'Use an unrelated tool without checking its output.',
          'Avoid documenting inputs or expected results.',
        ],
        correctIndex: 0,
        explanation:
            'A focused example with a checked result demonstrates the purpose and practical use of $title.',
      ),
    ],
  );
}

// HOME PAGE

class DashboardRoutePage extends StatelessWidget {
  final Widget child;

  const DashboardRoutePage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LearnHub')),
      body: child,
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: completedLessonRevision,
      builder: (context, revision, child) {
        final totalTopics = availableCourses.fold<int>(
          0,
          (sum, course) => sum + course.topics.length,
        );
        final completedTopics = availableCourses.fold<int>(
          0,
          (sum, course) => sum + course.completedTopicsCount,
        );
        final overallProgress = totalTopics == 0
            ? 0.0
            : completedTopics / totalTopics;

        return SafeArea(
          child: ColoredBox(
            color: Colors.white,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: constraints.maxWidth > 760
                            ? 760
                            : constraints.maxWidth,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'LearnHub',
                                      style: TextStyle(
                                        color: primaryColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    ValueListenableBuilder<LearnHubSettings>(
                                      valueListenable:
                                          LearnHubSettingsStore
                                              .instance
                                              .settings,
                                      builder: (context, settings, child) =>
                                          Text(
                                            _homeGreeting(
                                              settings.learnerName,
                                            ),
                                            style: const TextStyle(
                                              fontSize: 25,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Continue your learning journey',
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                key: const ValueKey('home-notifications'),
                                tooltip: 'Notifications',
                                onPressed: () {
                                  showDialog<void>(
                                    context: context,
                                    builder: (dialogContext) => AlertDialog(
                                      title: const Text('Notifications'),
                                      content: const Text(
                                        'You are all caught up.',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(dialogContext),
                                          child: const Text('Close'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.notifications_none_rounded,
                                  color: primaryColor,
                                  size: 26,
                                ),
                                style: IconButton.styleFrom(
                                  backgroundColor: const Color(0xFFEFF3FF),
                                  minimumSize: const Size(48, 48),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 26),
                          const Text(
                            'My Learning Progress',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Card(
                            key: const ValueKey('home-progress-card'),
                            color: Colors.white,
                            elevation: 2,
                            shadowColor: Colors.black12,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (_) => const MyLearningPage(),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(18),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Expanded(
                                          child: Text(
                                            'My Learning Progress',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '${(overallProgress * 100).round()}%',
                                          style: const TextStyle(
                                            color: Color(0xFF24965A),
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          size: 16,
                                          color: Color(0xFF24965A),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: LinearProgressIndicator(
                                        value: overallProgress,
                                        minHeight: 9,
                                        color: const Color(0xFF35B86B),
                                        backgroundColor: const Color(
                                          0xFFE8F4EC,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '$completedTopics of $totalTopics lessons completed',
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),
                          LayoutBuilder(
                            builder: (context, gridConstraints) {
                              return GridView.count(
                                crossAxisCount: 2,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                                childAspectRatio: gridConstraints.maxWidth < 380
                                    ? 1.05
                                    : 1.55,
                                children: [
                                  DashboardActionCard(
                                    key: const ValueKey('home-courses-card'),
                                    title: 'My Courses',
                                    subtitle: 'Continue Learning',
                                    icon: Icons.play_arrow_rounded,
                                    color: const Color(0xFF3977E8),
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute<void>(
                                        builder: (_) =>
                                            const DashboardRoutePage(
                                              child: CoursesPage(),
                                            ),
                                      ),
                                    ),
                                  ),
                                  DashboardActionCard(
                                    key: const ValueKey('home-interview-card'),
                                    title: 'Interview Prep',
                                    subtitle: 'Practice Q&A',
                                    icon: Icons.mic_none_rounded,
                                    color: const Color(0xFF8A55D7),
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute<void>(
                                        builder: (_) => DashboardRoutePage(
                                          child: InterviewPage(),
                                        ),
                                      ),
                                    ),
                                  ),
                                  DashboardActionCard(
                                    key: const ValueKey(
                                      'home-assessments-card',
                                    ),
                                    title: 'Assessments',
                                    subtitle: 'Mock Tests & Quizzes',
                                    icon: Icons.assignment_outlined,
                                    color: const Color(0xFFF08A3C),
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute<void>(
                                        builder: (_) =>
                                            const DashboardRoutePage(
                                              child: PracticeTestsPage(),
                                            ),
                                      ),
                                    ),
                                  ),
                                  DashboardActionCard(
                                    key: const ValueKey('home-projects-card'),
                                    title: 'Projects',
                                    subtitle: 'End-to-End',
                                    icon: Icons.layers_outlined,
                                    color: const Color(0xFF35A878),
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute<void>(
                                        builder: (_) =>
                                            const DashboardRoutePage(
                                              child: ProjectsPage(),
                                            ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 22),
                          Card(
                            color: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              key: const ValueKey('home-interview-banner'),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (_) => DashboardRoutePage(
                                    child: InterviewPage(),
                                  ),
                                ),
                              ),
                              child: Ink(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF663CC7),
                                      Color(0xFF9A5AD8),
                                    ],
                                  ),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Interview Questions & Answers',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 6),
                                            Text(
                                              'Real interview Q&A for top roles',
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class DashboardActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const DashboardActionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: color, size: 25),
              ),
              const Spacer(),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// COURSES PAGE

const List<String> courseCategories = [
  'All',
  'Programming',
  'Database',
  'AI & Machine Learning',
  'Data',
  'Cloud & DevOps',
];

class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  String searchQuery = '';
  String selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final visibleCourses = availableCourses.where((course) {
      final matchesQuery =
          course.title.toLowerCase().contains(searchQuery) ||
          course.subtitle.toLowerCase().contains(searchQuery);
      final matchesCategory =
          selectedCategory == 'All' || course.category == selectedCategory;
      return matchesQuery && matchesCategory;
    }).toList();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'My Courses 📚',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Explore courses and improve your skills.'),
            const SizedBox(height: 16),
            TextField(
              key: const ValueKey('courses-search'),
              onChanged: (value) =>
                  setState(() => searchQuery = value.trim().toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search courses',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: courseCategories.map((category) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      key: ValueKey('course-category-$category'),
                      label: Text(category),
                      selected: selectedCategory == category,
                      onSelected: (_) =>
                          setState(() => selectedCategory = category),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            if (visibleCourses.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 36),
                child: Center(child: Text('No courses match your search.')),
              )
            else
              ...visibleCourses.map((course) => CourseCard(course: course)),
          ],
        ),
      ),
    );
  }
}

class PracticeTestsPage extends StatelessWidget {
  const PracticeTestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        key: const ValueKey('practice-tests-list'),
        padding: const EdgeInsets.all(18),
        children: [
          const Text(
            'Practice Tests',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Practice course topics and review each answer.'),
          const SizedBox(height: 18),
          ...availableCourses.map((course) {
            final questionCount = buildCoursePracticeQuestions(course).length;
            return Card(
              margin: const EdgeInsets.only(bottom: 14),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: course.color.withValues(alpha: 0.12),
                          child: Icon(course.icon, color: course.color),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                course.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text('$questionCount questions'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            key: ValueKey('start-practice-${course.title}'),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      PracticeTestPage(course: course),
                                ),
                              );
                            },
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Start Practice Test'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            key: ValueKey('start-mock-${course.title}'),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      MockTestSetupPage(course: course),
                                ),
                              );
                            },
                            icon: const Icon(Icons.timer_outlined),
                            label: const Text('Configure Mock Test'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class MockTestSetupPage extends StatefulWidget {
  final Course course;

  const MockTestSetupPage({super.key, required this.course});

  @override
  State<MockTestSetupPage> createState() => _MockTestSetupPageState();
}

class _MockTestSetupPageState extends State<MockTestSetupPage> {
  String _difficulty = 'Beginner';
  int _questionCount = 20;

  @override
  Widget build(BuildContext context) {
    final availableQuestionCount = buildMockTestQuestions(
      widget.course,
      _difficulty,
      1000,
    ).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Mock Test Setup')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            widget.course.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose a difficulty and test length. Your answers and review marks are saved with the result.',
          ),
          const SizedBox(height: 22),
          const Text(
            'Difficulty',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: courseLevels.map((level) {
              return ChoiceChip(
                key: ValueKey('mock-level-$level'),
                label: Text(level),
                selected: _difficulty == level,
                onSelected: (_) => setState(() => _difficulty = level),
              );
            }).toList(),
          ),
          const SizedBox(height: 22),
          const Text(
            'Question count',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [20, 40].map((count) {
              return ChoiceChip(
                key: ValueKey('mock-count-$count'),
                label: Text('$count questions'),
                selected: _questionCount == count,
                onSelected: (_) => setState(() => _questionCount = count),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Card(
            child: ListTile(
              leading: const Icon(Icons.timer_outlined),
              title: Text('Time limit: $_questionCount minutes'),
              subtitle: Text(
                '$availableQuestionCount questions available at $_difficulty level',
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            key: const ValueKey('start-configured-mock'),
            onPressed: availableQuestionCount < _questionCount
                ? null
                : () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => PracticeTestPage(
                        course: widget.course,
                        isTimed: true,
                        isMockTest: true,
                        difficulty: _difficulty,
                        questionCount: _questionCount,
                      ),
                    ),
                  ),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start Mock Test'),
          ),
        ],
      ),
    );
  }
}

class LearningProject {
  final String subject;
  final String title;
  final String description;
  final List<String> deliverables;

  const LearningProject({
    required this.subject,
    required this.title,
    required this.description,
    required this.deliverables,
  });
}

const List<LearningProject> learningProjects = [
  LearningProject(
    subject: 'Python Programming',
    title: 'Personal Expense Tracker',
    description: 'Build a command-line app that records expenses, summarizes spending, and exports a monthly report.',
    deliverables: [
      'Expense entry and category validation',
      'Monthly totals and category summaries',
      'CSV export for a selected month',
    ],
  ),
  LearningProject(
    subject: 'SQL / Database Management',
    title: 'Retail Sales Analytics',
    description: 'Create a small relational sales dataset and answer business questions with grouped SQL queries.',
    deliverables: [
      'Normalized customers, orders, and products tables',
      'Revenue by product and month',
      'A query for repeat customers',
    ],
  ),
  LearningProject(
    subject: 'Machine Learning',
    title: 'Customer Churn Predictor',
    description: 'Train and evaluate a classification model that identifies customers who may leave a service.',
    deliverables: [
      'A documented train/test split',
      'Baseline model and evaluation metrics',
      'Notes on features and model limitations',
    ],
  ),
  LearningProject(
    subject: 'Data Science',
    title: 'Public Data Story',
    description: 'Explore a public dataset, clean it, and communicate the most useful findings with charts.',
    deliverables: [
      'Data quality summary',
      'Three analysis visualizations',
      'A short evidence-based conclusion',
    ],
  ),
  LearningProject(
    subject: 'Generative AI',
    title: 'Grounded Learning Assistant',
    description: 'Prototype a question-answering assistant that retrieves course notes before drafting an answer.',
    deliverables: [
      'A set of source notes and chunks',
      'Retrieval and answer-generation flow',
      'Citation and answer-quality checks',
    ],
  ),
  LearningProject(
    subject: 'Agentic AI',
    title: 'Study Planner Agent',
    description: 'Design a bounded agent that turns a learner goal into a schedule using approved tools.',
    deliverables: [
      'Task planner and schedule representation',
      'A read-only calendar tool contract',
      'A human approval step for schedule changes',
    ],
  ),
  LearningProject(
    subject: 'Azure DevOps',
    title: 'Test and Deploy Pipeline',
    description: 'Create a pipeline that runs checks on changes and deploys a sample app to a test environment.',
    deliverables: [
      'Versioned pipeline definition',
      'Automated test stage',
      'Test-environment deployment and approval gate',
    ],
  ),
  LearningProject(
    subject: 'Data Engineering',
    title: 'Daily Data Quality Pipeline',
    description: 'Build a repeatable workflow that validates daily records and prepares clean data for reporting.',
    deliverables: [
      'Input schema and validation rules',
      'Duplicate and missing-value report',
      'Aggregated output table for analytics',
    ],
  ),
];

class ProjectsPage extends StatelessWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        key: const ValueKey('projects-list'),
        padding: const EdgeInsets.all(18),
        children: [
          const Text(
            'Projects',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Build practical projects across all 8 subjects.'),
          const SizedBox(height: 18),
          ...learningProjects.map(
            (project) => Card(
              key: ValueKey('project-${project.subject}'),
              color: Colors.white,
              elevation: 2,
              shadowColor: Colors.black12,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE9F5EF),
                  child: Icon(Icons.layers_outlined, color: Color(0xFF35A878)),
                ),
                title: Text(
                  project.title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(project.subject),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => ProjectDetailPage(project: project),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProjectDetailPage extends StatelessWidget {
  final LearningProject project;

  const ProjectDetailPage({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(project.subject)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            project.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(project.description),
          const SizedBox(height: 22),
          const Text(
            'Project deliverables',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ...project.deliverables.map(
            (deliverable) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.check_circle_outline,
                color: Color(0xFF35A878),
              ),
              title: Text(deliverable),
            ),
          ),
        ],
      ),
    );
  }
}

class PracticeTestPage extends StatefulWidget {
  final Course course;
  final bool isTimed;
  final bool isMockTest;
  final String difficulty;
  final int? questionCount;

  const PracticeTestPage({
    super.key,
    required this.course,
    this.isTimed = false,
    this.isMockTest = false,
    this.difficulty = 'All levels',
    this.questionCount,
  });

  @override
  State<PracticeTestPage> createState() => _PracticeTestPageState();
}

class _PracticeTestPageState extends State<PracticeTestPage> {
  late final List<CourseAssessmentQuestion> questions;
  late List<int> selectedAnswers;
  bool submitted = false;
  bool timeExpired = false;
  late int remainingSeconds;
  int currentQuestionIndex = 0;
  final Set<int> reviewedQuestionIndices = <int>{};
  final ScrollController _mockTestScrollController = ScrollController();
  final DateTime startedAt = DateTime.now();
  Timer? _timer;

  int get initialSeconds =>
      widget.isMockTest ? (widget.questionCount ?? 20) * 60 : 120;

  int get score => List<int>.generate(questions.length, (index) => index)
      .where(
        (index) =>
            selectedAnswers[index] == questions[index].question.correctIndex,
      )
      .length;

  @override
  void initState() {
    super.initState();
    questions = widget.isMockTest
        ? buildMockTestQuestions(
            widget.course,
            widget.difficulty,
            widget.questionCount ?? 20,
          )
        : buildCoursePracticeQuestions(widget.course);
    selectedAnswers = List<int>.filled(questions.length, -1);
    remainingSeconds = initialSeconds;
    _startTimer();
  }

  void _startTimer() {
    if (!widget.isTimed) {
      return;
    }
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (remainingSeconds <= 1) {
        remainingSeconds = 0;
        timeExpired = true;
        unawaited(_submitTest());
      } else {
        setState(() {
          remainingSeconds--;
        });
      }
    });
  }

  Future<void> _submitTest() async {
    if (submitted) {
      return;
    }
    _timer?.cancel();
    setState(() {
      submitted = true;
    });
    final attempt = TestAttempt(
      course: widget.course,
      isTimed: widget.isTimed,
      endedByTimeout: timeExpired,
      isMockTest: widget.isMockTest,
      difficulty: widget.difficulty,
      reviewedQuestionIndices: Set<int>.unmodifiable(reviewedQuestionIndices),
      questionCount: widget.questionCount ?? questions.length,
      score: score,
      completedAt: DateTime.now(),
      elapsed: widget.isTimed
          ? Duration(seconds: initialSeconds - remainingSeconds)
          : DateTime.now().difference(startedAt),
      answers: [
        for (var index = 0; index < questions.length; index++)
          QuestionAttemptResult(
            assessmentQuestion: questions[index],
            selectedIndex: selectedAnswers[index],
          ),
      ],
    );
    testAttempts.insert(0, attempt);
    learningDataRevision.value++;
    try {
      await CertificateStore.instance.awardAssessmentIfPassed(
        courseName: widget.course.title,
        assessmentName: widget.isMockTest
            ? '${widget.difficulty} Mock Test'
            : 'Course Practice Test',
        learnerName: LearnHubSettingsStore.instance.settings.value.learnerName,
        score: attempt.score,
        totalQuestions: attempt.totalQuestions,
      );
    } on Exception catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save assessment certificate: $error')),
        );
      }
    }
    if (!mounted) {
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => TestResultsPage(attempt: attempt)),
    );
  }

  void _showQuestion(int index) {
    setState(() => currentQuestionIndex = index);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_mockTestScrollController.hasClients) {
        _mockTestScrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String get _timeLabel {
    final minutes = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Widget _buildMockQuestion() {
    final assessmentQuestion = questions[currentQuestionIndex];
    final question = assessmentQuestion.question;
    final selectedIndex = selectedAnswers[currentQuestionIndex];
    final isMarked = reviewedQuestionIndices.contains(currentQuestionIndex);

    return Card(
      key: ValueKey('mock-question-card-$currentQuestionIndex'),
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${assessmentQuestion.difficulty} • ${assessmentQuestion.topicTitle}',
                    style: const TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton.icon(
                  key: ValueKey('mark-review-$currentQuestionIndex'),
                  onPressed: () => setState(() {
                    if (isMarked) {
                      reviewedQuestionIndices.remove(currentQuestionIndex);
                    } else {
                      reviewedQuestionIndices.add(currentQuestionIndex);
                    }
                  }),
                  icon: Icon(isMarked ? Icons.flag : Icons.outlined_flag),
                  label: Text(
                    isMarked ? 'Marked for Review' : 'Mark for Review',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Question ${currentQuestionIndex + 1} of ${questions.length}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              question.question,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    key: const ValueKey('mock-previous-question'),
                    onPressed: currentQuestionIndex == 0
                        ? null
                        : () => _showQuestion(currentQuestionIndex - 1),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Previous'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    key: const ValueKey('mock-next-question'),
                    onPressed: currentQuestionIndex == questions.length - 1
                        ? null
                        : () => _showQuestion(currentQuestionIndex + 1),
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Next'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...question.options.asMap().entries.map((entry) {
              final isSelected = selectedIndex == entry.key;
              return InkWell(
                key: ValueKey(
                  'practice-option-$currentQuestionIndex-${entry.key}',
                ),
                onTap: () => setState(
                  () => selectedAnswers[currentQuestionIndex] = entry.key,
                ),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 7),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? primaryColor : Colors.grey.shade300,
                    ),
                    color: isSelected
                        ? primaryColor.withValues(alpha: 0.06)
                        : null,
                  ),
                  child: Text(entry.value),
                ),
              );
            }),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List<Widget>.generate(questions.length, (index) {
                final answered = selectedAnswers[index] >= 0;
                final marked = reviewedQuestionIndices.contains(index);
                return OutlinedButton(
                  key: ValueKey('mock-jump-question-$index'),
                  onPressed: () => _showQuestion(index),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: marked
                        ? Colors.orange.shade100
                        : answered
                        ? Colors.green.shade100
                        : null,
                    minimumSize: const Size(42, 38),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  child: Text('${index + 1}'),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _mockTestScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final answeredCount = selectedAnswers.where((answer) => answer >= 0).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isTimed ? 'Timed Mock Test' : 'Practice Test'),
      ),
      body: ListView(
        key: const ValueKey('practice-test-list'),
        controller: widget.isMockTest ? _mockTestScrollController : null,
        padding: const EdgeInsets.all(18),
        children: [
          if (widget.isTimed && !submitted)
            Card(
              color: remainingSeconds <= 30
                  ? Colors.red.shade50
                  : Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    const Icon(Icons.timer_outlined),
                    const SizedBox(width: 10),
                    Text(
                      'Time remaining: $_timeLabel',
                      key: const ValueKey('mock-timer-label'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          Text(
            widget.isMockTest
                ? '${widget.difficulty} • ${widget.questionCount} questions'
                : widget.isTimed
                ? 'Complete as many questions as you can before time runs out.'
                : 'Answer all ${questions.length} questions to see your result.',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: questions.isEmpty ? 0 : answeredCount / questions.length,
          ),
          const SizedBox(height: 6),
          Text('$answeredCount of ${questions.length} answered'),
          const SizedBox(height: 18),
          if (widget.isMockTest)
            _buildMockQuestion()
          else
            ...questions.asMap().entries.map((entry) {
              final questionIndex = entry.key;
              final assessmentQuestion = entry.value;
              final question = assessmentQuestion.question;

              return Card(
                margin: const EdgeInsets.only(bottom: 14),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        assessmentQuestion.topicTitle,
                        style: const TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${questionIndex + 1}. ${question.question}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...question.options.asMap().entries.map((optionEntry) {
                        final optionIndex = optionEntry.key;
                        final isSelected =
                            selectedAnswers[questionIndex] == optionIndex;
                        final isCorrect = question.correctIndex == optionIndex;
                        final color = submitted && isCorrect
                            ? Colors.green
                            : isSelected
                            ? primaryColor
                            : Colors.grey.shade300;

                        return InkWell(
                          key: ValueKey(
                            'practice-option-$questionIndex-$optionIndex',
                          ),
                          onTap: submitted
                              ? null
                              : () {
                                  setState(() {
                                    selectedAnswers[questionIndex] =
                                        optionIndex;
                                  });
                                },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(top: 7),
                            padding: const EdgeInsets.all(11),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: color),
                              color: isSelected
                                  ? primaryColor.withValues(alpha: 0.06)
                                  : null,
                            ),
                            child: Text(optionEntry.value),
                          ),
                        );
                      }),
                      if (submitted) ...[
                        const SizedBox(height: 8),
                        Text(
                          selectedAnswers[questionIndex] ==
                                  question.correctIndex
                              ? 'Correct! ${question.explanation}'
                              : 'Correct answer: ${question.options[question.correctIndex]}. ${question.explanation}',
                          style: TextStyle(
                            color:
                                selectedAnswers[questionIndex] ==
                                    question.correctIndex
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ElevatedButton(
            key: ValueKey(
              widget.isTimed ? 'submit-mock-test' : 'submit-practice-test',
            ),
            onPressed:
                (widget.isTimed || answeredCount == questions.length) &&
                    !submitted
                ? _submitTest
                : null,
            child: Text(
              widget.isMockTest
                  ? 'Submit Test'
                  : widget.isTimed
                  ? 'Submit Mock Test'
                  : 'Submit Practice Test',
            ),
          ),
        ],
      ),
    );
  }
}

class TestResultsPage extends StatelessWidget {
  final TestAttempt attempt;

  const TestResultsPage({super.key, required this.attempt});

  String get durationLabel {
    final minutes = attempt.elapsed.inMinutes.toString().padLeft(2, '0');
    final seconds = attempt.elapsed.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final topicTitles = attempt.answers
        .map((answer) => answer.assessmentQuestion.topicTitle)
        .toSet();

    return Scaffold(
      appBar: AppBar(title: const Text('Test Results')),
      body: ListView(
        key: const ValueKey('test-results-list'),
        padding: const EdgeInsets.all(18),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    attempt.accuracyPercent >= 70
                        ? Icons.emoji_events_outlined
                        : Icons.assignment_turned_in_outlined,
                    color: primaryColor,
                    size: 44,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    attempt.course.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    attempt.isMockTest
                        ? '${attempt.difficulty} Mock Test • ${attempt.totalQuestions} questions'
                        : attempt.isTimed
                        ? 'Timed Mock Test'
                        : 'Practice Test',
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Score: ${attempt.score} / ${attempt.totalQuestions}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Accuracy: ${attempt.accuracyPercent}%'),
                  const SizedBox(height: 14),
                  LinearProgressIndicator(
                    value: attempt.totalQuestions == 0
                        ? 0
                        : attempt.score / attempt.totalQuestions,
                    minHeight: 9,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 18,
                    runSpacing: 8,
                    children: [
                      Text('Correct: ${attempt.score}'),
                      Text(
                        'Incorrect: ${attempt.totalQuestions - attempt.score}',
                      ),
                      Text('Time: $durationLabel'),
                      if (attempt.reviewedQuestionIndices.isNotEmpty)
                        Text(
                          'Marked for review: ${attempt.reviewedQuestionIndices.length}',
                        ),
                    ],
                  ),
                  if (attempt.endedByTimeout) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Time limit reached. Answers were auto-submitted.',
                    ),
                  ],
                ],
              ),
            ),
          ),
          const Text(
            'Answer Review',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...attempt.answers.asMap().entries.map((entry) {
            final questionIndex = entry.key;
            final result = entry.value;
            final question = result.assessmentQuestion.question;
            final isCorrect = result.selectedIndex == question.correctIndex;
            final selectedAnswer = result.selectedIndex < 0
                ? 'Not answered'
                : question.options[result.selectedIndex];

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${questionIndex + 1}. ${question.question}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (attempt.reviewedQuestionIndices.contains(questionIndex))
                      const Padding(
                        padding: EdgeInsets.only(top: 5),
                        child: Text(
                          'Marked for Review',
                          style: TextStyle(color: Colors.orange),
                        ),
                      ),
                    const SizedBox(height: 5),
                    Text(result.assessmentQuestion.topicTitle),
                    const SizedBox(height: 8),
                    Text(
                      'Your answer: $selectedAnswer',
                      style: TextStyle(
                        color: isCorrect ? Colors.green : Colors.red,
                      ),
                    ),
                    Text(
                      'Correct answer: ${question.options[question.correctIndex]}',
                    ),
                    const SizedBox(height: 5),
                    Text(question.explanation),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 18),
          const Text(
            'Topic Analysis',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...topicTitles.map((topicTitle) {
            final topicAnswers = attempt.answers
                .where(
                  (answer) =>
                      answer.assessmentQuestion.topicTitle == topicTitle,
                )
                .toList();
            final correctCount = topicAnswers
                .where(
                  (answer) =>
                      answer.selectedIndex ==
                      answer.assessmentQuestion.question.correctIndex,
                )
                .length;
            return Card(
              child: ListTile(
                title: Text(topicTitle),
                subtitle: Text(
                  '$correctCount/${topicAnswers.length} correct • ${topicAnswers.isEmpty ? 0 : (correctCount * 100 / topicAnswers.length).round()}% accuracy',
                ),
                trailing: Icon(
                  correctCount == topicAnswers.length
                      ? Icons.check_circle_outline
                      : Icons.lightbulb_outline,
                  color: correctCount == topicAnswers.length
                      ? Colors.green
                      : Colors.orange,
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            key: const ValueKey('retake-test-button'),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => PracticeTestPage(
                    course: attempt.course,
                    isTimed: attempt.isTimed,
                    isMockTest: attempt.isMockTest,
                    difficulty: attempt.difficulty,
                    questionCount: attempt.questionCount,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.replay),
            label: const Text('Retake Test'),
          ),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back to Practice Tests'),
          ),
        ],
      ),
    );
  }
}

// REUSABLE COURSE CARD

class CourseCard extends StatelessWidget {
  final Course course;

  const CourseCard({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: completedLessonRevision,
      builder: (context, revision, child) {
        final progressValue = course.progressValue;

        return Card(
          key: ValueKey('course-card-${course.title}'),
          margin: const EdgeInsets.only(bottom: 13),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: CircleAvatar(
              radius: 25,
              backgroundColor: course.color.withValues(alpha: 0.12),
              child: Icon(course.icon, color: course.color),
            ),
            title: Text(
              course.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${course.level} • ${course.duration}'),
                  const SizedBox(height: 4),
                  Text(course.progressText),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progressValue,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ],
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 17),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CourseDetailPage(course: course),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// COURSE DETAILS PAGE

class CourseDetailPage extends StatelessWidget {
  final Course course;

  const CourseDetailPage({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: completedLessonRevision,
      builder: (context, revision, child) {
        final progressValue = course.progressValue;

        return Scaffold(
          appBar: AppBar(title: Text(course.title)),
          body: ListView(
            key: const ValueKey('course-curriculum-list'),
            padding: const EdgeInsets.all(18),
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: course.color.withValues(alpha: 0.12),
                child: Icon(course.icon, size: 40, color: course.color),
              ),
              const SizedBox(height: 18),
              Text(
                course.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Course Introduction',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(course.introduction, textAlign: TextAlign.center),
              const SizedBox(height: 18),
              Text(
                '${course.duration}  •  ${course.topics.length} chapters',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text(
                'Learning Objectives',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...course.learningObjectives.map(
                (objective) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        color: primaryColor,
                        size: 19,
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(objective)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Course Levels',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: courseLevels
                    .map(
                      (level) => Chip(
                        label: Text(level),
                        backgroundColor: const Color(0xFFE2EAFE),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                key: ValueKey('open-study-materials-${course.title}'),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => StudyMaterialsPage(course: course),
                  ),
                ),
                icon: const Icon(Icons.menu_book_outlined),
                label: const Text('Study Materials'),
              ),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Lesson Progress',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${(progressValue * 100).round()}%',
                    style: const TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progressValue,
                minHeight: 8,
                borderRadius: BorderRadius.circular(10),
              ),
              const SizedBox(height: 8),
              Text(
                course.progressText,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 25),
              const Text(
                'Chapter-wise Syllabus',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...course.topics.asMap().entries.map((entry) {
                final topic = entry.value;
                final isCompleted = completedLessonIds.contains(
                  buildLessonKey(course.title, topic.title),
                );

                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFE2EAFE),
                      child: Text('${entry.key + 1}'),
                    ),
                    title: Text(topic.title),
                    subtitle: Text(
                      '${topic.level} • ${isCompleted ? 'Completed' : 'In progress'}',
                    ),
                    trailing: const Icon(Icons.play_circle_outline),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              LessonPage(course: course, topic: topic),
                        ),
                      );
                    },
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class StudyMaterialsPage extends StatelessWidget {
  final Course course;

  const StudyMaterialsPage({super.key, required this.course});

  Future<void> _downloadPdf(BuildContext context) async {
    final chapters = course.topics
        .map(
          (topic) => StudyMaterialChapter(
            title: topic.title,
            level: topic.level,
            introduction: topic.introduction,
            explanation: topic.explanation,
            concepts: topic.importantConcepts,
            example: topic.code,
            expectedOutput: topic.expectedOutput,
            applications: topic.realWorldApplications,
            exercises: topic.practiceExercises,
            assignment: topic.assignmentText,
          ),
        )
        .toList();
    final bytes = await createStudyMaterialPdf(
      courseTitle: course.title,
      introduction: course.introduction,
      objectives: course.learningObjectives,
      chapters: chapters,
    );
    final filename =
        '${course.title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_')}_study_materials.pdf';

    try {
      await downloadPdfBytes(bytes, filename);
    } on UnsupportedError catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message ?? 'PDF download is unavailable.'),
          ),
        );
      }
      return;
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Study materials PDF downloaded.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Study Materials')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text(
            course.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(course.introduction),
          const SizedBox(height: 14),
          FilledButton.icon(
            key: ValueKey('download-study-pdf-${course.title}'),
            onPressed: () => _downloadPdf(context),
            icon: const Icon(Icons.picture_as_pdf_outlined),
            label: const Text('Download Study Materials PDF'),
          ),
          const SizedBox(height: 18),
          const Text(
            'Chapter-wise Materials',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ...course.topics.map(
            (topic) => Card(
              key: ValueKey('study-material-${topic.title}'),
              child: ListTile(
                leading: const Icon(Icons.description_outlined),
                title: Text(topic.title),
                subtitle: Text(
                  '${topic.level} • Notes, example, and exercises',
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        StudyMaterialChapterPage(course: course, topic: topic),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StudyMaterialChapterPage extends StatelessWidget {
  final Course course;
  final CourseTopic topic;

  const StudyMaterialChapterPage({
    super.key,
    required this.course,
    required this.topic,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Study Material')),
      body: ListView(
        key: const ValueKey('study-material-chapter-list'),
        padding: const EdgeInsets.all(18),
        children: [
          Text(
            course.title,
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Chip(
            label: Text('${topic.level} level'),
            avatar: const Icon(Icons.stairs_outlined, size: 18),
          ),
          Text(
            topic.title,
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 18),
          const Text(
            'Notes',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(topic.introduction),
          const SizedBox(height: 10),
          Text(topic.explanation, style: const TextStyle(height: 1.6)),
          const SizedBox(height: 18),
          const Text(
            'Important Concepts',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
          Wrap(
            spacing: 8,
            children: topic.importantConcepts
                .map((concept) => Chip(label: Text(concept)))
                .toList(),
          ),
          const SizedBox(height: 18),
          const Text(
            'Practical Example',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SelectableText(topic.code),
          const SizedBox(height: 8),
          Text('Expected output: ${topic.expectedOutput}'),
          const SizedBox(height: 18),
          const Text(
            'Hands-on Exercises',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
          ...topic.practiceExercises.map(
            (exercise) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.check_circle_outline),
              title: Text(exercise),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Assignment',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(topic.assignmentText),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            key: const ValueKey('continue-study-lesson'),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => LessonPage(course: course, topic: topic),
              ),
            ),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Continue Lesson and Quiz'),
          ),
        ],
      ),
    );
  }
}

// LESSON PAGE

class LessonPage extends StatefulWidget {
  final Course course;
  final CourseTopic topic;

  const LessonPage({super.key, required this.course, required this.topic});

  @override
  State<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> {
  bool isCompleted = false;
  List<int> selectedAnswers = [];
  bool submitted = false;

  String get lessonId =>
      buildLessonKey(widget.course.title, widget.topic.title);

  @override
  void initState() {
    super.initState();
    isCompleted = completedLessonIds.contains(lessonId);
    selectedAnswers = List<int>.filled(widget.topic.quizQuestions.length, -1);
  }

  Future<void> completeLesson() async {
    if (isCompleted) {
      return;
    }
    try {
      await markLessonCompleted(lessonId);
      if (!mounted) {
        return;
      }
      setState(() => isCompleted = true);
      final certificate = await CertificateStore.instance.awardCourseIfComplete(
        courseName: widget.course.title,
        learnerName: LearnHubSettingsStore.instance.settings.value.learnerName,
        requiredLessonIds: widget.course.topics.map(
          (topic) => buildLessonKey(widget.course.title, topic.title),
        ),
        completedLessonIds: completedLessonIds,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              certificate == null
                  ? 'Lesson completed successfully!'
                  : 'Course complete! Your certificate has been earned.',
            ),
          ),
        );
      }
    } on Exception catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save lesson completion: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = selectedAnswers.contains(-1) == false && !submitted;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.topic.title),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.course.title,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Chip(
              key: const ValueKey('lesson-level'),
              label: Text('${widget.topic.level} level'),
              avatar: const Icon(Icons.stairs_outlined, size: 18),
            ),
            const SizedBox(height: 12),
            Text(
              widget.topic.title,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              widget.topic.introduction,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),

            const Text(
              'Topic Introduction',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(widget.topic.introduction),
            const SizedBox(height: 24),

            const Text(
              'Detailed Explanation',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              widget.topic.explanation,
              style: const TextStyle(fontSize: 15, height: 1.7),
            ),
            const SizedBox(height: 24),

            const Text(
              'Important Concepts',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.topic.importantConcepts
                  .map(
                    (concept) => Chip(
                      label: Text(concept),
                      backgroundColor: const Color(0xFFE2EAFE),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 24),

            const Text(
              'Practical Code Example',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SelectableText(
                widget.topic.code,
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 15,
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Expected Output',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEDF3FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: SelectableText(
                widget.topic.expectedOutput,
                style: const TextStyle(fontSize: 15),
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Real-World Applications',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              widget.topic.realWorldApplications,
              style: const TextStyle(fontSize: 15, height: 1.6),
            ),
            const SizedBox(height: 24),

            const Text(
              'Practice Exercises',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...widget.topic.practiceExercises.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${entry.key + 1}. ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Expanded(child: Text(entry.value)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Assignment',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(widget.topic.assignmentText),
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Practice Quiz',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...widget.topic.quizQuestions.asMap().entries.map((entry) {
              final questionIndex = entry.key;
              final quizQuestion = entry.value;
              final isQuestionSubmitted = submitted;

              return Container(
                margin: const EdgeInsets.only(bottom: 18),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${questionIndex + 1}. ${quizQuestion.question}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...quizQuestion.options.asMap().entries.map((optionEntry) {
                      final optionIndex = optionEntry.key;
                      final optionText = optionEntry.value;
                      final isSelected =
                          selectedAnswers[questionIndex] == optionIndex;
                      final isCorrect =
                          quizQuestion.correctIndex == optionIndex;
                      final showAnswerState = isQuestionSubmitted && isCorrect;

                      return GestureDetector(
                        onTap: submitted
                            ? null
                            : () {
                                setState(() {
                                  selectedAnswers[questionIndex] = optionIndex;
                                });
                              },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.indigo.withValues(alpha: 0.08)
                                : Colors.transparent,
                            border: Border.all(
                              color: showAnswerState
                                  ? Colors.green
                                  : (isSelected
                                        ? Colors.indigo
                                        : Colors.grey.shade300),
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_unchecked,
                                color: showAnswerState
                                    ? Colors.green
                                    : (isSelected
                                          ? Colors.indigo
                                          : Colors.grey),
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: Text(optionText)),
                            ],
                          ),
                        ),
                      );
                    }),
                    if (submitted)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          selectedAnswers[questionIndex] ==
                                  quizQuestion.correctIndex
                              ? 'Correct! ${quizQuestion.explanation}'
                              : 'Incorrect. Correct answer: ${quizQuestion.options[quizQuestion.correctIndex]}. ${quizQuestion.explanation}',
                          style: TextStyle(
                            color:
                                selectedAnswers[questionIndex] ==
                                    quizQuestion.correctIndex
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: canSubmit
                    ? () => setState(() => submitted = true)
                    : null,
                child: const Text('Submit Quiz'),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isCompleted ? null : completeLesson,
                icon: const Icon(Icons.check_circle),
                label: Text(
                  isCompleted ? 'Lesson Completed' : 'Mark as Completed',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// INTERVIEW PAGE

class InterviewPage extends StatefulWidget {
  const InterviewPage({super.key});

  @override
  State<InterviewPage> createState() => _InterviewPageState();
}

class _InterviewPageState extends State<InterviewPage> {
  final TextEditingController _searchController = TextEditingController();
  InterviewDifficulty? _selectedDifficulty;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<InterviewQuestion> _searchResults() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return const <InterviewQuestion>[];
    }
    return allInterviewQuestions.where((question) {
      final matchesDifficulty =
          _selectedDifficulty == null ||
          question.difficulty == _selectedDifficulty;
      final searchableText = [
        question.subject,
        question.question,
        question.answer,
        question.example,
        question.code,
        question.useCase,
        question.keyPoints,
      ].join(' ').toLowerCase();
      return matchesDifficulty && searchableText.contains(query);
    }).toList();
  }

  void _openQuestion(InterviewQuestion question, List<InterviewQuestion> list) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => InterviewQuestionDetailPage(
          questions: list,
          initialIndex: list.indexOf(question),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = InterviewProgressStore.instance;
    return SafeArea(
      child: ValueListenableBuilder<int>(
        valueListenable: learningDataRevision,
        builder: (context, revision, child) {
          final results = _searchResults();
          final recentlyViewed = progress.recentQuestionIds
              .map((id) => interviewQuestionsById[id])
              .whereType<InterviewQuestion>()
              .take(5)
              .toList();
          final completedCount = progress.completedQuestionIds.length;

          return LayoutBuilder(
            builder: (context, constraints) {
              final contentWidth = constraints.maxWidth > 1000
                  ? 1000.0
                  : constraints.maxWidth;
              final crossAxisCount = contentWidth >= 700 ? 3 : 1;
              final cardWidth =
                  (contentWidth - (crossAxisCount - 1) * 12) / crossAxisCount;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Center(
                  child: SizedBox(
                    width: contentWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Interview Preparation 🎯',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Practice ${allInterviewQuestions.length} questions across eight technical subjects.',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                        const SizedBox(height: 18),
                        TextField(
                          controller: _searchController,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: 'Search questions, concepts, or code',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _searchController.text.isEmpty
                                ? null
                                : IconButton(
                                    tooltip: 'Clear search',
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {});
                                    },
                                    icon: const Icon(Icons.close),
                                  ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _DifficultyFilters(
                          selectedDifficulty: _selectedDifficulty,
                          onChanged: (value) =>
                              setState(() => _selectedDifficulty = value),
                        ),
                        const SizedBox(height: 14),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.track_changes,
                                      color: primaryColor,
                                    ),
                                    const SizedBox(width: 8),
                                    const Expanded(
                                      child: Text(
                                        'Preparation progress',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '$completedCount/${allInterviewQuestions.length}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                LinearProgressIndicator(
                                  value: allInterviewQuestions.isEmpty
                                      ? 0
                                      : completedCount /
                                            allInterviewQuestions.length,
                                  minHeight: 8,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${progress.bookmarkedQuestionIds.length} saved • ${progress.recentQuestionIds.length} recently viewed',
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 13,
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton.icon(
                                    onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute<void>(
                                        builder: (_) => const MyLearningPage(),
                                      ),
                                    ),
                                    icon: const Icon(Icons.bookmarks_outlined),
                                    label: const Text('Saved questions'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        if (_searchController.text.trim().isNotEmpty) ...[
                          Text(
                            'Search results (${results.length})',
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (results.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Text(
                                'No questions match your search and difficulty filter.',
                              ),
                            )
                          else
                            ...results.map(
                              (question) => InterviewQuestionCard(
                                question: question,
                                onOpen: () => _openQuestion(question, results),
                              ),
                            ),
                        ] else ...[
                          const Text(
                            'Subjects',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              for (final subject in interviewSubjectOrder)
                                SizedBox(
                                  width: cardWidth,
                                  child: _InterviewSubjectCard(
                                    subject: subject,
                                    questions:
                                        interviewQuestionsBySubject[subject]!,
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute<void>(
                                        builder: (_) => QuestionListPage(
                                          title: subject,
                                          questions:
                                              interviewQuestionsBySubject[subject]!,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          if (recentlyViewed.isNotEmpty) ...[
                            const SizedBox(height: 22),
                            const Text(
                              'Recently viewed',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...recentlyViewed.map(
                              (question) => InterviewQuestionCard(
                                question: question,
                                onOpen: () =>
                                    _openQuestion(question, recentlyViewed),
                              ),
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _DifficultyFilters extends StatelessWidget {
  final InterviewDifficulty? selectedDifficulty;
  final ValueChanged<InterviewDifficulty?> onChanged;

  const _DifficultyFilters({
    required this.selectedDifficulty,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          FilterChip(
            label: const Text('All levels'),
            selected: selectedDifficulty == null,
            onSelected: (_) => onChanged(null),
          ),
          const SizedBox(width: 8),
          for (final difficulty in InterviewDifficulty.values) ...[
            FilterChip(
              label: Text(_difficultyLabel(difficulty)),
              selected: selectedDifficulty == difficulty,
              onSelected: (selected) => onChanged(selected ? difficulty : null),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

String _difficultyLabel(InterviewDifficulty difficulty) {
  return switch (difficulty) {
    InterviewDifficulty.basic => 'Basic',
    InterviewDifficulty.intermediate => 'Intermediate',
    InterviewDifficulty.advanced => 'Advanced',
  };
}

class _InterviewSubjectCard extends StatelessWidget {
  final String subject;
  final List<InterviewQuestion> questions;
  final VoidCallback onTap;

  const _InterviewSubjectCard({
    required this.subject,
    required this.questions,
    required this.onTap,
  });

  IconData get _icon {
    if (subject.startsWith('Python')) return Icons.code;
    if (subject.startsWith('SQL')) return Icons.storage;
    if (subject == 'Machine Learning') return Icons.psychology;
    if (subject == 'Data Science') return Icons.analytics;
    if (subject == 'Generative AI') return Icons.auto_awesome;
    if (subject == 'Agentic AI') return Icons.smart_toy_outlined;
    if (subject == 'Azure DevOps') return Icons.cloud_outlined;
    return Icons.dataset_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final completed = questions
        .where(
          (question) => InterviewProgressStore.instance.completedQuestionIds
              .contains(question.id),
        )
        .length;
    return Card(
      key: ValueKey('interview-subject-$subject'),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFFE2EAFE),
                    foregroundColor: primaryColor,
                    child: Icon(_icon),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_ios, size: 15),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                subject,
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 5),
              Text('${questions.length} questions'),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: questions.isEmpty ? 0 : completed / questions.length,
                minHeight: 5,
              ),
              const SizedBox(height: 4),
              Text(
                '$completed/${questions.length} completed',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuestionListPage extends StatefulWidget {
  final String title;
  final List<InterviewQuestion> questions;

  const QuestionListPage({
    super.key,
    required this.title,
    required this.questions,
  });

  @override
  State<QuestionListPage> createState() => _QuestionListPageState();
}

class _QuestionListPageState extends State<QuestionListPage> {
  final TextEditingController _searchController = TextEditingController();
  InterviewDifficulty? _selectedDifficulty;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final questions = widget.questions.where((question) {
      final matchesDifficulty =
          _selectedDifficulty == null ||
          question.difficulty == _selectedDifficulty;
      final searchableText = [
        question.question,
        question.answer,
        question.example,
        question.code,
        question.useCase,
        question.keyPoints,
      ].join(' ').toLowerCase();
      return matchesDifficulty &&
          (query.isEmpty || searchableText.contains(query));
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            tooltip: 'Saved questions',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => const MyLearningPage()),
            ),
            icon: const Icon(Icons.bookmarks_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'Search this subject',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: _DifficultyFilters(
                selectedDifficulty: _selectedDifficulty,
                onChanged: (value) =>
                    setState(() => _selectedDifficulty = value),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 2, 18, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${questions.length} questions',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ),
            ),
            Expanded(
              child: ValueListenableBuilder<int>(
                valueListenable: learningDataRevision,
                builder: (context, revision, child) {
                  if (questions.isEmpty) {
                    return const Center(
                      child: Text('No questions match these filters.'),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(14),
                    itemCount: questions.length,
                    itemBuilder: (context, index) => InterviewQuestionCard(
                      question: questions[index],
                      onOpen: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => InterviewQuestionDetailPage(
                            questions: questions,
                            initialIndex: index,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InterviewQuestionCard extends StatelessWidget {
  final InterviewQuestion question;
  final VoidCallback onOpen;

  const InterviewQuestionCard({
    super.key,
    required this.question,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final progress = InterviewProgressStore.instance;
    final isBookmarked = progress.bookmarkedQuestionIds.contains(question.id);
    final isCompleted = progress.completedQuestionIds.contains(question.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            key: ValueKey('open-interview-question-${question.id}'),
            onTap: onOpen,
            title: Text(
              question.question,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Wrap(
                spacing: 7,
                runSpacing: 5,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _DifficultyBadge(difficulty: question.difficulty),
                  Text(question.subject, style: const TextStyle(fontSize: 12)),
                  if (isCompleted)
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 17,
                    ),
                ],
              ),
            ),
            trailing: IconButton(
              tooltip: isBookmarked ? 'Remove bookmark' : 'Bookmark question',
              onPressed: () => _runInterviewProgressAction(
                context,
                () => progress.toggleBookmark(question.id),
              ),
              icon: Icon(
                isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                color: isBookmarked ? primaryColor : null,
              ),
            ),
          ),
          ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16),
            title: const Text('Expand detailed answer'),
            children: [
              _QuestionAnswerContent(question: question),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onOpen,
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Open question'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DifficultyBadge extends StatelessWidget {
  final InterviewDifficulty difficulty;

  const _DifficultyBadge({required this.difficulty});

  @override
  Widget build(BuildContext context) {
    final color = switch (difficulty) {
      InterviewDifficulty.basic => const Color(0xFF16834A),
      InterviewDifficulty.intermediate => const Color(0xFFB36B00),
      InterviewDifficulty.advanced => const Color(0xFFB3261E),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _difficultyLabel(difficulty),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class InterviewQuestionDetailPage extends StatefulWidget {
  final List<InterviewQuestion> questions;
  final int initialIndex;

  const InterviewQuestionDetailPage({
    super.key,
    required this.questions,
    required this.initialIndex,
  });

  @override
  State<InterviewQuestionDetailPage> createState() =>
      _InterviewQuestionDetailPageState();
}

class _InterviewQuestionDetailPageState
    extends State<InterviewQuestionDetailPage> {
  late int _currentIndex;
  final ScrollController _scrollController = ScrollController();

  InterviewQuestion get _question => widget.questions[_currentIndex];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_recordViewed());
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _recordViewed() async {
    await _runInterviewProgressAction(
      context,
      () => InterviewProgressStore.instance.recordViewed(_question.id),
    );
  }

  void _showQuestion(int nextIndex) {
    setState(() => _currentIndex = nextIndex);
    _scrollController.jumpTo(0);
    unawaited(_recordViewed());
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: learningDataRevision,
      builder: (context, revision, child) {
        final question = _question;
        final progress = InterviewProgressStore.instance;
        final isBookmarked = progress.bookmarkedQuestionIds.contains(
          question.id,
        );
        final isCompleted = progress.completedQuestionIds.contains(question.id);

        return Scaffold(
          appBar: AppBar(
            title: Text(question.subject),
            actions: [
              IconButton(
                tooltip: isBookmarked ? 'Remove bookmark' : 'Bookmark question',
                onPressed: () => _runInterviewProgressAction(
                  context,
                  () => progress.toggleBookmark(question.id),
                ),
                icon: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                  color: isBookmarked ? primaryColor : null,
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(18),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: constraints.maxWidth > 850
                          ? 850
                          : constraints.maxWidth,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _DifficultyBadge(difficulty: question.difficulty),
                        const SizedBox(height: 12),
                        Text(
                          question.question,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Card(
                          child: CheckboxListTile(
                            value: isCompleted,
                            title: Text(
                              isCompleted
                                  ? 'Completed'
                                  : 'Mark this question as completed',
                            ),
                            secondary: const Icon(Icons.task_alt),
                            onChanged: (_) => _runInterviewProgressAction(
                              context,
                              () => progress.toggleCompleted(question.id),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Card(
                          child: ExpansionTile(
                            key: ValueKey('answer-${question.id}'),
                            initiallyExpanded: true,
                            title: const Text(
                              'Detailed answer',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            children: [
                              _QuestionAnswerContent(question: question),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            OutlinedButton.icon(
                              onPressed: _currentIndex == 0
                                  ? null
                                  : () => _showQuestion(_currentIndex - 1),
                              icon: const Icon(Icons.arrow_back),
                              label: const Text('Previous'),
                            ),
                            const Spacer(),
                            Text(
                              '${_currentIndex + 1} of ${widget.questions.length}',
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                            const Spacer(),
                            FilledButton.icon(
                              onPressed:
                                  _currentIndex == widget.questions.length - 1
                                  ? null
                                  : () => _showQuestion(_currentIndex + 1),
                              icon: const Icon(Icons.arrow_forward),
                              label: const Text('Next'),
                              iconAlignment: IconAlignment.end,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _QuestionAnswerContent extends StatelessWidget {
  final InterviewQuestion question;

  const _QuestionAnswerContent({required this.question});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question.answer, style: const TextStyle(height: 1.55)),
          const SizedBox(height: 14),
          _AnswerSection(title: 'Practical example', body: question.example),
          if (question.code.isNotEmpty) ...[
            const SizedBox(height: 14),
            _AnswerSection(
              title: 'Code / query',
              body: question.code,
              code: true,
            ),
          ],
          if (question.output.isNotEmpty) ...[
            const SizedBox(height: 14),
            _AnswerSection(title: 'Expected output', body: question.output),
          ],
          const SizedBox(height: 14),
          _AnswerSection(title: 'Real-world use case', body: question.useCase),
          const SizedBox(height: 14),
          _AnswerSection(
            title: 'Important interview points',
            body: question.keyPoints,
          ),
        ],
      ),
    );
  }
}

class _AnswerSection extends StatelessWidget {
  final String title;
  final String body;
  final bool code;

  const _AnswerSection({
    required this.title,
    required this.body,
    this.code = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: code ? const Color(0xFFF0F3F8) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: SelectableText(
            body,
            style: TextStyle(
              height: 1.45,
              fontFamily: code ? 'monospace' : null,
              fontSize: code ? 13 : 14,
            ),
          ),
        ),
      ],
    );
  }
}

Future<void> _runInterviewProgressAction(
  BuildContext context,
  Future<void> Function() action,
) async {
  try {
    await action();
    _syncInterviewBookmarks();
    learningDataRevision.value++;
  } on Exception catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save interview progress: $error')),
      );
    }
  }
}

class MyLearningPage extends StatelessWidget {
  final int initialTabIndex;

  const MyLearningPage({super.key, this.initialTabIndex = 0});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: initialTabIndex == 1 ? 1 : 0,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Learning'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.bookmark_outline), text: 'Saved Questions'),
              Tab(icon: Icon(Icons.history), text: 'Test History'),
            ],
          ),
        ),
        body: ValueListenableBuilder<int>(
          valueListenable: learningDataRevision,
          builder: (context, revision, child) {
            return TabBarView(
              children: [
                _SavedQuestionsTab(
                  questionIds: InterviewProgressStore
                      .instance
                      .bookmarkedQuestionIds
                      .toList(),
                ),
                _TestHistoryTab(attempts: testAttempts),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SavedQuestionsTab extends StatelessWidget {
  final List<String> questionIds;

  const _SavedQuestionsTab({required this.questionIds});

  @override
  Widget build(BuildContext context) {
    final questions = questionIds
        .map((id) => interviewQuestionsById[id])
        .whereType<InterviewQuestion>()
        .toList();
    if (questions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No saved questions yet. Bookmark an interview question to find it here.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: questions.map((question) {
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            title: Text(question.question),
            subtitle: Text(
              '${question.subject} • ${question.difficultyLabel}\n${question.answer}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: IconButton(
              tooltip: 'Remove saved question',
              onPressed: () => _runInterviewProgressAction(
                context,
                () =>
                    InterviewProgressStore.instance.toggleBookmark(question.id),
              ),
              icon: const Icon(Icons.bookmark_remove_outlined),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => InterviewQuestionDetailPage(
                    questions: questions,
                    initialIndex: questions.indexOf(question),
                  ),
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }
}

class _TestHistoryTab extends StatelessWidget {
  final List<TestAttempt> attempts;

  const _TestHistoryTab({required this.attempts});

  @override
  Widget build(BuildContext context) {
    if (attempts.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No test history yet. Complete a practice or mock test to see your results here.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: attempts.map((attempt) {
        final date = attempt.completedAt;
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: primaryColor.withValues(alpha: 0.1),
              child: const Icon(Icons.assignment_turned_in_outlined),
            ),
            title: Text(attempt.course.title),
            subtitle: Text(
              '${attempt.isMockTest
                  ? '${attempt.difficulty} Mock (${attempt.totalQuestions} questions)'
                  : attempt.isTimed
                  ? 'Timed Mock'
                  : 'Practice'} • ${attempt.score}/${attempt.totalQuestions} correct • ${attempt.accuracyPercent}% • ${date.day}/${date.month}/${date.year}',
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TestResultsPage(attempt: attempt),
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }
}

// PROFILE PAGE

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: completedLessonRevision,
      builder: (context, revision, child) {
        final totalLessons = availableCourses.fold<int>(
          0,
          (total, course) => total + course.topics.length,
        );
        final completedLessons = availableCourses.fold<int>(
          0,
          (total, course) => total + course.completedTopicsCount,
        );
        final progress = totalLessons == 0
            ? 0.0
            : completedLessons / totalLessons;

        return SafeArea(
          child: ListView(
            key: const ValueKey('profile-list'),
            padding: const EdgeInsets.all(18),
            children: [
              const Text(
                'My Profile',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 25),
              const CircleAvatar(
                radius: 48,
                backgroundColor: Color(0xFFE2EAFE),
                child: Icon(Icons.person, size: 55, color: primaryColor),
              ),
              const SizedBox(height: 14),
              ValueListenableBuilder<LearnHubSettings>(
                valueListenable: LearnHubSettingsStore.instance.settings,
                builder: (context, settings, child) => Text(
                  settings.learnerName.trim().isEmpty
                      ? 'Welcome!'
                      : settings.learnerName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Text('Welcome to LearnHub', textAlign: TextAlign.center),
              const SizedBox(height: 25),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ProfileStat(
                        value: '${availableCourses.length}',
                        label: 'Courses',
                      ),
                      ProfileStat(value: '$totalLessons', label: 'Lessons'),
                      ProfileStat(
                        value: '${(progress * 100).round()}%',
                        label: 'Progress',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ProfileMenuTile(
                icon: Icons.menu_book,
                title: 'My Courses',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const DashboardRoutePage(child: CoursesPage()),
                    ),
                  );
                },
              ),
              ProfileMenuTile(
                icon: Icons.bookmark_outline,
                title: 'Saved Questions',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MyLearningPage()),
                  );
                },
              ),
              ProfileMenuTile(
                icon: Icons.history,
                title: 'Learning History',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MyLearningPage(initialTabIndex: 1),
                    ),
                  );
                },
              ),
              ProfileMenuTile(
                icon: Icons.workspace_premium,
                title: 'Certificates',
                onTap: () {
                  final progress = availableCourses
                      .map(
                        (course) => CertificateProgress(
                          courseName: course.title,
                          completedLessons: course.completedTopicsCount,
                          totalLessons: course.topics.length,
                        ),
                      )
                      .toList();
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          CertificatesPage(courseProgress: progress),
                    ),
                  );
                },
              ),
              ProfileMenuTile(
                icon: Icons.settings,
                title: 'Settings',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => SettingsPage(
                      subjects: courseSubjectOrder,
                      onLogout: () => Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute<void>(
                          builder: (_) => const WelcomeScreen(),
                        ),
                        (route) => false,
                      ),
                      onDeleteAccount: _deleteLocalAccountData,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

}

// PROFILE STATISTICS

class ProfileStat extends StatelessWidget {
  final String value;
  final String label;

  const ProfileStat({super.key, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 5),
        Text(label),
      ],
    );
  }
}

// PROFILE MENU

class ProfileMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const ProfileMenuTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 9),
      child: ListTile(
        leading: Icon(icon, color: primaryColor),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
