import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  List<Task> _recentlyDeleted = [];
  TaskFilter _currentFilter = TaskFilter.today;
  String _searchQuery = '';

  final Uuid _uuid = const Uuid();

  List<Task> get tasks {
    List<Task> filteredTasks = [];

    switch (_currentFilter) {
      case TaskFilter.today:
        filteredTasks = _tasks
            .where((task) => task.isDueToday && !task.isCompleted)
            .toList();
        break;
      case TaskFilter.all:
        filteredTasks = _tasks.where((task) => !task.isCompleted).toList();
        break;
      case TaskFilter.completed:
        filteredTasks = _tasks.where((task) => task.isCompleted).toList();
        break;
      case TaskFilter.overdue:
        filteredTasks = _tasks
            .where((task) => task.isOverdue && !task.isCompleted)
            .toList();
        break;
      case TaskFilter.upcoming:
        filteredTasks = _tasks
            .where(
              (task) =>
                  task.dueDate != null &&
                  task.dueDate!.isAfter(DateTime.now()) &&
                  !task.isCompleted,
            )
            .toList();
        break;
      case TaskFilter.starred:
        filteredTasks = _tasks
            .where((task) => task.isStarred && !task.isCompleted)
            .toList();
        break;
    }

    if (_searchQuery.isNotEmpty) {
      filteredTasks = filteredTasks
          .where(
            (task) =>
                task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                (task.description?.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ??
                    false),
          )
          .toList();
    }

    // Sort by priority and due date
    filteredTasks.sort((a, b) {
      // First sort by completion status
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }

      // Then by starred status
      if (a.isStarred != b.isStarred) {
        return a.isStarred ? -1 : 1;
      }

      // Then by priority
      final priorityCompare = b.priority.index.compareTo(a.priority.index);
      if (priorityCompare != 0) return priorityCompare;

      // Finally by due date
      if (a.dueDate == null && b.dueDate == null) {
        return b.createdAt.compareTo(a.createdAt);
      }
      if (a.dueDate == null) return 1;
      if (b.dueDate == null) return -1;

      return a.dueDate!.compareTo(b.dueDate!);
    });

    return filteredTasks;
  }

  TaskFilter get currentFilter => _currentFilter;
  String get searchQuery => _searchQuery;

  int get todayTasksCount =>
      _tasks.where((task) => task.isDueToday && !task.isCompleted).length;

  int get overduTasksCount =>
      _tasks.where((task) => task.isOverdue && !task.isCompleted).length;

  int get completedTasksCount =>
      _tasks.where((task) => task.isCompleted).length;

  List<Task> get focusTasks => _tasks
      .where((task) => task.isStarred && !task.isCompleted)
      .take(3)
      .toList();

  void loadTasks() {
    _tasks = DatabaseService.getAllTasks();
    notifyListeners();
  }

  Future<void> addTask({
    required String title,
    String? description,
    DateTime? dueDate,
    TaskPriority priority = TaskPriority.medium,
    bool isStarred = false,
  }) async {
    final task = Task(
      id: _uuid.v4(),
      title: title,
      description: description,
      dueDate: dueDate,
      priority: priority,
      isStarred: isStarred,
      createdAt: DateTime.now(),
    );

    _tasks.add(task);
    await DatabaseService.addTask(task);

    if (dueDate != null) {
      await NotificationService.scheduleTaskReminder(task);
    }

    notifyListeners();
  }

  Future<void> updateTask(Task updatedTask) async {
    final index = _tasks.indexWhere((task) => task.id == updatedTask.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
      await DatabaseService.updateTask(updatedTask);

      // Update notification
      await NotificationService.cancelTaskReminder(updatedTask.id);
      if (updatedTask.dueDate != null && !updatedTask.isCompleted) {
        await NotificationService.scheduleTaskReminder(updatedTask);
      }

      notifyListeners();
    }
  }

  Future<void> toggleTaskCompletion(String taskId) async {
    final index = _tasks.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      final task = _tasks[index];
      final updatedTask = task.copyWith(
        isCompleted: !task.isCompleted,
        completedAt: !task.isCompleted ? DateTime.now() : null,
      );

      _tasks[index] = updatedTask;
      await DatabaseService.updateTask(updatedTask);

      if (updatedTask.isCompleted) {
        await NotificationService.cancelTaskReminder(taskId);
        await NotificationService.showTaskCompletedNotification(
          updatedTask.title,
        );
      } else if (updatedTask.dueDate != null) {
        await NotificationService.scheduleTaskReminder(updatedTask);
      }

      notifyListeners();
    }
  }

  Future<void> deleteTask(String taskId) async {
    final index = _tasks.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      final task = _tasks.removeAt(index);
      _recentlyDeleted.add(task);

      await DatabaseService.deleteTask(taskId);
      await NotificationService.cancelTaskReminder(taskId);

      notifyListeners();

      // Auto-clear recently deleted after 10 seconds
      Future.delayed(const Duration(seconds: 10), () {
        _recentlyDeleted.removeWhere((t) => t.id == taskId);
      });
    }
  }

  Future<void> undoDeleteTask() async {
    if (_recentlyDeleted.isNotEmpty) {
      final task = _recentlyDeleted.removeLast();
      _tasks.add(task);
      await DatabaseService.addTask(task);

      if (task.dueDate != null && !task.isCompleted) {
        await NotificationService.scheduleTaskReminder(task);
      }

      notifyListeners();
    }
  }

  Future<void> toggleTaskStar(String taskId) async {
    final index = _tasks.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      final task = _tasks[index];
      final updatedTask = task.copyWith(isStarred: !task.isStarred);

      _tasks[index] = updatedTask;
      await DatabaseService.updateTask(updatedTask);
      notifyListeners();
    }
  }

  void setFilter(TaskFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  void reorderTasks(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final filteredTasks = tasks;
    final task = filteredTasks.removeAt(oldIndex);
    filteredTasks.insert(newIndex, task);

    // Update the order in the main tasks list
    // This is a simplified reordering - in a real app you might want
    // to store explicit order values
    notifyListeners();
  }

  List<Task> getTasksForDate(DateTime date) {
    return _tasks.where((task) {
      if (task.dueDate == null) return false;
      return task.dueDate!.year == date.year &&
          task.dueDate!.month == date.month &&
          task.dueDate!.day == date.day;
    }).toList();
  }

  Map<String, int> getTaskStats() {
    return {
      'total': _tasks.length,
      'completed': _tasks.where((task) => task.isCompleted).length,
      'pending': _tasks.where((task) => !task.isCompleted).length,
      'overdue': _tasks
          .where((task) => task.isOverdue && !task.isCompleted)
          .length,
      'today': _tasks
          .where((task) => task.isDueToday && !task.isCompleted)
          .length,
    };
  }
}

enum TaskFilter { today, all, completed, overdue, upcoming, starred }
