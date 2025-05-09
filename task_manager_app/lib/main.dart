import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/task/task_list_screen.dart';
import 'screens/task/task_form_screen.dart';
import 'screens/task/task_detail_screen.dart';
import 'models/task_model.dart';

void main() {
  runApp(const TaskManagerApp());
}

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Task Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      initialRoute: '/login',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case '/register':
            return MaterialPageRoute(builder: (_) => const RegisterScreen());
          case '/task-list':
            return MaterialPageRoute(builder: (_) => TaskListScreen());
          case '/task-form':
            final task = settings.arguments as TaskModel?;
            return MaterialPageRoute(
              builder: (_) => TaskFormScreen(task: task),
            );
          case '/task-detail':
            final task = settings.arguments as TaskModel;
            return MaterialPageRoute(
              builder: (_) => TaskDetailScreen(task: task),
            );
          default:
            return MaterialPageRoute(
              builder: (_) => const Scaffold(
                body: Center(child: Text('404 - Không tìm thấy trang')),
              ),
            );
        }
      },
    );
  }
}
