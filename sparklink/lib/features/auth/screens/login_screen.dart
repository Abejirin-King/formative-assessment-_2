import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool isLogin = true;
  String selectedRole = 'student';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("SparkLink", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const Text("ALU Ecosystem", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 40),

            if (!isLogin)
              TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Full Name")),
            
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: "Email")),
            TextField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: "Password")),

            if (!isLogin)
              DropdownButton<String>(
                value: selectedRole,
                items: const [
                  DropdownMenuItem(value: 'student', child: Text("Student")),
                  DropdownMenuItem(value: 'startup', child: Text("Startup")),
                ],
                onChanged: (v) => setState(() => selectedRole = v!),
              ),

            const SizedBox(height: 20),
            ElevatedButton(
  onPressed: () async {
    try {
      final repo = ref.read(authRepositoryProvider);
      if (isLogin) {
        await repo.signIn(_emailController.text, _passwordController.text);
      } else {
        await repo.signUp(
          email: _emailController.text,
          password: _passwordController.text,
          name: _nameController.text,
          role: selectedRole,
        );
      }
      if (context.mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  },
  child: Text(isLogin ? "Login" : "Sign Up"),
),
            TextButton(
              onPressed: () => setState(() => isLogin = !isLogin),
              child: Text(isLogin ? "Create Account" : "Already have account? Login"),
            ),
          ],
        ),
      ),
    );
  }
}