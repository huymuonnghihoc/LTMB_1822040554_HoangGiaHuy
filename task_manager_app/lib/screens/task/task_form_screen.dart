import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/task_model.dart';
import '../../services/task_service.dart';

class TaskFormScreen extends StatefulWidget {
  final TaskModel? task;

  const TaskFormScreen({super.key, this.task});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String title;
  late String description;
  int priority = 2;
  String status = 'To do';
  DateTime? dueDate;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      final task = widget.task!;
      title = task.title;
      description = task.description;
      priority = task.priority;
      status = task.status;
      dueDate = task.dueDate;
    } else {
      title = '';
      description = '';
    }
  }

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

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Sửa Công Việc' : 'Tạo Công Việc'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.list), // Biểu tượng danh sách
          onPressed: () {
            Navigator.pushNamed(context, '/task-list');
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    initialValue: title,
                    decoration: InputDecoration(
                      labelText: 'Tiêu đề',
                      prefixIcon: Icon(Icons.title),
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) => val!.isEmpty ? 'Không được để trống' : null,
                    onSaved: (val) => title = val!,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: description,
                    decoration: InputDecoration(
                      labelText: 'Mô tả',
                      prefixIcon: Icon(Icons.description),
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    onSaved: (val) => description = val!,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: priority,
                          decoration: InputDecoration(
                            labelText: 'Độ ưu tiên',
                            prefixIcon: Icon(Icons.flag),
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            DropdownMenuItem(value: 1, child: Text('Thấp')),
                            DropdownMenuItem(value: 2, child: Text('Trung bình')),
                            DropdownMenuItem(value: 3, child: Text('Cao')),
                          ],
                          onChanged: (val) => setState(() => priority = val!),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: _getPriorityColor(priority),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: status,
                    decoration: InputDecoration(
                      labelText: 'Trạng thái',
                      prefixIcon: Icon(Icons.info_outline),
                      border: OutlineInputBorder(),
                    ),
                    items: ['To do', 'In progress', 'Done', 'Cancelled']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (val) => setState(() => status = val!),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                        initialDate: dueDate ?? DateTime.now(),
                      );
                      if (picked != null) setState(() => dueDate = picked);
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Hạn hoàn thành',
                        prefixIcon: Icon(Icons.date_range),
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        dueDate != null
                            ? '${dueDate!.day}/${dueDate!.month}/${dueDate!.year}'
                            : 'Chưa chọn',
                        style: TextStyle(
                          color: dueDate != null
                              ? Theme.of(context).textTheme.bodyMedium!.color
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: Icon(Icons.save),
                    label: Text('Lưu Công Việc'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();

                        final task = TaskModel(
                          id: widget.task?.id ?? const Uuid().v4(),
                          title: title,
                          description: description,
                          status: status,
                          priority: priority,
                          dueDate: dueDate,
                          createdAt: widget.task?.createdAt ?? DateTime.now(),
                          updatedAt: DateTime.now(),
                          assignedTo: null,
                          createdBy: 'giahuy2401',
                          category: null,
                          attachments: null,
                          completed: widget.task?.completed ?? false,
                        );

                        if (widget.task == null) {
                          await TaskService.insertTask(task);
                        } else {
                          await TaskService.updateTask(task);
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đã lưu công việc')),
                        );

                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
