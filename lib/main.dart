import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; 
import 'provider/firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:goodbooks_flutter/provider/AuthProvider.dart';
import 'package:goodbooks_flutter/provider/WishlistProvider.dart';
import 'package:goodbooks_flutter/provider/product_services.dart';
import 'package:goodbooks_flutter/config/performance_config.dart';
import 'package:goodbooks_flutter/theme/apptheme.dart'; 
import 'package:goodbooks_flutter/data/dummy_data.dart';
import 'pages/splashscreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  PerformanceConfig.optimizeForEmulator();
  PerformanceConfig.disableDebugOverlays();

  // Initialize providers
  final authProvider = AuthProvider();
  await authProvider.checkLoginStatus();

  final wishlistProvider = WishlistProvider();
  await wishlistProvider.loadWishlist();

  // Initialize ProductService and upload sample data (only in development)
  final productService = ProductService();
  await _initializeSampleProducts(productService); // Helper function

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => authProvider),
        ChangeNotifierProvider(create: (_) => wishlistProvider),
        Provider<ProductService>(create: (_) => productService), // Add ProductService
      ],
      child: const MyApp(),
    ),
  );
}

// Helper function to upload sample products (only in debug mode)
Future<void> _initializeSampleProducts(ProductService productService) async {
  if (const bool.fromEnvironment('dart.vm.product')) {
    // Don't run in production
    return;
  }

  try {
    // Check if products already exist
    final existingProducts = await productService.getProducts(limit: 1);
    if (existingProducts.isEmpty) {
      // Pass dummyProducts to uploadSampleProducts
      await productService.uploadSampleProducts(dummyProducts);
      debugPrint('✅ Sample products uploaded successfully');
    }
  } catch (e) {
    debugPrint('❌ Error uploading sample products: $e');
  }
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