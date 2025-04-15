import 'package:flutter/material.dart';
import 'package:goodbooks_flutter/base/NavBar.dart';
import 'package:goodbooks_flutter/pages/Login/ResetPasswordPage.dart';
import 'package:goodbooks_flutter/pages/Login/RegisterPage.dart';
import 'package:provider/provider.dart';
import 'package:goodbooks_flutter/provider/AuthProvider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            IconButton(
              icon: const Icon(Icons.arrow_back, size: 28),
              onPressed: () => Navigator.pop(context, false),
            ),
            const SizedBox(height: 20),
            const Text(
              "Welcome back to GoodBooks",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Silahkan masukkan data untuk login",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            
            // Email Input
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email/Phone",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Password Input
            TextField(
              controller: passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                ),
              ),
            ),
            const SizedBox(height: 30),
            
            // Sign In Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(54, 105, 201, 1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () => _login(context),
              child: const Text("Sign In"),
            ),
            const SizedBox(height: 20),
            
            // Forgot Password & Sign Up
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ResetPasswordPage()),
                  ),
                  child: const Text("Forgot Password"),
                ),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterPage()),
                  ),
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(color: Color.fromRGBO(54, 105, 201, 1)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _login(BuildContext context) async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // Validation
    if (email.isEmpty || password.isEmpty) {
      _showErrorSnackbar(context, "Email dan password harus diisi!");
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      _showErrorSnackbar(context, "Format email tidak valid!");
      return;
    }

    if (password.length < 6) {
      _showErrorSnackbar(context, "Password minimal 6 karakter!");
      return;
    }

    // Show loading
    _showLoadingSnackbar(context);

    try {
      // Call login method with email and password
      await Provider.of<AuthProvider>(context, listen: false).loginWithEmailAndPassword(email, password);
      
      // On success, navigate to NavBar
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const NavBar()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Remove loading snackbar
        _showErrorSnackbar(context, "Login gagal: ${e.toString()}");
      }
    }
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showLoadingSnackbar(BuildContext context) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please wait... Logging in..."),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }
}
