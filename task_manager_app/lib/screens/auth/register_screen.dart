import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../models/user_model.dart';
import '../../data/user_dao.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String username = '';
  String email = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng ký tài khoản'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Tên đăng nhập
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Tên đăng nhập',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                      value!.isEmpty ? 'Không được để trống' : null,
                      onSaved: (value) => username = value!,
                    ),
                    const SizedBox(height: 20),
                    // Email
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) =>
                      value!.isEmpty ? 'Vui lòng nhập email' : null,
                      onSaved: (value) => email = value!,
                    ),
                    const SizedBox(height: 20),
                    // Mật khẩu
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Mật khẩu',
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: (value) =>
                      value!.length < 6 ? 'Tối thiểu 6 ký tự' : null,
                      onSaved: (value) => password = value!,
                    ),
                    const SizedBox(height: 20),
                    // Nút đăng ký
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.blueAccent,
                      ),
                      onPressed: () async {
                        final isValid = _formKey.currentState!.validate();
                        if (isValid) {
                          _formKey.currentState!.save();

                          final userDao = UserDao();

                          // Kiểm tra username đã tồn tại chưa
                          final existingUser =
                          await userDao.getUserByUsername(username);
                          if (existingUser != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Tên đăng nhập đã tồn tại')),
                            );
                            return;
                          }

                          // Tạo người dùng mới
                          final newUser = UserModel(
                            id: const Uuid().v4(),
                            username: username,
                            email: email,
                            password: password,
                            avatar: null,
                            createdAt: DateTime.now(),
                            lastActive: DateTime.now(),
                          );

                          await userDao.insertUser(newUser);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Đăng ký thành công')),
                          );

                          Navigator.pushReplacementNamed(context, '/login');
                        }
                      },
                      child: const Text('Đăng ký'),
                    ),
                    const SizedBox(height: 12),
                    // Liên kết quay lại trang đăng nhập
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: const Text(
                        'Đã có tài khoản? Đăng nhập',
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
