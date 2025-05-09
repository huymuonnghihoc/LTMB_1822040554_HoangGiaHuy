import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/task_model.dart';
import '../../services/task_service.dart';
import '../../widgets/task_item.dart';

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<TaskModel> tasks = [];
  List<TaskModel> filteredTasks = [];
  String username = '';
  bool isSearching = false;  // Biến để kiểm tra trạng thái tìm kiếm
  final TextEditingController _searchController = TextEditingController();
  bool isSorted = false; // Biến kiểm tra trạng thái sắp xếp
  bool isSortedDescending = false; // Biến kiểm tra chiều sắp xếp (tăng dần hay giảm dần)

  @override
  void initState() {
    super.initState();
    loadUsername();
    loadTasks();
  }

  Future<void> loadUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? 'Người dùng';
    });
  }

  Future<void> loadTasks() async {
    final taskList = await TaskService.getAllTasks();
    setState(() {
      tasks = taskList;
      filteredTasks = taskList; // Ban đầu hiển thị toàn bộ
    });
  }

  void _performSearch() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredTasks = tasks.where((task) {
        return task.title.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _resetSearch() {
    _searchController.clear();
    setState(() {
      filteredTasks = tasks;
    });
  }

  void _sortTasks() {
    setState(() {
      // Nếu đã sắp xếp, đảo ngược thứ tự danh sách
      if (isSorted) {
        if (isSortedDescending) {
          // Nếu đang sắp xếp theo chiều giảm, đổi lại sắp xếp theo chiều tăng
          filteredTasks.sort((a, b) => a.priority.compareTo(b.priority));
        } else {
          // Nếu đang sắp xếp theo chiều tăng, đổi lại sắp xếp theo chiều giảm
          filteredTasks.sort((a, b) => b.priority.compareTo(a.priority));
        }
      } else {
        // Lần đầu tiên sắp xếp, sắp xếp theo chiều giảm
        filteredTasks.sort((a, b) => b.priority.compareTo(a.priority));
      }

      // Đảo ngược trạng thái sắp xếp
      isSortedDescending = !isSortedDescending;
      isSorted = true;
    });
  }

  void _toggleSort() {
    setState(() {
      _sortTasks(); // Sắp xếp lại danh sách công việc khi nút sắp xếp được nhấn
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isSearching
            ? TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Nhập tiêu đề công việc...',
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 12),
          ),
          onChanged: (text) {
            _performSearch();
          },
        )
            : Text('Danh sách công việc'),
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (isSearching) {
                  _resetSearch(); // Hủy tìm kiếm
                  isSearching = false; // Đóng thanh tìm kiếm
                } else {
                  isSearching = true; // Mở thanh tìm kiếm
                }
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.sort),
            onPressed: _toggleSort, // Mở sắp xếp khi nhấn nút Sort
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Xin chào, $username!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: filteredTasks.isEmpty
                ? Center(child: Text('Không có công việc phù hợp'))
                : ListView.builder(
              itemCount: filteredTasks.length,
              itemBuilder: (_, index) {
                final task = filteredTasks[index];
                return Dismissible(
                  key: Key(task.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) async {
                    await TaskService.deleteTask(task.id);
                    await loadTasks();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Đã xóa công việc')),
                    );
                  },
                  child: TaskItem(
                    task: task,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/task-detail',
                        arguments: task,
                      ).then((_) => loadTasks());
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, '/task-form').then((_) => loadTasks());
        },
      ),
    );
  }
}
