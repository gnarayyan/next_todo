import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/theme_provider.dart';
import '../providers/task_provider.dart';
import '../widgets/task_card.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: Provider.of<ThemeProvider>(context).backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [_buildAppBar(), _buildCalendarView(), _buildTasksList()],
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
            'Calendar View',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0);
  }

  Widget _buildCalendarView() {
    return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildCalendarHeader(),
                const SizedBox(height: 16),
                _buildCalendarGrid(),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(delay: 200.ms, duration: 500.ms)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildCalendarHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: _previousMonth,
          icon: const Icon(Icons.chevron_left),
        ),
        Text(
          _getMonthYearText(),
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        IconButton(
          onPressed: _nextMonth,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  Widget _buildCalendarGrid() {
    return Column(
      children: [
        // Weekday headers
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
              .map(
                (day) => SizedBox(
                  width: 40,
                  child: Text(
                    day,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withAlpha((0.6 * 255).toInt()),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),
        // Calendar days
        ..._buildCalendarWeeks(),
      ],
    );
  }

  List<Widget> _buildCalendarWeeks() {
    final firstDayOfMonth = DateTime(_focusedDate.year, _focusedDate.month, 1);
    final lastDayOfMonth = DateTime(
      _focusedDate.year,
      _focusedDate.month + 1,
      0,
    );
    final firstDayWeekday = firstDayOfMonth.weekday % 7;

    final weeks = <Widget>[];
    var currentDate = firstDayOfMonth.subtract(Duration(days: firstDayWeekday));

    while (currentDate.isBefore(lastDayOfMonth) || currentDate.day != 1) {
      final weekDays = <Widget>[];

      for (int i = 0; i < 7; i++) {
        weekDays.add(_buildCalendarDay(currentDate));
        currentDate = currentDate.add(const Duration(days: 1));
      }

      weeks.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekDays,
          ),
        ),
      );

      if (currentDate.month != _focusedDate.month && currentDate.day > 7) {
        break;
      }
    }

    return weeks;
  }

  Widget _buildCalendarDay(DateTime date) {
    final isSelected = _isSameDay(date, _selectedDate);
    final isToday = _isSameDay(date, DateTime.now());
    final isCurrentMonth = date.month == _focusedDate.month;

    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final tasksForDate = taskProvider.getTasksForDate(date);
        final hasEvents = tasksForDate.isNotEmpty;

        return GestureDetector(
          onTap: () => setState(() => _selectedDate = date),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : isToday
                  ? Theme.of(context).colorScheme.primaryContainer
                  : null,
              borderRadius: BorderRadius.circular(8),
              border: isToday && !isSelected
                  ? Border.all(color: Theme.of(context).colorScheme.primary)
                  : null,
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    date.day.toString(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isSelected
                          ? Theme.of(context).colorScheme.onPrimary
                          : isCurrentMonth
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(context).colorScheme.onSurface.withAlpha(
                              (0.4 * 255).toInt(),
                            ),
                      fontWeight: isSelected || isToday
                          ? FontWeight.bold
                          : null,
                    ),
                  ),
                ),
                if (hasEvents)
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTasksList() {
    return Expanded(
          child: Consumer<TaskProvider>(
            builder: (context, taskProvider, child) {
              final tasks = taskProvider.getTasksForDate(_selectedDate);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Tasks for ${_getSelectedDateText()}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: tasks.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.event_available,
                                  size: 64,
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withAlpha((0.3 * 255).toInt()),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No tasks for this date',
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withAlpha((0.6 * 255).toInt()),
                                      ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(top: 8, bottom: 16),
                            itemCount: tasks.length,
                            itemBuilder: (context, index) {
                              final task = tasks[index];
                              return TaskCard(
                                key: ValueKey(task.id),
                                task: task,
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        )
        .animate()
        .fadeIn(delay: 400.ms, duration: 500.ms)
        .slideY(begin: 0.2, end: 0);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _getMonthYearText() {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${months[_focusedDate.month - 1]} ${_focusedDate.year}';
  }

  String _getSelectedDateText() {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    if (_isSameDay(_selectedDate, DateTime.now())) {
      return 'Today';
    } else if (_isSameDay(
      _selectedDate,
      DateTime.now().add(const Duration(days: 1)),
    )) {
      return 'Tomorrow';
    } else {
      return '${months[_selectedDate.month - 1]} ${_selectedDate.day}, ${_selectedDate.year}';
    }
  }

  void _previousMonth() {
    setState(() {
      _focusedDate = DateTime(_focusedDate.year, _focusedDate.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedDate = DateTime(_focusedDate.year, _focusedDate.month + 1, 1);
    });
  }
}
