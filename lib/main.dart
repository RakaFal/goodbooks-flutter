import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Import Provider & Konfigurasi
import 'provider/firebase_options.dart';
import 'package:goodbooks_flutter/provider/auth_provider.dart';
import 'package:goodbooks_flutter/provider/WishlistProvider.dart';
import 'package:goodbooks_flutter/provider/product_services.dart';

// Import BLoC
import 'package:goodbooks_flutter/bloc/auth_bloc.dart';

// Import Halaman
import 'package:goodbooks_flutter/pages/splashscreen.dart';
import 'package:goodbooks_flutter/pages/login/LoginPage.dart';
import 'package:goodbooks_flutter/pages/profile/editprofile.dart';
import 'package:goodbooks_flutter/pages/seller/seller_home.dart';
import 'package:goodbooks_flutter/pages/seller/add_product_page.dart';
import 'package:goodbooks_flutter/pages/Wishlist.dart';
import 'package:goodbooks_flutter/theme/apptheme.dart';

void main() async {
  // Pastikan semua binding siap sebelum inisialisasi Firebase
  WidgetsFlutterBinding.ensureInitialized();
  // Inisialisasi Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Daftarkan semua provider di titik tertinggi aplikasi menggunakan MultiProvider
    return MultiProvider(
      providers: [
        // 1. Sediakan ProductService sebagai Provider biasa
        Provider<ProductService>(
          create: (_) => ProductService(),
        ),

        // 2. Sediakan AuthProvider dan langsung panggil initialize
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider()..initialize(),
        ),

        // 3. Gunakan ChangeNotifierProxyProvider untuk WishlistProvider
        // Ini membuat WishlistProvider "mendengarkan" perubahan pada AuthProvider
        ChangeNotifierProxyProvider<AuthProvider, WishlistProvider>(
          create: (_) => WishlistProvider(),
          update: (context, authProvider, previousWishlistProvider) {
            // Beri tahu WishlistProvider siapa user yang sedang login
            previousWishlistProvider?.update(authProvider.user?.id);
            return previousWishlistProvider!;
          },
        ),
        
        // 4. Sediakan AuthBloc
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            // Ambil AuthProvider yang sudah terdaftar di atasnya
            authProvider: context.read<AuthProvider>(),
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: appTheme,
        home: const Splashscreen(), // Mulai aplikasi dari SplashScreen
        routes: {
          '/seller-home': (context) => const SellerHomePage(),
          '/login': (context) => const LoginPage(),
          '/edit-profile': (context) => const EditProfilePage(),
          '/wishlist': (context) => const WishlistPage(),
          '/add-product': (context) => const AddProductPage(),
        },
      ),
    );
  }
}