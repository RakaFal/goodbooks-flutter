import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CategoryModel {
  final String id;
  final String name;
  final String iconName;
  final String boxColorHex; // DIUBAH: dari Color ke String untuk kode Hex
  final int order;

  CategoryModel({
    required this.id,
    required this.name,
    required this.iconName,
    required this.boxColorHex,
    required this.order,
  });

  // BARU: Getter untuk mengubah string Hex menjadi objek Color
  Color get boxColor {
    // Menghapus karakter '#' jika ada dan memastikan formatnya benar
    final hexCode = boxColorHex.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  // BARU: Factory constructor dari Firestore
  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CategoryModel(
      id: doc.id,
      name: data['name'] ?? 'No Name',
      iconName: data['iconName'] ?? 'question',
      boxColorHex: data['boxColorHex'] ?? 'FFFFFF', // Default ke putih jika tidak ada
      order: data['order'] ?? 99,
    );
  }

  static IconData getIconData(String iconName) {
  switch(iconName) {
    case 'Foods':
      return FontAwesomeIcons.burger;
    case 'Horror':
      return FontAwesomeIcons.ghost;
    case 'Fashion':
      return FontAwesomeIcons.shirt;
    case 'Technology':
      return FontAwesomeIcons.laptop;
    case 'Psychology':
      return FontAwesomeIcons.brain;
    case 'Romance':
      return FontAwesomeIcons.heart;
    case 'Fanfiction':
      return FontAwesomeIcons.book;
    case 'Science Fiction':
      return FontAwesomeIcons.rocket;
    case 'Mystery':
      return FontAwesomeIcons.question;
    case 'Fantasy':
      return FontAwesomeIcons.dragon;
    case 'Thriller':
      return FontAwesomeIcons.bolt;
    case 'Historical':
      return FontAwesomeIcons.monument;
    case 'Realistic Fiction':
      return FontAwesomeIcons.globe;
    default:
      return Icons.error;
    }
  }
  }

