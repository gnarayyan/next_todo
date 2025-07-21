import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../models/task.dart';
import '../../services/database_service.dart';
import '../../services/notification_service.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final Uuid _uuid = const Uuid();

  TaskBloc() : super(const TaskState()) {
    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
    on<UpdateTask>(_onUpdateTask);
    on<ToggleTaskCompletion>(_onToggleTaskCompletion);
    on<DeleteTask>(_onDeleteTask);
    on<UndoDeleteTask>(_onUndoDeleteTask);
    on<ToggleTaskStar>(_onToggleTaskStar);
    on<SetTaskFilter>(_onSetTaskFilter);
    on<SetSearchQuery>(_onSetSearchQuery);
    on<ClearSearch>(_onClearSearch);
    on<ReorderTasks>(_onReorderTasks);
  }

  void _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) {
    emit(state.copyWith(isLoading: true));
    try {
      final tasks = DatabaseService.getAllTasks();
      emit(state.copyWith(tasks: tasks, isLoading: false));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  void _onAddTask(AddTask event, Emitter<TaskState> emit) async {
    try {
      final task = Task(
        id: _uuid.v4(),
        title: event.title,
        description: event.description,
        dueDate: event.dueDate,
        priority: event.priority,
        isStarred: event.isStarred,
        createdAt: DateTime.now(),
      );

      final updatedTasks = List<Task>.from(state.tasks)..add(task);
      emit(state.copyWith(tasks: updatedTasks));

      await DatabaseService.addTask(task);

      if (event.dueDate != null) {
        await NotificationService.scheduleTaskReminder(task);
      }
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  void _onUpdateTask(UpdateTask event, Emitter<TaskState> emit) async {
    try {
      final updatedTasks = List<Task>.from(state.tasks);
      final index = updatedTasks.indexWhere((task) => task.id == event.task.id);

      if (index != -1) {
        updatedTasks[index] = event.task;
        emit(state.copyWith(tasks: updatedTasks));

        await DatabaseService.updateTask(event.task);

        // Update notification
        await NotificationService.cancelTaskReminder(event.task.id);
        if (event.task.dueDate != null && !event.task.isCompleted) {
          await NotificationService.scheduleTaskReminder(event.task);
        }
      }
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  void _onToggleTaskCompletion(
    ToggleTaskCompletion event,
    Emitter<TaskState> emit,
  ) async {
    try {
      final updatedTasks = List<Task>.from(state.tasks);
      final index = updatedTasks.indexWhere((task) => task.id == event.taskId);

      if (index != -1) {
        final task = updatedTasks[index];
        final updatedTask = task.copyWith(
          isCompleted: !task.isCompleted,
          completedAt: !task.isCompleted ? DateTime.now() : null,
        );

        updatedTasks[index] = updatedTask;
        emit(state.copyWith(tasks: updatedTasks));

        await DatabaseService.updateTask(updatedTask);

        if (updatedTask.isCompleted) {
          await NotificationService.cancelTaskReminder(event.taskId);
          await NotificationService.showTaskCompletedNotification(
            updatedTask.title,
          );
        } else if (updatedTask.dueDate != null) {
          await NotificationService.scheduleTaskReminder(updatedTask);
        }
      }
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  void _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    try {
      final updatedTasks = List<Task>.from(state.tasks);
      final index = updatedTasks.indexWhere((task) => task.id == event.taskId);

      if (index != -1) {
        final task = updatedTasks.removeAt(index);
        final updatedRecentlyDeleted = List<Task>.from(state.recentlyDeleted)
          ..add(task);

        emit(
          state.copyWith(
            tasks: updatedTasks,
            recentlyDeleted: updatedRecentlyDeleted,
          ),
        );

        await DatabaseService.deleteTask(event.taskId);
        await NotificationService.cancelTaskReminder(event.taskId);

        // Auto-clear recently deleted after 10 seconds
        Future.delayed(const Duration(seconds: 10), () {
          final currentRecentlyDeleted = List<Task>.from(state.recentlyDeleted);
          currentRecentlyDeleted.removeWhere((t) => t.id == event.taskId);
          emit(state.copyWith(recentlyDeleted: currentRecentlyDeleted));
        });
      }
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  void _onUndoDeleteTask(UndoDeleteTask event, Emitter<TaskState> emit) async {
    try {
      final updatedRecentlyDeleted = List<Task>.from(state.recentlyDeleted);

      if (updatedRecentlyDeleted.isNotEmpty) {
        final task = updatedRecentlyDeleted.removeLast();
        final updatedTasks = List<Task>.from(state.tasks)..add(task);

        emit(
          state.copyWith(
            tasks: updatedTasks,
            recentlyDeleted: updatedRecentlyDeleted,
          ),
        );

        await DatabaseService.addTask(task);

        if (task.dueDate != null && !task.isCompleted) {
          await NotificationService.scheduleTaskReminder(task);
        }
      }
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  void _onToggleTaskStar(ToggleTaskStar event, Emitter<TaskState> emit) async {
    try {
      final updatedTasks = List<Task>.from(state.tasks);
      final index = updatedTasks.indexWhere((task) => task.id == event.taskId);

      if (index != -1) {
        final task = updatedTasks[index];
        final updatedTask = task.copyWith(isStarred: !task.isStarred);

        updatedTasks[index] = updatedTask;
        emit(state.copyWith(tasks: updatedTasks));

        await DatabaseService.updateTask(updatedTask);
      }
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  void _onSetTaskFilter(SetTaskFilter event, Emitter<TaskState> emit) {
    emit(state.copyWith(currentFilter: event.filter));
  }

  void _onSetSearchQuery(SetSearchQuery event, Emitter<TaskState> emit) {
    emit(state.copyWith(searchQuery: event.query));
  }

  void _onClearSearch(ClearSearch event, Emitter<TaskState> emit) {
    emit(state.copyWith(searchQuery: ''));
  }

  void _onReorderTasks(ReorderTasks event, Emitter<TaskState> emit) {
    // This is a simplified reordering - in a real app you might want
    // to store explicit order values
    emit(state); // For now, just emit the current state
  }
}
