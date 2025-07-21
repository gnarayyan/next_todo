import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../blocs/blocs.dart';
import '../services/database_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(gradient: themeState.backgroundGradient),
            child: SafeArea(
              child: Column(
                children: [
                  _buildAppBar(context),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _buildAppearanceSection(context),
                        const SizedBox(height: 20),
                        _buildLanguageSection(context),
                        const SizedBox(height: 20),
                        _buildNotificationSection(context),
                        const SizedBox(height: 20),
                        _buildAboutSection(context),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
          ),
          const SizedBox(width: 8),
          Text(
            'Settings',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0);
  }

  Widget _buildAppearanceSection(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, themeState) {
            return Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.palette,
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Appearance',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  SwitchListTile(
                    title: const Text('Dark Mode'),
                    subtitle: const Text(
                      'Switch between light and dark themes',
                    ),
                    value: themeState.isDarkMode,
                    onChanged: (value) =>
                        context.read<ThemeBloc>().add(ToggleTheme()),
                    secondary: Icon(
                      themeState.isDarkMode
                          ? Icons.dark_mode
                          : Icons.light_mode,
                    ),
                  ),
                ],
              ),
            );
          },
        )
        .animate()
        .fadeIn(delay: 100.ms, duration: 500.ms)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildLanguageSection(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, themeState) {
            return Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.language,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSecondaryContainer,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Language',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    title: const Text('App Language'),
                    subtitle: Text(
                      _getLanguageName(themeState.selectedLanguage),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _showLanguageDialog(context, themeState),
                  ),
                ],
              ),
            );
          },
        )
        .animate()
        .fadeIn(delay: 200.ms, duration: 500.ms)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildNotificationSection(BuildContext context) {
    return Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.tertiaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.notifications,
                        color: Theme.of(
                          context,
                        ).colorScheme.onTertiaryContainer,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Notifications',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              FutureBuilder<bool>(
                future: _getNotificationSettings(),
                builder: (context, snapshot) {
                  final isEnabled = snapshot.data ?? true;
                  return SwitchListTile(
                    title: const Text('Task Reminders'),
                    subtitle: const Text('Get notified about upcoming tasks'),
                    value: isEnabled,
                    onChanged: (value) => _setNotificationSettings(value),
                    secondary: const Icon(Icons.alarm),
                  );
                },
              ),
              ListTile(
                title: const Text('Daily Motivation'),
                subtitle: const Text('Receive daily motivational messages'),
                trailing: Switch(
                  value: true, // You can make this dynamic
                  onChanged: (value) {
                    // Handle daily motivation toggle
                  },
                ),
                leading: const Icon(Icons.wb_sunny),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: 300.ms, duration: 500.ms)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildAboutSection(BuildContext context) {
    return Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.info,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'About',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                title: const Text('Version'),
                subtitle: const Text('1.0.0'),
                leading: const Icon(Icons.info_outline),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _showAboutDialog(context),
              ),
              ListTile(
                title: const Text('Privacy Policy'),
                leading: const Icon(Icons.privacy_tip),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Navigate to privacy policy
                },
              ),
              ListTile(
                title: const Text('Terms of Service'),
                leading: const Icon(Icons.description),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Navigate to terms of service
                },
              ),
              ListTile(
                title: const Text('Rate App'),
                leading: const Icon(Icons.star_rate),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Navigate to app store rating
                },
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: 400.ms, duration: 500.ms)
        .slideY(begin: 0.2, end: 0);
  }

  String _getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'ne':
        return 'नेपाली (Nepali)';
      default:
        return 'English';
    }
  }

  void _showLanguageDialog(BuildContext context, ThemeState themeState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: themeState.selectedLanguage,
              onChanged: (value) {
                if (value != null) {
                  context.read<ThemeBloc>().add(SetLanguage(value));
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('नेपाली (Nepali)'),
              value: 'ne',
              groupValue: themeState.selectedLanguage,
              onChanged: (value) {
                if (value != null) {
                  context.read<ThemeBloc>().add(SetLanguage(value));
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'NextTodo',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          gradient: context.read<ThemeBloc>().state.primaryGradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.task_alt, color: Colors.white, size: 32),
      ),
      children: [
        const SizedBox(height: 16),
        const Text(
          'NextTodo is a beautiful and intuitive task management app designed to help you stay organized and productive.',
        ),
        const SizedBox(height: 16),
        const Text(
          'Features:\n'
          '• Dark/Light theme support\n'
          '• Multi-language support\n'
          '• Task reminders\n'
          '• Focus mode\n'
          '• Beautiful animations\n'
          '• Offline storage',
        ),
      ],
    );
  }

  Future<bool> _getNotificationSettings() async {
    return DatabaseService.notificationsEnabled;
  }

  Future<void> _setNotificationSettings(bool enabled) async {
    await DatabaseService.setNotificationsEnabled(enabled);
  }
}
