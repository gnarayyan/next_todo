import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../providers/theme_provider.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const TaskCard({super.key, required this.task, this.onTap, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Dismissible(
        key: Key(task.id),
        background: _buildSwipeBackground(
          context,
          Colors.green,
          Icons.check,
          'Complete',
          Alignment.centerLeft,
        ),
        secondaryBackground: _buildSwipeBackground(
          context,
          Colors.red,
          Icons.delete,
          'Delete',
          Alignment.centerRight,
        ),
        onDismissed: (direction) {
          if (direction == DismissDirection.startToEnd) {
            taskProvider.toggleTaskCompletion(task.id);
          } else {
            taskProvider.deleteTask(task.id);
            _showUndoSnackBar(context, taskProvider);
          }
        },
        child: ListTile(
          onTap: onTap,
          onLongPress: onLongPress,
          contentPadding: const EdgeInsets.all(16),
          leading: _buildLeading(themeProvider, taskProvider),
          title: _buildTitle(context, themeProvider),
          subtitle: _buildSubtitle(context, themeProvider),
          trailing: _buildTrailing(themeProvider, taskProvider),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildLeading(ThemeProvider themeProvider, TaskProvider taskProvider) {
    return GestureDetector(
      onTap: () => taskProvider.toggleTaskCompletion(task.id),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: task.isCompleted
                ? Colors.green
                : themeProvider.getPriorityColor(
                    task.priority.name,
                    isDark: themeProvider.isDarkMode,
                  ),
            width: 2,
          ),
          color: task.isCompleted ? Colors.green : Colors.transparent,
        ),
        child: task.isCompleted
            ? const Icon(Icons.check, size: 16, color: Colors.white)
            : null,
      ),
    );
  }

  Widget _buildTitle(BuildContext context, ThemeProvider themeProvider) {
    return Text(
      task.title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        decoration: task.isCompleted ? TextDecoration.lineThrough : null,
        color: task.isCompleted
            ? Theme.of(context).colorScheme.onSurface.withOpacity(0.6)
            : null,
        fontWeight: FontWeight.w600,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildSubtitle(BuildContext context, ThemeProvider themeProvider) {
    final widgets = <Widget>[];

    if (task.description != null && task.description!.isNotEmpty) {
      widgets.add(
        Text(
          task.description!,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }

    if (task.dueDate != null) {
      final timeText = _getTimeText();
      widgets.add(
        Padding(
          padding: EdgeInsets.only(top: widgets.isNotEmpty ? 4 : 0),
          child: Row(
            children: [
              Icon(Icons.access_time, size: 14, color: _getTimeColor(context)),
              const SizedBox(width: 4),
              Text(
                timeText,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: _getTimeColor(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return widgets.isNotEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widgets,
          )
        : const SizedBox.shrink();
  }

  Widget _buildTrailing(
    ThemeProvider themeProvider,
    TaskProvider taskProvider,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: themeProvider.getPriorityColor(
              task.priority.name,
              isDark: themeProvider.isDarkMode,
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => taskProvider.toggleTaskStar(task.id),
          child: Icon(
            task.isStarred ? Icons.star : Icons.star_border,
            color: task.isStarred ? Colors.amber : Colors.grey,
            size: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildSwipeBackground(
    BuildContext context,
    Color color,
    IconData icon,
    String text,
    Alignment alignment,
  ) {
    return Container(
      color: color,
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeText() {
    if (task.dueDate == null) return '';

    final now = DateTime.now();
    final dueDate = task.dueDate!;

    if (task.isDueToday) {
      return 'Today ${_formatTime(dueDate)}';
    } else if (task.isDueTomorrow) {
      return 'Tomorrow ${_formatTime(dueDate)}';
    } else if (task.isOverdue) {
      final days = now.difference(dueDate).inDays;
      return 'Overdue by $days day${days > 1 ? 's' : ''}';
    } else {
      final days = dueDate.difference(now).inDays;
      if (days <= 7) {
        return 'In $days day${days > 1 ? 's' : ''}';
      } else {
        return '${dueDate.day}/${dueDate.month}/${dueDate.year}';
      }
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  Color _getTimeColor(BuildContext context) {
    if (task.isOverdue) {
      return Colors.red;
    } else if (task.isDueToday) {
      return Colors.orange;
    }
    return Theme.of(context).colorScheme.primary;
  }

  void _showUndoSnackBar(BuildContext context, TaskProvider taskProvider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Task "${task.title}" deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => taskProvider.undoDeleteTask(),
        ),
        duration: const Duration(seconds: 10),
      ),
    );
  }
}
