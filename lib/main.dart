import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'provider/firebase_options.dart';
import 'package:goodbooks_flutter/provider/AuthProvider.dart';
import 'package:goodbooks_flutter/provider/WishlistProvider.dart';
import 'package:goodbooks_flutter/provider/product_services.dart';
import 'package:goodbooks_flutter/config/performance_config.dart';
import 'package:goodbooks_flutter/theme/apptheme.dart';
import 'package:goodbooks_flutter/data/dummy_data.dart';
import 'pages/splashscreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Start app initialization and run
  runApp(const AppInitializer());
}

class AppInitializer extends StatelessWidget {
  const AppInitializer({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return MaterialApp(
              home: Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Failed to initialize app'),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(snapshot.error.toString(), textAlign: TextAlign.center,),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Restart the app by calling main again
                          main();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          return snapshot.data!;
        }
        // Show loading while initializing
        return const MaterialApp(
          home: Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
        );
      },
    );
  }

  Future<Widget> _initializeApp() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      PerformanceConfig.optimizeForEmulator();
      PerformanceConfig.disableDebugOverlays();

      final authProvider = AuthProvider();
      await authProvider.checkLoginStatus();

      final wishlistProvider = WishlistProvider();
      await wishlistProvider.loadWishlist();

      final productService = ProductService();
      if (kDebugMode) {
        await _initializeSampleProducts(productService);
      }

      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => authProvider),
          ChangeNotifierProvider(create: (_) => wishlistProvider),
          Provider<ProductService>(create: (_) => productService),
        ],
        child: const MyApp(),
      );
    } catch (e) {
      debugPrint('Initialization error: $e');
      // Return error screen widget instead of throwing
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Failed to initialize app'),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(e.toString(), textAlign: TextAlign.center,),
                ),
                ElevatedButton(
                  onPressed: () {
                    main();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Future<void> _initializeSampleProducts(ProductService productService) async {
    try {
      final existingProducts = await productService.getProducts(limit: 1);
      if (existingProducts.isEmpty) {
        await productService.uploadSampleProducts(dummyProducts);
        debugPrint('✅ Sample products uploaded');
      }
    } catch (e) {
      debugPrint('❌ Error uploading samples: $e');
    }
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
        ErrorWidget.builder = (FlutterErrorDetails details) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Something went wrong'),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(details.exception.toString(), textAlign: TextAlign.center,),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Back'),
                  ),
                ],
              ),
            ),
          );
        };
        return child!;
      },
    );
  }
}
