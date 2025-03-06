class BannerModel {
  final String imagePath;

  BannerModel({
    required this.imagePath
  });

  static List<BannerModel> getBanners() {
    return [
      BannerModel(imagePath: 'assets/images/Iklan_Facebook_Dibalik_Gedung_Merah_Bergaya_Kreatif_Ilustrasi_Biru_dan_Hijau.png'),
      BannerModel(imagePath: 'assets/images/Hari-Buku-Nasional_Twitter-min.png'),
    ];
  }
}