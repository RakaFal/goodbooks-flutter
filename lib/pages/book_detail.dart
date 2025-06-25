import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'dart:convert'; 
import 'package:goodbooks_flutter/provider/WishlistProvider.dart';
import 'package:goodbooks_flutter/provider/auth_provider.dart';
import 'package:goodbooks_flutter/provider/product_services.dart';
import 'package:goodbooks_flutter/models/product_models.dart';
import 'package:goodbooks_flutter/models/user_model.dart';
import 'package:goodbooks_flutter/pages/Login/LoginPage.dart';
import 'package:goodbooks_flutter/pages/Login/LoginDialog.dart';
import './checkout/CheckoutPage.dart';

class BookDetailPage extends StatefulWidget {
  final ProductModel product;

  const BookDetailPage({
    super.key,
    required this.product,
  });

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  bool _isExpanded = false;

  void _navigateToCheckout(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutPage(product: widget.product),
      ),
    );
  }

  // Fungsi untuk menampilkan dialog login jika diperlukan
  void _showLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => LoginDialog(
        onLoginPressed: (ctx) {
          Navigator.pop(ctx);
          Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage()));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 350, 
            pinned: true,
            stretch: true,
            backgroundColor: Colors.blueGrey[800], 
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              titlePadding: const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
              title: Text(
                widget.product.title, 
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
                ),
                textAlign: TextAlign.center,
              ),
              background: Hero(
                tag: 'book-cover-${widget.product.id}',
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    widget.product.imageBase64.isNotEmpty
                      ? Image.memory(
                          base64Decode(widget.product.imageBase64),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.error, color: Colors.white, size: 50),
                        )
                      : Container( 
                          color: Colors.grey[300],
                          child: const Icon(Icons.book, size: 80, color: Colors.grey),
                        ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment(0.0, 0.5),
                          end: Alignment.center,
                          colors: <Color>[
                            Color(0x60000000),
                            Color(0x00000000),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              // DIUBAH: Semua `widget.namaVariabel` diubah menjadi `widget.product.namaField`
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'by ${widget.product.author}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildSellerInfo(context),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      RatingBar.builder(
                        initialRating: widget.product.rating,
                        itemSize: 20,
                        ignoreGestures: true,
                        // ... sisa properti RatingBar ...
                        itemBuilder: (context, _) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ), onRatingUpdate: (double value) {  },
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.product.rating} (${widget.product.reviews} reviews)',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildInfoChip(Icons.menu_book, '${widget.product.pageCount} pages'),
                      _buildInfoChip(Icons.account_balance, widget.product.publisher),
                      _buildInfoChip(Icons.calendar_today, widget.product.publishedDate),
                      _buildInfoChip(Icons.category, widget.product.genre),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // ... (Sisa dari UI deskripsi Anda sudah bagus dan tidak perlu diubah) ...
                  _buildDescriptionSection(context),
                  const SizedBox(height: 32),
                  _buildActionButtons(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSellerInfo(BuildContext context) {
    return FutureBuilder<User>(
      future: ProductService().getSellerInfo(widget.product.sellerId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Row(children: [Text("Dijual oleh: "), SizedBox(width: 8), SizedBox(height: 12, width: 12, child: CircularProgressIndicator(strokeWidth: 2))]);
        }
        if (snapshot.hasError) {
          return const Text("Gagal memuat info penjual.", style: TextStyle(color: Colors.red));
        }
        if (snapshot.hasData) {
          final seller = snapshot.data!;
          return Row(
            children: [
              Text("Dijual oleh: ", style: Theme.of(context).textTheme.titleSmall),
              Text(
                seller.name,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildDescriptionSection(BuildContext context) {
    // Logika "Read More" Anda sudah bagus, kita hanya perlu mengubah sumber teksnya
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
             Text(
              'Description',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => setState(() => _isExpanded = !_isExpanded),
              child: Text(_isExpanded ? 'Show Less' : 'Read More'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        AnimatedCrossFade(
          firstChild: Text(
            widget.product.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          secondChild: Text(
            widget.product.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Chip(
      avatar: Icon(icon, size: 18, color: Colors.blueGrey),
      label: Text(text),
      backgroundColor: Colors.grey[200],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final wishlistProvider = Provider.of<WishlistProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false); // Dapatkan AuthProvider
    final isWishlisted = wishlistProvider.isInWishlist(widget.product.id);

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: Icon(widget.product.isPurchased ? Icons.menu_book : Icons.shopping_cart),
            label: Text(widget.product.isPurchased
                ? 'Read Now'
                : 'Buy Now - Rp${widget.product.price.toStringAsFixed(0)}'),
            onPressed: () {
              if (widget.product.isPurchased) {
                // TODO: Implementasi logika "Read Now"
              } else {
                _navigateToCheckout(context);
              }
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Color.fromRGBO(54, 105, 201, 1),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
          ),
        ),
        const SizedBox(width: 16),
        IconButton(
          icon: Icon(
            isWishlisted ? Icons.favorite : Icons.favorite_border,
            color: isWishlisted ? Colors.red : Colors.grey,
            size: 30,
          ),
          onPressed: () {
            if (!authProvider.isLoggedIn) {
              _showLoginDialog(context);
              return;
            }
            // DIUBAH: Langsung gunakan widget.product
            wishlistProvider.toggleWishlist(widget.product);
          },
        ),
      ],
    );
  }
}