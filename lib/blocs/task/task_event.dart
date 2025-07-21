import 'package:equatable/equatable.dart';
import '../../models/task.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

class LoadTasks extends TaskEvent {}

class AddTask extends TaskEvent {
  final String title;
  final String? description;
  final DateTime? dueDate;
  final TaskPriority priority;
  final bool isStarred;

  const AddTask({
    required this.title,
    this.description,
    this.dueDate,
    this.priority = TaskPriority.medium,
    this.isStarred = false,
  });

  @override
  List<Object?> get props => [title, description, dueDate, priority, isStarred];
}

class UpdateTask extends TaskEvent {
  final Task task;

  const UpdateTask(this.task);

  @override
  List<Object> get props => [task];
}

class ToggleTaskCompletion extends TaskEvent {
  final String taskId;

  const ToggleTaskCompletion(this.taskId);

  @override
  List<Object> get props => [taskId];
}

class DeleteTask extends TaskEvent {
  final String taskId;

  const DeleteTask(this.taskId);

  @override
  List<Object> get props => [taskId];
}

class UndoDeleteTask extends TaskEvent {}

class ToggleTaskStar extends TaskEvent {
  final String taskId;

  const ToggleTaskStar(this.taskId);

  @override
  List<Object> get props => [taskId];
}

class SetTaskFilter extends TaskEvent {
  final TaskFilter filter;

  const SetTaskFilter(this.filter);

  @override
  List<Object> get props => [filter];
}

class SetSearchQuery extends TaskEvent {
  final String query;

  const SetSearchQuery(this.query);

  @override
  List<Object> get props => [query];
}

class ClearSearch extends TaskEvent {}

class ReorderTasks extends TaskEvent {
  final int oldIndex;
  final int newIndex;

  const ReorderTasks(this.oldIndex, this.newIndex);

  @override
  List<Object> get props => [oldIndex, newIndex];
}

enum TaskFilter { today, all, completed, overdue, upcoming, starred }
