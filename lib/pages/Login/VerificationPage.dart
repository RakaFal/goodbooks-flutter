import 'package:flutter/material.dart';
import 'ProfilePasswordPage.dart';
import 'UpdatePasswordPage.dart';
import 'package:provider/provider.dart';
import 'package:goodbooks_flutter/provider/AuthProvider.dart'; 

class VerificationPage extends StatefulWidget {
  final String phoneNumber;
  final String source; // Tambahkan source sebagai parameter wajib

  const VerificationPage({super.key, required this.phoneNumber, required this.source});

  @override
  _VerificationPageState createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  List<TextEditingController> otpControllers =
      List.generate(6, (index) => TextEditingController()); 
  int countdown = 185; 
  bool canResend = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    Future.delayed(Duration(seconds: 1), () {
      if (countdown > 0) {
        setState(() {
          countdown--;
        });
        _startCountdown();
      } else {
        setState(() {
          canResend = true;
        });
      }
    });
  }

  void _verifyOTP() async {
    String otpCode = otpControllers.map((controller) => controller.text).join();
    if (otpCode.length == 6) { // Ubah menjadi 6
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      try {
        await authProvider.verifyOTP(otpCode, widget.phoneNumber);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Kode OTP berhasil diverifikasi!")),
        );

        // Pindah ke halaman yang sesuai berdasarkan source
        if (widget.source == "register") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfilePasswordPage()),
          );
        } else if (widget.source == "reset_password") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UpdatePasswordPage()),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Verifikasi gagal: ${e.toString()}")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Harap isi semua kotak OTP!")),
      );
    }
  }

  void _resendOTP() {
    setState(() {
      countdown = 185;
      canResend = false;
    });
    _startCountdown();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Kode OTP telah dikirim ulang!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    String maskedPhone = widget.phoneNumber;
    if (maskedPhone.length >= 10) {
      maskedPhone = widget.phoneNumber.replaceRange(4, 10, "******");
    }

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
              "Verification",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Kami telah mengirimkan kode verifikasi ke\n$maskedPhone ",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),

            // OTP Input
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) { 
                return SizedBox(
                  width: 50,
                  child: TextField(
                    controller: otpControllers[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    decoration: const InputDecoration(
                      counterText: "",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty && index < 5) { // Ubah menjadi 5
                        FocusScope.of(context).nextFocus();
                      }
                    },
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),

            // Resend Code
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Verification Code",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: canResend ? _resendOTP : null,
                  child: Text(
                    "Re-send Code",
                    style: TextStyle(
                      fontSize: 16,
                      color: canResend ? Color.fromRGBO(54, 105, 201, 1) : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "Kirim kode ulang dalam ${_formatCountdown()}",
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
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
              onPressed: _verifyOTP,
              child: const Text("Continue"),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCountdown() {
    int minutes = countdown ~/ 60;
    int seconds = countdown % 60;
    return "$minutes:${seconds.toString().padLeft(2, '0')}";
  }
}