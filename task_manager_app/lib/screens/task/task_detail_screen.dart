import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/task_model.dart';
import '../../services/task_service.dart';

class TaskDetailScreen extends StatelessWidget {
  final TaskModel task;

  const TaskDetailScreen({super.key, required this.task});

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy • HH:mm').format(date);
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[700]),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.grey[800])),
                const SizedBox(height: 2),
                Text(value,
                    style: TextStyle(color: Colors.grey[900], fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final priorityColor = _getPriorityColor(task.priority);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết công việc'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề
            Text(
              task.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),

            // Trạng thái và ưu tiên
            Row(
              children: [
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    task.status,
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: priorityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    ['Thấp', 'Trung bình', 'Cao'][task.priority - 1],
                    style: TextStyle(
                        color: priorityColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Nội dung chi tiết
            _buildInfoRow(Icons.description, 'Mô tả', task.description),
            _buildInfoRow(Icons.calendar_today, 'Ngày tạo',
                _formatDate(task.createdAt)),
            if (task.dueDate != null)
              _buildInfoRow(
                  Icons.access_time, 'Hạn hoàn thành', _formatDate(task.dueDate!)),

            if (task.attachments != null && task.attachments!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('📎 Tệp đính kèm:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: task.attachments!
                    .map((f) => Chip(label: Text(f)))
                    .toList(),
              ),
            ],

            const SizedBox(height: 30),

            // Nút hành động
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('Chỉnh sửa'),
                    onPressed: () {
                      Navigator.pushNamed(context, '/task-form',
                          arguments: task);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(task.completed
                        ? Icons.cancel
                        : Icons.check_circle_outline),
                    label: Text(task.completed
                        ? 'Bỏ đánh dấu hoàn thành'
                        : 'Hoàn thành'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      task.completed ? Colors.grey : Colors.green,
                    ),
                    onPressed: () async {
                      final updatedTask = task.copyWith(
                        completed: !task.completed,
                        status: task.completed ? 'To do' : 'Done',
                        updatedAt: DateTime.now(),
                      );
                      await TaskService.updateTask(updatedTask);
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
