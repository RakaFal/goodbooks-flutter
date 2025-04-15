class BestproductModels {
  final String imagePath;
  final String title;
  final String bookId;
  final double price;
  final double rating;
  final int reviews;
  final String author;
  final int pageCount;
  final String publisher;
  final String publishedDate;
  final String description;
  final bool isBestseller;

  BestproductModels({
    required this.imagePath,
    required this.title,
    required this.bookId,
    required this.price,
    required this.rating,
    required this.reviews,
    required this.author,
    required this.pageCount,
    required this.publisher,
    required this.publishedDate,
    required this.description,
    this.isBestseller = false,
  });

  static BestproductModels? fromId(String bookId) {
    try {
      return getProducts().firstWhere((book) => book.bookId == bookId);
    } catch (e) {
      return null;
    }
  }

  static List<BestproductModels> getProducts() {
    return [
      BestproductModels(
        imagePath: 'assets/images/A_Brief_History_of_Humankind.jpg',
        title: 'Sapiens - A Brief History of Humankind',
        bookId: 'ABHH2011',
        price: 69000.0,
        rating: 4.6,
        reviews: 76,
        author: 'Yuval Noah Harari',
        pageCount: 512,
        publisher: 'Harper',
        publishedDate: '2011',
        description: 'Bagaimana manusia, yang dulunya hanya spesies biasa di antara makhluk hidup lainnya, bisa mendominasi dunia? Sapiens karya Yuval Noah Harari adalah buku yang mengguncang cara kita memahami sejarah dan masa depan umat manusia.\nDari zaman purba hingga era modern, Harari menjelaskan bagaimana Homo sapiens bertahan, berevolusi, dan menciptakan peradaban melalui tiga revolusi utama: Kognitif, Agrikultur, dan Sains. Buku ini mengajak pembaca menelusuri peran mitos, agama, uang, dan teknologi dalam membentuk dunia yang kita kenal saat ini.\nDengan gaya penulisan yang tajam dan penuh wawasan, Sapiens tidak hanya menawarkan fakta sejarah, tetapi juga mengajukan pertanyaan mendalam tentang siapa kita dan ke mana kita akan menuju.',
        isBestseller: true
      ),
      BestproductModels(
        imagePath: 'assets/images/Man_Search_For_Meaning.jpg',
        title: 'Man Search For Meaning',
        bookId: 'MSFM1946',
        price: 50000.0,
        rating: 4.8,
        reviews: 45,
        author: 'Viktor E. Frankl',
        pageCount: 200,
        publisher: 'Beacon Press',
        publishedDate: '1946',
        description: 'Apa yang membuat manusia tetap bertahan meskipun menghadapi penderitaan yang luar biasa? Man’s Search for Meaning karya Viktor E. Frankl adalah sebuah kisah yang menggugah jiwa, berdasarkan pengalaman langsung penulis saat bertahan hidup di kamp konsentrasi Nazi.\nLebih dari sekadar memoar, buku ini mengajarkan bahwa makna hidup dapat ditemukan bahkan dalam situasi yang paling menyakitkan. Frankl, seorang psikiater, mengembangkan logoterapi, sebuah teori yang menekankan bahwa motivasi utama manusia bukanlah kesenangan atau kekuasaan, tetapi mencari makna hidup.\nDengan refleksi yang mendalam dan penuh inspirasi, buku ini membantu pembaca memahami bahwa di tengah penderitaan, kita masih memiliki kebebasan untuk memilih bagaimana merespons kehidupan.',
        isBestseller: true
      ),
      BestproductModels(
        imagePath: 'assets/images/The_4-Hour_Workweek.jpg',
        title: 'The 4-Hour Workweek', 
        bookId: '4HWW2007',
        price: 75000, 
        rating: 4.7, 
        reviews: 100,
        author: 'Timothy Ferriss',
        pageCount: 308,
        publisher: 'Crown Publishing Group',
        publishedDate: '2007',
        description: 'Bagaimana jika Anda bisa menikmati hidup sekarang, tanpa menunggu pensiun? The 4-Hour Workweek karya Tim Ferriss adalah panduan revolusioner bagi siapa saja yang ingin keluar dari rutinitas kerja 9-to-5 dan merancang gaya hidup yang lebih bebas.\nBuku ini mengajarkan strategi untuk meningkatkan produktivitas, mengotomatisasi pekerjaan, dan menciptakan sumber pendapatan pasif, sehingga Anda bisa bekerja lebih sedikit namun tetap menghasilkan lebih banyak. Dengan konsep DEAL (Definition, Elimination, Automation, Liberation), Ferriss menunjukkan bagaimana siapa pun bisa merancang hidup impian mereka—bepergian keliling dunia, memulai bisnis online, atau sekadar punya lebih banyak waktu untuk menikmati hidup.',
        isBestseller: true
      ),
    ];
  }
}