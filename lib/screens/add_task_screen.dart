import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../providers/theme_provider.dart';

class AddTaskScreen extends StatefulWidget {
  final Task? taskToEdit;

  const AddTaskScreen({super.key, this.taskToEdit});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  TaskPriority _selectedPriority = TaskPriority.medium;
  bool _isStarred = false;

  @override
  void initState() {
    super.initState();
    if (widget.taskToEdit != null) {
      _populateFields();
    }
  }

  void _populateFields() {
    final task = widget.taskToEdit!;
    _titleController.text = task.title;
    _descriptionController.text = task.description ?? '';
    _selectedDate = task.dueDate;
    _selectedTime = task.dueDate != null
        ? TimeOfDay.fromDateTime(task.dueDate!)
        : null;
    _selectedPriority = task.priority;
    _isStarred = task.isStarred;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.taskToEdit != null;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: Provider.of<ThemeProvider>(context).backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(isEditing),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTitleField(),
                        const SizedBox(height: 20),
                        _buildDescriptionField(),
                        const SizedBox(height: 20),
                        _buildDateTimeSection(),
                        const SizedBox(height: 20),
                        _buildPrioritySection(),
                        const SizedBox(height: 20),
                        _buildOptionsSection(),
                        const SizedBox(height: 40),
                        _buildActionButtons(isEditing),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(bool isEditing) {
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
            isEditing ? 'Edit Task' : 'Add Task',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0);
  }

  Widget _buildTitleField() {
    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Task Title *',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Enter task title',
                prefixIcon: const Icon(Icons.task),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a task title';
                }
                return null;
              },
              autofocus: true,
            ),
          ],
        )
        .animate()
        .fadeIn(delay: 100.ms, duration: 500.ms)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildDescriptionField() {
    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Description',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                hintText: 'Add task description (optional)',
                prefixIcon: const Icon(Icons.notes),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 3,
            ),
          ],
        )
        .animate()
        .fadeIn(delay: 200.ms, duration: 500.ms)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildDateTimeSection() {
    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Due Date & Time',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildDatePicker()),
                const SizedBox(width: 12),
                Expanded(child: _buildTimePicker()),
              ],
            ),
            if (_selectedDate != null && _selectedTime != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getFormattedDateTime(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: _clearDateTime,
                      icon: Icon(
                        Icons.clear,
                        size: 16,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        )
        .animate()
        .fadeIn(delay: 300.ms, duration: 500.ms)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildDatePicker() {
    return OutlinedButton.icon(
      onPressed: _selectDate,
      icon: const Icon(Icons.calendar_today),
      label: Text(
        _selectedDate != null
            ? DateFormat('MMM dd, yyyy').format(_selectedDate!)
            : 'Select Date',
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
    );
  }

  Widget _buildTimePicker() {
    return OutlinedButton.icon(
      onPressed: _selectTime,
      icon: const Icon(Icons.access_time),
      label: Text(
        _selectedTime != null ? _selectedTime!.format(context) : 'Select Time',
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
    );
  }

  Widget _buildPrioritySection() {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Priority',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Row(
              children: TaskPriority.values.map((priority) {
                final isSelected = _selectedPriority == priority;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: priority != TaskPriority.values.last ? 8 : 0,
                    ),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedPriority = priority),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? themeProvider.getPriorityColor(
                                  priority.name,
                                  isDark: themeProvider.isDarkMode,
                                )
                              : Theme.of(context).colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: themeProvider.getPriorityColor(
                              priority.name,
                              isDark: themeProvider.isDarkMode,
                            ),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? Colors.white
                                    : themeProvider.getPriorityColor(
                                        priority.name,
                                        isDark: themeProvider.isDarkMode,
                                      ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              priority.name.toUpperCase(),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: isSelected
                                        ? Colors.white
                                        : Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        )
        .animate()
        .fadeIn(delay: 400.ms, duration: 500.ms)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildOptionsSection() {
    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Options',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Card(
              child: SwitchListTile(
                title: const Text('Add to Focus'),
                subtitle: const Text('Star this task for quick access'),
                value: _isStarred,
                onChanged: (value) => setState(() => _isStarred = value),
                secondary: Icon(
                  _isStarred ? Icons.star : Icons.star_border,
                  color: _isStarred ? Colors.amber : null,
                ),
              ),
            ),
          ],
        )
        .animate()
        .fadeIn(delay: 500.ms, duration: 500.ms)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildActionButtons(bool isEditing) {
    return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _saveTask,
                child: Text(isEditing ? 'Update Task' : 'Create Task'),
              ),
            ),
          ],
        )
        .animate()
        .fadeIn(delay: 600.ms, duration: 500.ms)
        .slideY(begin: 0.2, end: 0);
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );

    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  void _clearDateTime() {
    setState(() {
      _selectedDate = null;
      _selectedTime = null;
    });
  }

  String _getFormattedDateTime() {
    if (_selectedDate == null) return '';

    final dateStr = DateFormat('EEEE, MMM dd, yyyy').format(_selectedDate!);
    final timeStr = _selectedTime?.format(context) ?? '';

    return timeStr.isNotEmpty ? '$dateStr at $timeStr' : dateStr;
  }

  DateTime? _getCombinedDateTime() {
    if (_selectedDate == null) return null;

    if (_selectedTime != null) {
      return DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
    }

    return _selectedDate;
  }

  void _saveTask() {
    if (!_formKey.currentState!.validate()) return;

    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final dueDateTime = _getCombinedDateTime();

    if (widget.taskToEdit != null) {
      // Update existing task
      final updatedTask = widget.taskToEdit!.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        dueDate: dueDateTime,
        priority: _selectedPriority,
        isStarred: _isStarred,
      );

      taskProvider.updateTask(updatedTask);
    } else {
      // Create new task
      taskProvider.addTask(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        dueDate: dueDateTime,
        priority: _selectedPriority,
        isStarred: _isStarred,
      );
    }

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.taskToEdit != null
              ? 'Task updated successfully!'
              : 'Task created successfully!',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }
}
