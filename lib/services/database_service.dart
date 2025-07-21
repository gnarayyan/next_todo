import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';

class DatabaseService {
  static const String _taskBoxName = 'tasks';
  static const String _settingsBoxName = 'settings';

  static Box<Task>? _taskBox;
  static Box? _settingsBox;

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(TaskAdapter());
    Hive.registerAdapter(TaskPriorityAdapter());

    // Open boxes
    _taskBox = await Hive.openBox<Task>(_taskBoxName);
    _settingsBox = await Hive.openBox(_settingsBoxName);
  }

  static Box<Task> get taskBox {
    if (_taskBox == null) {
      throw Exception(
        'Database not initialized. Call DatabaseService.init() first.',
      );
    }
    return _taskBox!;
  }

  static Box get settingsBox {
    if (_settingsBox == null) {
      throw Exception(
        'Database not initialized. Call DatabaseService.init() first.',
      );
    }
    return _settingsBox!;
  }

  // Task operations
  static Future<void> addTask(Task task) async {
    await taskBox.put(task.id, task);
  }

  static Future<void> updateTask(Task task) async {
    await taskBox.put(task.id, task);
  }

  static Future<void> deleteTask(String taskId) async {
    await taskBox.delete(taskId);
  }

  static List<Task> getAllTasks() {
    return taskBox.values.toList();
  }

  static List<Task> getTodayTasks() {
    final now = DateTime.now();
    return taskBox.values.where((task) {
      if (task.dueDate == null) return false;
      return task.dueDate!.year == now.year &&
          task.dueDate!.month == now.month &&
          task.dueDate!.day == now.day;
    }).toList();
  }

  static List<Task> getUpcomingTasks() {
    final now = DateTime.now();
    return taskBox.values.where((task) {
      if (task.dueDate == null) return false;
      return task.dueDate!.isAfter(now) && !task.isCompleted;
    }).toList();
  }

  static List<Task> getOverdueTasks() {
    final now = DateTime.now();
    return taskBox.values.where((task) {
      if (task.dueDate == null || task.isCompleted) return false;
      return task.dueDate!.isBefore(now);
    }).toList();
  }

  static List<Task> getCompletedTasks() {
    return taskBox.values.where((task) => task.isCompleted).toList();
  }

  static List<Task> getPendingTasks() {
    return taskBox.values.where((task) => !task.isCompleted).toList();
  }

  // Settings operations
  static Future<void> saveSetting(String key, dynamic value) async {
    await settingsBox.put(key, value);
  }

  static T? getSetting<T>(String key, {T? defaultValue}) {
    return settingsBox.get(key, defaultValue: defaultValue) as T?;
  }

  static bool get isDarkMode {
    return getSetting('isDarkMode', defaultValue: false) ?? false;
  }

  static Future<void> setDarkMode(bool value) async {
    await saveSetting('isDarkMode', value);
  }

  static String get selectedLanguage {
    return getSetting('selectedLanguage', defaultValue: 'en') ?? 'en';
  }

  static Future<void> setSelectedLanguage(String languageCode) async {
    await saveSetting('selectedLanguage', languageCode);
  }

  static bool get notificationsEnabled {
    return getSetting('notificationsEnabled', defaultValue: true) ?? true;
  }

  static Future<void> setNotificationsEnabled(bool value) async {
    await saveSetting('notificationsEnabled', value);
  }
}
