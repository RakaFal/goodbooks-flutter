import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; 
import 'firebase/firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:goodbooks_flutter/provider/AuthProvider.dart';
import 'package:goodbooks_flutter/provider/WishlistProvider.dart';
import 'package:goodbooks_flutter/config/performance_config.dart';
import 'package:goodbooks_flutter/theme/apptheme.dart'; 
import 'pages/splashscreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  PerformanceConfig.optimizeForEmulator();
  PerformanceConfig.disableDebugOverlays();

  final authProvider = AuthProvider();
  await authProvider.checkLoginStatus();

  final wishlistProvider = WishlistProvider();
  await wishlistProvider.loadWishlist();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => authProvider), 
        ChangeNotifierProvider(create: (_) => wishlistProvider), 
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: appTheme, 
      home: const Splashscreen(),
      builder: (context, child) {
        ErrorWidget.builder = (details) => Scaffold(
          body: Center(child: Text('Error: ${details.exception}')),
        );
        return child!;
      },
    );
  }
}
