class ProductModel {
  final String id;
  final String imagePath;
  final String title;
  final double price;
  final double rating;
  final int reviews;
  final String author;
  final int pageCount;
  final String genre;
  final String publisher;
  final String publishedDate;
  final String description;
  final bool isBestseller;
  final bool isPurchased; // Tambahkan field baru

  ProductModel({
    required this.id,
    required this.imagePath,
    required this.title,
    required this.price,
    required this.rating,
    required this.reviews,
    required this.author,
    required this.pageCount,
    required this.genre,
    required this.publisher,
    required this.publishedDate,
    required this.description,
    this.isBestseller = false,
    this.isPurchased = false, // Default value
  });

  // Update toMap()
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imagePath': imagePath,
      'title': title,
      'price': price,
      'rating': rating,
      'reviews': reviews,
      'author': author,
      'pageCount': pageCount,
      'genre': genre,
      'publisher': publisher,
      'publishedDate': publishedDate,
      'description': description,
      'isBestseller': isBestseller,
      'isPurchased': isPurchased, // Tambahkan ke map
    };
  }

  // Update fromMap()
  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'],
      imagePath: map['imagePath'],
      title: map['title'],
      price: map['price']?.toDouble() ?? 0.0,
      rating: map['rating']?.toDouble() ?? 0.0,
      reviews: map['reviews'] ?? 0,
      author: map['author'] ?? 'Unknown',
      pageCount: map['pageCount'] ?? 0,
      genre: map['genre'] ?? 'Unknown',
      publisher: map['publisher'] ?? '',
      publishedDate: map['publishedDate'] ?? '',
      description: map['description'] ?? '',
      isBestseller: map['isBestseller'] ?? false,
      isPurchased: map['isPurchased'] ?? false, // Handle null
    );
  }

  // Helper untuk BookDetailPage
  ProductModel copyWith({
    bool? isPurchased,
  }) {
    return ProductModel(
      id: id,
      imagePath: imagePath,
      title: title,
      price: price,
      rating: rating,
      reviews: reviews,
      author: author,
      pageCount: pageCount,
      genre: genre,
      publisher: publisher,
      publishedDate: publishedDate,
      description: description,
      isBestseller: isBestseller,
      isPurchased: isPurchased ?? this.isPurchased,
    );
  }
}