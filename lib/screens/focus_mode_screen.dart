import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/theme_provider.dart';
import '../providers/task_provider.dart';
import '../widgets/task_card.dart';

class FocusModeScreen extends StatefulWidget {
  const FocusModeScreen({super.key});

  @override
  State<FocusModeScreen> createState() => _FocusModeScreenState();
}

class _FocusModeScreenState extends State<FocusModeScreen>
    with TickerProviderStateMixin {
  bool _isFocusMode = false;
  int _focusTimeMinutes = 25; // Pomodoro style
  late AnimationController _pulseController;
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _progressController = AnimationController(
      duration: Duration(minutes: _focusTimeMinutes),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: Provider.of<ThemeProvider>(context).backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: _isFocusMode ? _buildFocusSession() : _buildFocusSetup(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
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
            'Focus Mode',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          if (_isFocusMode)
            IconButton(
              onPressed: _exitFocusMode,
              icon: const Icon(Icons.stop),
              tooltip: 'Exit Focus Mode',
            ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0);
  }

  Widget _buildFocusSetup() {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final focusTasks = taskProvider.focusTasks;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildFocusIntro(),
              const SizedBox(height: 32),
              _buildTimeSelector(),
              const SizedBox(height: 32),
              _buildFocusTasksList(focusTasks),
              const SizedBox(height: 32),
              _buildStartFocusButton(focusTasks.isNotEmpty),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFocusIntro() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: Provider.of<ThemeProvider>(context).primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.center_focus_strong,
            size: 64,
            color: Colors.white,
          ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
          const SizedBox(height: 16),
          Text(
            'Focus Mode',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select your most important tasks and focus on them without distractions',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildTimeSelector() {
    return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Focus Duration',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [15, 25, 45, 60].map((minutes) {
                    final isSelected = _focusTimeMinutes == minutes;
                    return GestureDetector(
                      onTap: () => setState(() => _focusTimeMinutes = minutes),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${minutes}m',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(delay: 300.ms, duration: 500.ms)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildFocusTasksList(List<dynamic> focusTasks) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Focus Tasks',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${focusTasks.length}/3',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (focusTasks.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.star_border,
                          size: 64,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No focus tasks yet',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.6),
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Star tasks from your task list to add them to focus mode',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.5),
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: focusTasks.length,
                    itemBuilder: (context, index) {
                      final task = focusTasks[index];
                      return TaskCard(key: ValueKey(task.id), task: task);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 400.ms, duration: 500.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildStartFocusButton(bool hasEvents) {
    return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: hasEvents ? _startFocusMode : null,
            icon: const Icon(Icons.play_arrow),
            label: Text('Start Focus Session ($_focusTimeMinutes min)'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        )
        .animate()
        .fadeIn(delay: 500.ms, duration: 500.ms)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildFocusSession() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildFocusTimer(),
                  const SizedBox(height: 40),
                  _buildFocusMessage(),
                  const SizedBox(height: 40),
                  _buildFocusControls(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFocusTimer() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          width: 200 + (_pulseController.value * 20),
          height: 200 + (_pulseController.value * 20),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: Provider.of<ThemeProvider>(context).primaryGradient,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(
                  0.3 + (_pulseController.value * 0.2),
                ),
                blurRadius: 20 + (_pulseController.value * 10),
                spreadRadius: 5 + (_pulseController.value * 5),
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$_focusTimeMinutes:00',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Focus Time',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFocusMessage() {
    final messages = [
      'Stay focused on your goals! 🎯',
      'You\'re doing great! Keep going! 💪',
      'Deep work leads to great results! 🚀',
      'This is your focused time! ⭐',
      'Productivity mode: ON! ⚡',
    ];

    final message = messages[DateTime.now().second % messages.length];

    return Text(
      message,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.primary,
      ),
      textAlign: TextAlign.center,
    ).animate().fadeIn().then().shimmer(duration: 2000.ms);
  }

  Widget _buildFocusControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: _pauseFocusMode,
          icon: const Icon(Icons.pause),
          label: const Text('Pause'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
        ),
        ElevatedButton.icon(
          onPressed: _exitFocusMode,
          icon: const Icon(Icons.stop),
          label: const Text('Stop'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        ),
      ],
    );
  }

  void _startFocusMode() {
    setState(() => _isFocusMode = true);
    _progressController.forward();

    // Show motivation snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Focus session started! You\'ve got this! 🚀'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _pauseFocusMode() {
    _progressController.stop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Focus session paused'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _exitFocusMode() {
    setState(() => _isFocusMode = false);
    _progressController.reset();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Focus session ended. Great work! 👏'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 3),
      ),
    );
  }
}
