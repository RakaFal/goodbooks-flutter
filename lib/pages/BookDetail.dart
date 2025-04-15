import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:goodbooks_flutter/provider/WishlistProvider.dart';
import 'package:goodbooks_flutter/models/product_models.dart';
import 'payment/CheckoutPage.dart';

class BookDetailPage extends StatefulWidget {
  final String bookId;
  final String bookTitle;
  final String author;
  final String coverImage;
  final double rating;
  final int pageCount;
  final String genre;
  final String publisher;
  final String publishedDate;
  final String description;
  final bool isPurchased;
  final double price;

  const BookDetailPage({
    super.key,
    required this.bookId,
    required this.bookTitle,
    required this.author,
    required this.coverImage,
    required this.rating,
    required this.pageCount,
    required this.genre,
    required this.publisher,
    required this.publishedDate,
    required this.description,
    required this.isPurchased,
    required this.price,
  });

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  bool _isExpanded = false;

    void _navigateToCheckout(BuildContext context) {
    final product = ProductModel(
      id: widget.bookId,
      imagePath: widget.coverImage,
      title: widget.bookTitle,
      price: widget.price,
      rating: widget.rating,
      reviews: 0,
      author: widget.author,
      pageCount: widget.pageCount,
      genre: widget.genre,
      publisher: widget.publisher,
      publishedDate: widget.publishedDate,
      description: widget.description,
      isBestseller: false,
      isPurchased: widget.isPurchased,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutPage(product: product),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.bookTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Hero(
                tag: 'book-cover-${widget.bookId}',
                child: Image.asset(
                  widget.coverImage,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.bookTitle,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'by ${widget.author}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      RatingBar.builder(
                        initialRating: widget.rating,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemSize: 20,
                        itemBuilder: (context, _) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (rating) {},
                        ignoreGestures: true,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.rating}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildInfoChip(Icons.menu_book, '${widget.pageCount} pages'),
                      _buildInfoChip(Icons.account_balance, widget.publisher),
                      _buildInfoChip(Icons.calendar_today, widget.publishedDate),
                      _buildInfoChip(Icons.category, widget.genre),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Builder(
                        builder: (context) {
                          final textPainter = TextPainter(
                            text: TextSpan(
                              text: widget.description,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            maxLines: 3,
                            textDirection: TextDirection.ltr,
                          );
                          
                          textPainter.layout(maxWidth: MediaQuery.of(context).size.width - 32);
                          
                          if (textPainter.didExceedMaxLines) {
                            return TextButton(
                              onPressed: () {
                                setState(() {
                                  _isExpanded = !_isExpanded;
                                });
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                _isExpanded ? 'Show Less' : 'Read More',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: 14,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    child: ConstrainedBox(
                      constraints: _isExpanded 
                        ? const BoxConstraints() 
                        : const BoxConstraints(maxHeight: 70),
                      child: Text(
                        widget.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                        overflow: TextOverflow.fade,
                      ),
                    ),
                  ),
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

  Widget _buildInfoChip(IconData icon, String text) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(text),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final wishlistProvider = Provider.of<WishlistProvider>(context);
    final isWishlisted = wishlistProvider.isInWishlist(widget.bookId);

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: Icon(widget.isPurchased ? Icons.menu_book : Icons.shopping_cart),
            label: Text(widget.isPurchased 
              ? 'Read Now' 
              : 'Buy Now - Rp${widget.price.toStringAsFixed(0)}'),
            onPressed: () {
              if (widget.isPurchased) {

              } else {
                _navigateToCheckout(context);
              }
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: widget.isPurchased ? Colors.white : Colors.blue,
              foregroundColor: widget.isPurchased ? Colors.blue : Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 16),
        IconButton(
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return ScaleTransition(
                scale: animation,
                child: child,
              );
            },
            child: Icon(
              key: ValueKey<bool>(isWishlisted),
              isWishlisted ? Icons.favorite : Icons.favorite_border,
              color: isWishlisted ? Colors.red : Colors.grey,
            ),
          ),
          style: IconButton.styleFrom(
            backgroundColor: Colors.grey[200],
            padding: const EdgeInsets.all(16),
          ),
          onPressed: () {
            final product = ProductModel(
              id: widget.bookId,
              imagePath: widget.coverImage,
              title: widget.bookTitle,
              price: widget.price,
              rating: widget.rating,
              reviews: 0, 
              author: widget.author,
              pageCount: widget.pageCount,
              genre: widget.genre,
              publisher: widget.publisher,
              publishedDate: widget.publishedDate,
              description: widget.description,
              isBestseller: widget.isPurchased,
            );
            wishlistProvider.toggleWishlist(product);
          },
        ),
      ],
    );
  }
}