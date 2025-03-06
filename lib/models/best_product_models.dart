class BestproductModels {
  final String imagePath;
  final String title;
  final double price;
  final double rating;
  final int reviews;

  BestproductModels({
    required this.imagePath,
    required this.title,
    required this.price,
    required this.rating,
    required this.reviews,
  });

  static List<BestproductModels> getProducts() {
    return [

      BestproductModels(
        imagePath: 'assets/images/A_Brief_History_of_Humankind.jpg', 
        title: 'Sapiens - A Brief History of Humankind',
        price: 69000.0, 
        rating: 4.6, 
        reviews: 76,
      ),
      BestproductModels(
        imagePath: 'assets/images/Man_Search_For_Meaning.jpg', 
        title: 'Man Search For Meaning', 
        price: 50000.0, 
        rating: 4.8, 
        reviews: 45,
      ),
      BestproductModels(
        imagePath: 'assets/images/The_4-Hour_Workweek.jpg',
        title: 'The 4-Hour Workweek', 
        price: 75000, 
        rating: 4.7, 
        reviews: 100
      ),
    ];
  }
}
