class ProductModel {
  final String id;
  final String imagePath;
  final String title;
  final String author;
  final String genre;
  final String publisher;
  final String publishedDate;
  final String description;
  final double price;
  final double rating;
  final int reviews;
  final int pageCount;
  final bool isBestseller;
  final bool isPurchased;

  ProductModel({
    required this.id,
    required this.imagePath,
    required this.title,
    required this.author,
    required this.genre,
    required this.publisher,
    required this.publishedDate,
    required this.description,
    required this.price,
    required this.rating,
    required this.reviews,
    required this.pageCount,
    required this.isBestseller,
    required this.isPurchased,
  });

  // Factory dari JSON
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? '',
      imagePath: json['imagePath'] ?? '',
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      genre: json['genre'] ?? '',
      publisher: json['publisher'] ?? '',
      publishedDate: json['publishedDate'] ?? '',
      description: json['description'] ?? '',
      price: json['price']?.toDouble() ?? 0.0,
      rating: json['rating']?.toDouble() ?? 0.0,
      reviews: json['reviews'] ?? 0,
      pageCount: json['pageCount'] ?? 0,
      isBestseller: json['isBestseller'] ?? false,
      isPurchased: json['isPurchased'] ?? false,
    );
  }

  // Method toJson
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imagePath': imagePath,
      'title': title,
      'author': author,
      'genre': genre,
      'publisher': publisher,
      'publishedDate': publishedDate,
      'description': description,
      'price': price,
      'rating': rating,
      'reviews': reviews,
      'pageCount': pageCount,
      'isBestseller': isBestseller,
      'isPurchased': isPurchased,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] ?? '',
      imagePath: map['imagePath'] ?? '',
      title: map['title'] ?? '',
      author: map['author'] ?? '',
      genre: map['genre'] ?? '',
      publisher: map['publisher'] ?? '',
      publishedDate: map['publishedDate'] ?? '',
      description: map['description'] ?? '',
      price: map['price']?.toDouble() ?? 0.0,
      rating: map['rating']?.toDouble() ?? 0.0,
      reviews: map['reviews'] ?? 0,
      pageCount: map['pageCount'] ?? 0,
      isBestseller: map['isBestseller'] ?? false,
      isPurchased: map['isPurchased'] ?? false,
    );
  }

  // Untuk kirim ke Supabase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imagePath': imagePath,
      'title': title,
      'author': author,
      'genre': genre,
      'publisher': publisher,
      'publishedDate': publishedDate,
      'description': description,
      'price': price,
      'rating': rating,
      'reviews': reviews,
      'pageCount': pageCount,
      'isBestseller': isBestseller,
      'isPurchased': isPurchased,
    };
}
}