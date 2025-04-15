import 'package:flutter/material.dart';
import 'VerificationPage.dart'; // Import halaman verifikasi

class ResetPasswordPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();

  ResetPasswordPage({super.key});

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
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 20),
            const Text(
              "Reset Password",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Masukkan Email/ No. Hp akun untuk mereset kata sandi Anda",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),

            // Input Email/Phone
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "Email/ Phone",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Reset Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(54, 105, 201, 1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                _resetPassword(context);
              },
              child: const Text("Reset"),
            ),
          ],
        ),
      ),
    );
  }

  void _resetPassword(BuildContext context) {
    String input = emailController.text.trim();

    if (input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harap masukkan email atau nomor HP!")),
      );
      return;
    }

    // Pastikan input adalah email atau nomor telepon yang valid
    bool isValidEmail = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(input);
    bool isValidPhone = RegExp(r"^\d+$").hasMatch(input); // Harus angka saja

    if (!isValidEmail && !isValidPhone) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Masukkan email atau nomor telepon yang valid!")),
      );
      return;
    }

    // Kirim ke halaman verifikasi (anggap input adalah nomor telepon)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VerificationPage(phoneNumber: input, source: "reset_password"),
      ),
    );
  }
}
