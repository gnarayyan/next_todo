import 'package:equatable/equatable.dart';
import '../../models/task.dart';
import 'task_event.dart';

class TaskState extends Equatable {
  final List<Task> tasks;
  final List<Task> recentlyDeleted;
  final TaskFilter currentFilter;
  final String searchQuery;
  final bool isLoading;
  final String? error;

  const TaskState({
    this.tasks = const [],
    this.recentlyDeleted = const [],
    this.currentFilter = TaskFilter.today,
    this.searchQuery = '',
    this.isLoading = false,
    this.error,
  });

  TaskState copyWith({
    List<Task>? tasks,
    List<Task>? recentlyDeleted,
    TaskFilter? currentFilter,
    String? searchQuery,
    bool? isLoading,
    String? error,
  }) {
    return TaskState(
      tasks: tasks ?? this.tasks,
      recentlyDeleted: recentlyDeleted ?? this.recentlyDeleted,
      currentFilter: currentFilter ?? this.currentFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  List<Task> get filteredTasks {
    List<Task> filteredTasks = [];

    switch (currentFilter) {
      case TaskFilter.today:
        filteredTasks = tasks
            .where((task) => task.isDueToday && !task.isCompleted)
            .toList();
        break;
      case TaskFilter.all:
        filteredTasks = tasks.where((task) => !task.isCompleted).toList();
        break;
      case TaskFilter.completed:
        filteredTasks = tasks.where((task) => task.isCompleted).toList();
        break;
      case TaskFilter.overdue:
        filteredTasks = tasks
            .where((task) => task.isOverdue && !task.isCompleted)
            .toList();
        break;
      case TaskFilter.upcoming:
        filteredTasks = tasks
            .where(
              (task) =>
                  task.dueDate != null &&
                  task.dueDate!.isAfter(DateTime.now()) &&
                  !task.isCompleted,
            )
            .toList();
        break;
      case TaskFilter.starred:
        filteredTasks = tasks
            .where((task) => task.isStarred && !task.isCompleted)
            .toList();
        break;
    }

    if (searchQuery.isNotEmpty) {
      filteredTasks = filteredTasks
          .where(
            (task) =>
                task.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
                (task.description?.toLowerCase().contains(
                      searchQuery.toLowerCase(),
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

  int get todayTasksCount =>
      tasks.where((task) => task.isDueToday && !task.isCompleted).length;

  int get overdueTasksCount =>
      tasks.where((task) => task.isOverdue && !task.isCompleted).length;

  int get completedTasksCount => tasks.where((task) => task.isCompleted).length;

  List<Task> get focusTasks => tasks
      .where((task) => task.isStarred && !task.isCompleted)
      .take(3)
      .toList();

  List<Task> getTasksForDate(DateTime date) {
    return tasks.where((task) {
      if (task.dueDate == null) return false;
      return task.dueDate!.year == date.year &&
          task.dueDate!.month == date.month &&
          task.dueDate!.day == date.day;
    }).toList();
  }

  Map<String, int> get taskStats {
    return {
      'total': tasks.length,
      'completed': tasks.where((task) => task.isCompleted).length,
      'pending': tasks.where((task) => !task.isCompleted).length,
      'overdue': tasks
          .where((task) => task.isOverdue && !task.isCompleted)
          .length,
      'today': tasks
          .where((task) => task.isDueToday && !task.isCompleted)
          .length,
    };
  }

  @override
  List<Object?> get props => [
    tasks,
    recentlyDeleted,
    currentFilter,
    searchQuery,
    isLoading,
    error,
  ];
}
