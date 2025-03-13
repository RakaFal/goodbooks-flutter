import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:goodbooks_flutter/models/banner_models.dart';
import 'package:goodbooks_flutter/models/best_product_models.dart';
import 'package:goodbooks_flutter/models/category_models.dart';
import 'package:goodbooks_flutter/base/navbar.dart';
import 'LoginPage.dart';
import 'dart:math';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<CategoryModels> categories = [];
  List<BannerModel> banners = [];
  List<BestproductModels> bestproduct = [];

@override
void initState() {
  super.initState();
  _getCategories();
  _getBanners();
  _getProduct();

  // Tampilkan modal login otomatis setelah halaman dimuat
  Future.delayed(Duration(milliseconds: 300), () {
    _showLoginModal();
  });
}

void _getCategories() {
  categories = CategoryModels.getCategories();
}

void _getBanners() {
  banners = BannerModel.getBanners();
}

void _getProduct() {
  bestproduct = BestproductModels.getProducts();
}

void _showLoginModal() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    barrierColor: Colors.black.withOpacity(0.7), // Gelapin background biar fokus ke modal
    enableDrag: false, // Jangan bisa swipe turun buat nutup
    isDismissible: false, // Jangan bisa tap di luar buat nutup
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => const LoginPage(), // Ganti dengan halaman login kamu
  );
}


  @override
  Widget build(BuildContext context) {
    _getCategories();
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _searchField(),
            _buildBannerSlider(),
            const SizedBox(height: 20),
            _categorylist(),
            const SizedBox(height: 20),
            _bestProductList(),
            const SizedBox(height: 20),
            _bestSellerProductList()
          ],
        ),
      ),
    );
  }

  Column _bestSellerProductList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(
            'Best Seller',
            style: TextStyle(
              color: Color.fromRGBO(12, 26, 48, 1),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 250,
          child: ListView(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true, 
            physics: BouncingScrollPhysics(), 
            children: [
              const SizedBox(width: 20),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: bestproduct.map((bestproduct) => _buildProductItem(bestproduct)).toList(),
              ),
              const SizedBox(width: 20),
            ],
          ),
        ),
        const SizedBox(height: 50),
      ],
    );

  }
  Column _bestProductList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(
            'Best Products',
            style: TextStyle(
              color: Color.fromRGBO(12, 26, 48, 1),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 250,
          child: ListView(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true, 
            physics: BouncingScrollPhysics(), 
            children: [
              const SizedBox(width: 20),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: bestproduct.map((bestproduct) => _buildProductItem(bestproduct)).toList(),
              ),
              const SizedBox(width: 20),
            ],
          ),
        ),
        const SizedBox(height: 50),
      ],
    );
  }

  Container _buildProductItem(BestproductModels bestproduct) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.asset(
              bestproduct.imagePath, 
              width: double.infinity,
              height: 150,
              fit: BoxFit.fill,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bestproduct.title, 
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Rp. ${bestproduct.price.toStringAsFixed(0) ?? "0"}', // Null check
                  style: const TextStyle(
                    color: Color.fromRGBO(254, 58, 48, 1),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${bestproduct.rating.toStringAsFixed(1) ?? "0.0"} (${bestproduct.reviews ?? 0} reviews)', // Null check
                      style: const TextStyle(
                        color: Color.fromRGBO(12, 26, 48, 1),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Container _buildBannerSlider() {
    if (banners.isEmpty) {
      return Container(
        height: 200,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      );
    }
    banners.shuffle(Random());
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: PageView.builder(
        itemCount: banners.length,
        scrollDirection: Axis.horizontal,
        controller: PageController(
          viewportFraction: 0.9,
        ),
        physics: BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return _buildBannerItem(banners[index]);
        },
      ),
    );
  }

  Container _buildBannerItem(BannerModel banner) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 0,
            blurRadius: 20,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            banner.imagePath,
            fit: BoxFit.cover,
            width: double.infinity,
            height: 200,
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Text(
                  'Failed to load image',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Column _categorylist() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(
            'Genres',
            style: TextStyle(
              color: Color.fromRGBO(12, 26, 48, 1),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 100,
          child: ListView.separated(
            itemCount: categories.length,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 20),
            physics: BouncingScrollPhysics(), 
            separatorBuilder: (context, index) => const SizedBox(width: 32),
            itemBuilder: (context, index) {
              final hslColor = HSLColor.fromColor(categories[index].boxColor);
              final iconColor = hslColor.withLightness((hslColor.lightness - 0.2).clamp(0.0, 1.0)).toColor();

              return Column(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: categories[index].boxColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 50,
                          height: 50,
                          child: Icon(
                            CategoryModels.getIconData(categories[index].iconName),
                            size: 35,
                            color: iconColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    categories[index].name,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Color.fromRGBO(12, 26, 48, 1),
                      fontSize: 14
                      ),
                    )
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Container _searchField() {
    return Container(
          margin: EdgeInsets.only(top: 20, left: 20, right: 20),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 0.0,
                blurRadius: 40,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: TextField(
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color.fromRGBO(250, 250, 250, 1),
              hintText: 'Search for books',
              hintStyle: TextStyle(
                color: Color.fromRGBO(196, 197, 196, 1),
                fontSize: 16,
              ),
              contentPadding: EdgeInsets.all(15),
              suffixIcon: SizedBox(
                width: 100,
                child: IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      VerticalDivider(
                        color: Color.fromRGBO(250, 250, 250, 1),
                        thickness: 0.2,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Icon(Icons.search),
                      ),
                    ],
                  ),
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(40),
                borderSide: BorderSide.none
            ),
          ),
        ),
        );
  }
}
