import 'package:flutter/material.dart';

class LoginDialog extends StatelessWidget {
  final Function(BuildContext) onLoginPressed;
  const LoginDialog({super.key, required this.onLoginPressed});

  // Style constants
  static const _titleStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 20);
  static const _subtitleStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.w600);
  static const _bodyStyle = TextStyle(fontSize: 16, color: Colors.grey);
  static const _buttonStyle = TextStyle(fontSize: 16, color: Colors.white);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Login Account", style: _titleStyle),
            const SizedBox(height: 15),
            const Text("👋", style: TextStyle(fontSize: 50)),
            const SizedBox(height: 15),
            const Text(
              "Anda perlu masuk terlebih dahulu",
              style: _subtitleStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              "Silakan login/register terlebih dahulu untuk melakukan transaksi",
              style: _bodyStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => onLoginPressed(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(54, 105, 201, 1),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text("Login", style: _buttonStyle),
              ),
            ),
          ],
        ),
      ),
    );
  }
}