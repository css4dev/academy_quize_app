import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddUserScreen extends StatefulWidget {
  @override
  _AddUserScreenState createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> addUser() async {
    final response = await http.post(
      Uri.parse('https://sawa-aid.com/quizApp/add_user.php'),
      body: {
        'full_name': _nameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
      },
    );
    if (kDebugMode) {
      print("${response.body}Sssaa");
    }
    if (response.statusCode == 200) {
      Navigator.pop(context);
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'إضافة مستخدم',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'يرجى ملء التفاصيل لإضافة مستخدم جديد',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                _buildTextField(
                  controller: _nameController,
                  label: 'الاسم الكامل',
                  icon: Icons.person,
                  validator: (value) =>
                  value!.isEmpty ? 'الرجاء إدخال الاسم الكامل' : null,
                ),
                SizedBox(height: 10),
                _buildTextField(
                  controller: _emailController,
                  label: 'البريد الإلكتروني',
                  icon: Icons.email,
                  validator: (value) =>
                  value!.isEmpty ? 'الرجاء إدخال البريد الإلكتروني' : null,
                ),
                SizedBox(height: 10),
                _buildTextField(
                  controller: _passwordController,
                  label: 'كلمة المرور',
                  icon: Icons.lock,
                  obscureText: true,
                  validator: (value) =>
                  value!.isEmpty ? 'الرجاء إدخال كلمة المرور' : null,
                ),
                SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      addUser();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('تمت إضافة المستخدم بنجاح!'),
                        backgroundColor: Colors.teal,
                      ));
                    }
                  },
                  icon: Icon(Icons.add),
                  label: Text('إضافة مستخدم'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    textStyle: TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.teal),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: validator,
    );
  }}
