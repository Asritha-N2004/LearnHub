import 'dart:async';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../certificates/certificate_store.dart';
import 'learnhub_settings.dart';
import 'local_account_service.dart';

class SettingsPage extends StatefulWidget {
  final List<String> subjects;
  final VoidCallback onLogout;
  final Future<void> Function() onDeleteAccount;

  const SettingsPage({
    super.key,
    required this.subjects,
    required this.onLogout,
    required this.onDeleteAccount,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  LearnHubSettingsStore get _store => LearnHubSettingsStore.instance;

  @override
  void initState() {
    super.initState();
    unawaited(_loadSettings());
  }

  Future<void> _loadSettings() async {
    try {
      await _store.load();
    } on Exception catch (error) {
      if (mounted) {
        _showMessage('Could not load settings: $error');
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _save(LearnHubSettings value) async {
    try {
      await _store.save(value);
      _showMessage('Settings saved.');
    } on Exception catch (error) {
      _showMessage('Could not save settings: $error');
    }
  }

  Future<void> _editProfile({
    required bool editName,
    required LearnHubSettings settings,
  }) async {
    final value = await showDialog<String>(
      context: context,
      builder: (_) => _ProfileEditDialog(
        editName: editName,
        initialValue: editName ? settings.learnerName : settings.email,
        emailRequired: settings.email.isNotEmpty,
      ),
    );
    if (value == null) {
      return;
    }
    final updatedSettings = editName
        ? settings.copyWith(learnerName: value)
        : settings.copyWith(email: value);
    try {
      await LocalAccountService.updateProfile(
        currentEmail: settings.email,
        fullName: updatedSettings.learnerName,
        newEmail: updatedSettings.email,
      );
      await _store.save(updatedSettings);
      if (editName) {
        await CertificateStore.instance.renameLearner(
          previousName: settings.learnerName,
          newName: value,
        );
      }
      _showMessage('Profile updated.');
    } on Exception catch (error) {
      _showMessage('Could not update profile: $error');
    }
  }

  Future<void> _changePassword(String email) async {
    late final bool hasPassword;
    try {
      hasPassword = await LocalPasswordStore.instance.hasPassword(email: email);
    } on Exception catch (error) {
      _showMessage('Could not access secure password storage: $error');
      return;
    }
    if (!mounted) {
      return;
    }
    final currentPassword = TextEditingController();
    final newPassword = TextEditingController();
    final confirmation = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String? errorMessage;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Change password'),
          content: SizedBox(
            width: 420,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (hasPassword) ...[
                      TextFormField(
                        controller: currentPassword,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Current password',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => (value ?? '').isEmpty
                            ? 'Enter your current password.'
                            : null,
                      ),
                      const SizedBox(height: 12),
                    ],
                    TextFormField(
                      controller: newPassword,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'New password',
                        helperText: 'Use at least 8 characters.',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => (value ?? '').length < 8
                          ? 'Password must be at least 8 characters.'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: confirmation,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Confirm new password',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value != newPassword.text
                          ? 'Passwords do not match.'
                          : null,
                    ),
                    if (errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (!(formKey.currentState?.validate() ?? false)) {
                  return;
                }
                try {
                  await LocalPasswordStore.instance.changePassword(
                    email: email,
                    currentPassword: hasPassword ? currentPassword.text : null,
                    newPassword: newPassword.text,
                  );
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }
                  _showMessage('Password updated securely on this device.');
                } on Exception catch (error) {
                  setDialogState(() => errorMessage = error.toString());
                }
              },
              child: const Text('Update password'),
            ),
          ],
        ),
      ),
    );
    currentPassword.dispose();
    newPassword.dispose();
    confirmation.dispose();
  }

  Future<void> _editPreferredSubjects(LearnHubSettings settings) async {
    final selected = settings.preferredSubjects.isEmpty
        ? widget.subjects.toSet()
        : settings.preferredSubjects.toSet();
    String? errorMessage;
    final result = await showDialog<List<String>>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Preferred learning subjects'),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final subject in widget.subjects)
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: selected.contains(subject),
                      title: Text(subject),
                      onChanged: (checked) {
                        setDialogState(() {
                          if (checked ?? false) {
                            selected.add(subject);
                          } else {
                            selected.remove(subject);
                          }
                          errorMessage = null;
                        });
                      },
                    ),
                  if (errorMessage != null)
                    Text(
                      errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (selected.isEmpty) {
                  setDialogState(
                    () => errorMessage = 'Select at least one subject.',
                  );
                  return;
                }
                Navigator.pop(dialogContext, selected.toList()..sort());
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    if (result == null) {
      return;
    }
    final savedSubjects = result.length == widget.subjects.length
        ? const <String>[]
        : result;
    await _save(settings.copyWith(preferredSubjects: savedSubjects));
  }

  Future<void> _showPrivacyInformation() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy information'),
        content: const Text(
          'LearnHub stores your profile preferences, course progress, saved '
          'questions, and earned certificates locally on this device. Your '
          'local password is stored using the platform secure-storage service. '
          'This demo app does not send this information to a LearnHub server.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'LearnHub',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.school, color: Color(0xFF2457D6)),
      children: const [
        Text(
          'LearnHub helps you learn, practice, and prepare for technical '
          'interviews across eight technology subjects.',
        ),
      ],
    );
  }

  Future<void> _copySupportEmail() async {
    await Clipboard.setData(const ClipboardData(text: 'support@learnhub.app'));
    _showMessage('Support email copied: support@learnhub.app');
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You can sign in or continue as a guest later.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      widget.onLogout();
    }
  }

  Future<void> _confirmDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete local account data?'),
        content: const Text(
          'This permanently removes the profile, password, settings, course '
          'progress, saved interview questions, and certificates stored on '
          'this device. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete local data'),
          ),
        ],
      ),
    );
    if (!(confirmed ?? false)) {
      return;
    }
    try {
      await widget.onDeleteAccount();
      _showMessage('Local LearnHub data deleted.');
      widget.onLogout();
    } on Exception catch (error) {
      _showMessage('Could not delete local data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<LearnHubSettings>(
      valueListenable: _store.settings,
      builder: (context, settings, child) => Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth > 850
                  ? 850.0
                  : constraints.maxWidth;
              return Center(
                child: SizedBox(
                  width: width,
                  child: ListView(
                    padding: const EdgeInsets.all(18),
                    children: [
                      _SettingsSection(
                        title: 'Account Settings',
                        icon: Icons.manage_accounts_outlined,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.person_outline),
                            title: const Text('Edit Name'),
                            subtitle: Text(
                              settings.learnerName.trim().isEmpty
                                  ? 'Welcome!'
                                  : settings.learnerName,
                            ),
                            onTap: () => _editProfile(
                              editName: true,
                              settings: settings,
                            ),
                          ),
                          ListTile(
                            leading: const Icon(Icons.email_outlined),
                            title: const Text('Edit Email'),
                            subtitle: Text(
                              settings.email.isEmpty
                                  ? 'Not set'
                                  : settings.email,
                            ),
                            onTap: () => _editProfile(
                              editName: false,
                              settings: settings,
                            ),
                          ),
                          ListTile(
                            leading: const Icon(Icons.lock_outline),
                            title: const Text('Change Password'),
                            subtitle: const Text(
                              'Stored securely on this device',
                            ),
                            onTap: () => _changePassword(settings.email),
                          ),
                          ListTile(
                            leading: const Icon(Icons.badge_outlined),
                            title: const Text('Profile Information'),
                            subtitle: Text(
                              '${settings.learnerName.trim().isEmpty ? 'Welcome!' : settings.learnerName} • ${settings.email.isEmpty ? 'Email not set' : settings.email}',
                            ),
                            onTap: () => showDialog<void>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Profile information'),
                                content: Text(
                                  'Name: ${settings.learnerName.trim().isEmpty ? 'Welcome!' : settings.learnerName}\n'
                                  'Email: ${settings.email.isEmpty ? 'Not set' : settings.email}',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Close'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      _SettingsSection(
                        title: 'Appearance',
                        icon: Icons.palette_outlined,
                        children: [
                          RadioGroup<ThemeMode>(
                            groupValue: settings.themeMode,
                            onChanged: (value) {
                              if (value != null) {
                                _save(settings.copyWith(themeMode: value));
                              }
                            },
                            child: Column(
                              children: [
                                for (final mode in ThemeMode.values)
                                  RadioListTile<ThemeMode>(
                                    title: Text(_themeModeLabel(mode)),
                                    value: mode,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      _SettingsSection(
                        title: 'Notifications',
                        icon: Icons.notifications_outlined,
                        children: [
                          SwitchListTile(
                            title: const Text('Enable Notifications'),
                            value: settings.notificationsEnabled,
                            onChanged: (value) => _save(
                              settings.copyWith(notificationsEnabled: value),
                            ),
                          ),
                          SwitchListTile(
                            title: const Text('Learning Reminders'),
                            value: settings.learningRemindersEnabled,
                            onChanged: settings.notificationsEnabled
                                ? (value) => _save(
                                    settings.copyWith(
                                      learningRemindersEnabled: value,
                                    ),
                                  )
                                : null,
                          ),
                          SwitchListTile(
                            title: const Text('Assessment Notifications'),
                            value: settings.assessmentNotificationsEnabled,
                            onChanged: settings.notificationsEnabled
                                ? (value) => _save(
                                    settings.copyWith(
                                      assessmentNotificationsEnabled: value,
                                    ),
                                  )
                                : null,
                          ),
                          SwitchListTile(
                            title: const Text('Certificate Notifications'),
                            value: settings.certificateNotificationsEnabled,
                            onChanged: settings.notificationsEnabled
                                ? (value) => _save(
                                    settings.copyWith(
                                      certificateNotificationsEnabled: value,
                                    ),
                                  )
                                : null,
                          ),
                        ],
                      ),
                      _SettingsSection(
                        title: 'Learning Preferences',
                        icon: Icons.tune,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.category_outlined),
                            title: const Text('Preferred Learning Subjects'),
                            subtitle: Text(
                              settings.preferredSubjects.isEmpty
                                  ? 'All subjects'
                                  : settings.preferredSubjects.join(', '),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () => _editPreferredSubjects(settings),
                          ),
                          ListTile(
                            leading: const Icon(Icons.flag_outlined),
                            title: const Text('Daily Learning Goal'),
                            subtitle: Text(
                              '${settings.dailyLearningGoalMinutes} minutes per day',
                            ),
                            trailing: DropdownButton<int>(
                              value: settings.dailyLearningGoalMinutes,
                              items: const [15, 30, 45, 60, 90]
                                  .map(
                                    (minutes) => DropdownMenuItem(
                                      value: minutes,
                                      child: Text('$minutes min'),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  _save(
                                    settings.copyWith(
                                      dailyLearningGoalMinutes: value,
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                          ListTile(
                            leading: const Icon(Icons.language),
                            title: const Text('Language Preference'),
                            subtitle: Text(settings.language),
                            trailing: DropdownButton<String>(
                              value: settings.language,
                              items:
                                  const [
                                        'English',
                                        'Spanish',
                                        'French',
                                        'Hindi',
                                      ]
                                      .map(
                                        (language) => DropdownMenuItem(
                                          value: language,
                                          child: Text(language),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  _save(settings.copyWith(language: value));
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      _SettingsSection(
                        title: 'Privacy and Security',
                        icon: Icons.shield_outlined,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.privacy_tip_outlined),
                            title: const Text('Privacy Information'),
                            onTap: _showPrivacyInformation,
                          ),
                          ListTile(
                            leading: const Icon(Icons.password_outlined),
                            title: const Text('Password Security'),
                            subtitle: const Text(
                              'Local password is protected by secure storage',
                            ),
                            onTap: () => _changePassword(settings.email),
                          ),
                          ListTile(
                            leading: const Icon(Icons.logout),
                            title: const Text('Logout Confirmation'),
                            onTap: _confirmLogout,
                          ),
                        ],
                      ),
                      _SettingsSection(
                        title: 'About',
                        icon: Icons.info_outline,
                        children: [
                          const ListTile(
                            leading: Icon(Icons.school_outlined),
                            title: Text('App Name'),
                            subtitle: Text('LearnHub'),
                          ),
                          const ListTile(
                            leading: Icon(Icons.numbers),
                            title: Text('Version'),
                            subtitle: Text('1.0.0'),
                          ),
                          ListTile(
                            leading: const Icon(Icons.menu_book_outlined),
                            title: const Text('About LearnHub'),
                            onTap: _showAbout,
                          ),
                          ListTile(
                            leading: const Icon(Icons.support_agent),
                            title: const Text('Help and Support'),
                            subtitle: const Text('support@learnhub.app'),
                            onTap: _copySupportEmail,
                          ),
                        ],
                      ),
                      _SettingsSection(
                        title: 'Account Actions',
                        icon: Icons.account_circle_outlined,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.logout),
                            title: const Text('Logout'),
                            onTap: _confirmLogout,
                          ),
                          ListTile(
                            leading: Icon(
                              Icons.delete_forever_outlined,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            title: Text(
                              'Delete Account',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                            subtitle: const Text(
                              'Removes all local LearnHub data',
                            ),
                            onTap: _confirmDeleteAccount,
                          ),
                        ],
                      ),
                    ],
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

String _themeModeLabel(ThemeMode mode) {
  return switch (mode) {
    ThemeMode.light => 'Light Theme',
    ThemeMode.dark => 'Dark Theme',
    ThemeMode.system => 'System Default Theme',
  };
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF2457D6)),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _ProfileEditDialog extends StatefulWidget {
  final bool editName;
  final String initialValue;
  final bool emailRequired;

  const _ProfileEditDialog({
    required this.editName,
    required this.initialValue,
    required this.emailRequired,
  });

  @override
  State<_ProfileEditDialog> createState() => _ProfileEditDialogState();
}

class _ProfileEditDialogState extends State<_ProfileEditDialog> {
  late final TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? _validate(String? input) {
    final text = input?.trim() ?? '';
    if (widget.editName && text.isEmpty) {
      return 'Name is required.';
    }
    if (!widget.editName &&
        ((widget.emailRequired && text.isEmpty) ||
            (text.isNotEmpty &&
                !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text)))) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  void _save(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.pop(context, _controller.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final label = widget.editName ? 'Name' : 'Email';
    return AlertDialog(
      title: Text(widget.editName ? 'Edit name' : 'Edit email'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          keyboardType: widget.editName
              ? TextInputType.name
              : TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
          validator: _validate,
          onFieldSubmitted: (_) => _save(context),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => _save(context),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
