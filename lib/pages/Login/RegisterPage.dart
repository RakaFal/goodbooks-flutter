import 'package:flutter/material.dart';
import 'VerificationPage.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController emailPhoneController = TextEditingController();

  void _register() {
    String input = emailPhoneController.text.trim();
    if (input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Masukkan email atau nomor HP!")),
      );
      return;
    }

    // TODO: Integrasi ke backend untuk register

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Kode verifikasi dikirim ke $input")),
    );

    // Pindah ke halaman OTP Verification
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VerificationPage(
          phoneNumber: input, 
          source: "register",
        ),
      ),
    );
  }

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
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(height: 20),
            const Text(
              "Register Account",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Masukkan Email/ No. HP untuk mendaftar",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // Input Field
            TextField(
              controller: emailPhoneController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "Email/ Phone",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Continue Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(54, 105, 201, 1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: _register,
              child: const Text("Continue"),
            ),

            const SizedBox(height: 20),

            // Sign In Option
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Have an Account? "),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // Kembali ke Login
                  },
                  child: const Text(
                    "Sign In",
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
}
