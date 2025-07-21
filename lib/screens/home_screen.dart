import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/task_card.dart';
import '../widgets/empty_state_widget.dart';
import 'add_task_screen.dart';
import 'settings_screen.dart';
import 'calendar_screen.dart';
import 'focus_mode_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTasks();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadTasks() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskProvider>(context, listen: false).loadTasks();
    });
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
              _buildGreetingSection(),
              _buildSearchBar(),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTaskList(TaskFilter.today),
                    _buildTaskList(TaskFilter.all),
                    _buildTaskList(TaskFilter.starred),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'NextTodo',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () => _navigateToCalendar(),
                icon: const Icon(Icons.calendar_today),
                tooltip: 'Calendar View',
              ),
              IconButton(
                onPressed: () => _navigateToSettings(),
                icon: const Icon(Icons.settings),
                tooltip: 'Settings',
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.1, end: 0);
  }

  Widget _buildGreetingSection() {
    final now = DateTime.now();
    String greeting;

    if (now.hour < 12) {
      greeting = 'Good Morning';
    } else if (now.hour < 17) {
      greeting = 'Good Afternoon';
    } else if (now.hour < 21) {
      greeting = 'Good Evening';
    } else {
      greeting = 'Good Night';
    }

    return Consumer<TaskProvider>(
          builder: (context, taskProvider, child) {
            final stats = taskProvider.getTaskStats();

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: Provider.of<ThemeProvider>(context).primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withAlpha((0.3 * 255).toInt()),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$greeting! 👋',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You have ${stats['pending']} pending tasks',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withAlpha((0.9 * 255).toInt()),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildStatCard('Today', stats['today']!, Colors.orange),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        'Completed',
                        stats['completed']!,
                        Colors.green,
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard('Overdue', stats['overdue']!, Colors.red),
                    ],
                  ),
                ],
              ),
            );
          },
        )
        .animate()
        .fadeIn(delay: 200.ms, duration: 600.ms)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildStatCard(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha((0.2 * 255).toInt()),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withAlpha((0.9 * 255).toInt()),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search tasks...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _isSearching
              ? IconButton(
                  onPressed: _clearSearch,
                  icon: const Icon(Icons.clear),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
        ),
        onChanged: _onSearchChanged,
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 600.ms);
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      indicatorColor: Theme.of(context).colorScheme.primary,
      labelColor: Theme.of(context).colorScheme.primary,
      unselectedLabelColor: Theme.of(
        context,
      ).colorScheme.onSurface.withAlpha((0.7 * 255).toInt()),
      tabs: const [
        Tab(text: 'Today'),
        Tab(text: 'All'),
        Tab(text: 'Focus'),
      ],
    ).animate().fadeIn(delay: 400.ms, duration: 600.ms);
  }

  Widget _buildTaskList(TaskFilter filter) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        taskProvider.setFilter(filter);
        final tasks = taskProvider.tasks;

        if (tasks.isEmpty) {
          return _buildEmptyState(filter);
        }

        return ReorderableListView.builder(
          padding: const EdgeInsets.only(bottom: 100),
          itemCount: tasks.length,
          onReorder: taskProvider.reorderTasks,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return TaskCard(
              key: ValueKey(task.id),
              task: task,
              onTap: () => _editTask(task),
              onLongPress: () => _showTaskOptions(task),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(TaskFilter filter) {
    switch (filter) {
      case TaskFilter.today:
        return EmptyStateWidget(
          title: 'No tasks for today',
          subtitle: 'Take a moment to plan your day',
          icon: Icons.today,
          actionText: 'Add your first task',
          onActionPressed: _addTask,
        );
      case TaskFilter.all:
        return EmptyStateWidget(
          title: 'No tasks yet',
          subtitle: 'Start your productivity journey',
          icon: Icons.task_alt,
          actionText: 'Create your first task',
          onActionPressed: _addTask,
        );
      case TaskFilter.starred:
        return EmptyStateWidget(
          title: 'No focus tasks',
          subtitle: 'Star important tasks to focus on them',
          icon: Icons.star,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildFAB() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton.small(
          onPressed: _navigateToFocusMode,
          heroTag: "focus",
          backgroundColor: Theme.of(context).colorScheme.secondary,
          child: const Icon(Icons.center_focus_strong),
        ).animate().scale(delay: 600.ms, duration: 400.ms),
        const SizedBox(height: 8),
        FloatingActionButton(
          onPressed: _addTask,
          heroTag: "add",
          child: const Icon(Icons.add),
        ).animate().scale(delay: 500.ms, duration: 400.ms),
      ],
    );
  }

  void _onSearchChanged(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
    });
    Provider.of<TaskProvider>(context, listen: false).setSearchQuery(query);
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
    });
    Provider.of<TaskProvider>(context, listen: false).clearSearch();
  }

  void _addTask() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const AddTaskScreen()));
  }

  void _editTask(Task task) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => AddTaskScreen(taskToEdit: task)),
    );
  }

  void _navigateToSettings() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const SettingsScreen()));
  }

  void _navigateToCalendar() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const CalendarScreen()));
  }

  void _navigateToFocusMode() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const FocusModeScreen()));
  }

  void _showTaskOptions(Task task) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildTaskOptionsBottomSheet(task),
    );
  }

  Widget _buildTaskOptionsBottomSheet(Task task) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit'),
            onTap: () {
              Navigator.pop(context);
              _editTask(task);
            },
          ),
          ListTile(
            leading: Icon(
              task.isStarred ? Icons.star : Icons.star_border,
              color: task.isStarred ? Colors.amber : null,
            ),
            title: Text(task.isStarred ? 'Remove from Focus' : 'Add to Focus'),
            onTap: () {
              Navigator.pop(context);
              Provider.of<TaskProvider>(
                context,
                listen: false,
              ).toggleTaskStar(task.id);
            },
          ),
          ListTile(
            leading: const Icon(Icons.check_circle),
            title: Text(
              task.isCompleted ? 'Mark as Pending' : 'Mark as Complete',
            ),
            onTap: () {
              Navigator.pop(context);
              Provider.of<TaskProvider>(
                context,
                listen: false,
              ).toggleTaskCompletion(task.id);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Delete', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              Provider.of<TaskProvider>(
                context,
                listen: false,
              ).deleteTask(task.id);
            },
          ),
        ],
      ),
    );
  }
}
