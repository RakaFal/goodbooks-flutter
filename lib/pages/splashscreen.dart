import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:goodbooks_flutter/pages/onboarding.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500)).then((_) {
        if (mounted) {
          Navigator.of(context).pushReplacement(_getRoute());
        }
      });
    });
  }

  Route _getRoute() {
    if (kIsWeb) {
      return MaterialPageRoute(builder: (_) => const OnboardingPage());
    } else if (Platform.isIOS) {
      return CupertinoPageRoute(builder: (_) => const OnboardingPage());
    } else {
      return MaterialPageRoute(builder: (_) => const OnboardingPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Image(
              image: AssetImage('assets/images/Logo.png'),
              width: 200,
            ),
            const SizedBox(height: 50),
            const SpinKitRotatingPlain(
              color: Color.fromRGBO(54, 105, 201, 1),
              size: 50.0,
            ),
          ],
        ),
      ),
    );
  }
}