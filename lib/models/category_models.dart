import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
class CategoryModels {
  String name;
  String iconName;
  Color boxColor;

  CategoryModels({
    required this.name,
    required this.iconName,
    required this.boxColor,
  });

  static List<CategoryModels> getCategories() {
    List<CategoryModels> Categories = [];

    Categories.add(
      CategoryModels(
        name: 'Foods',
        iconName: 'Foods',
        boxColor: Colors.green.shade100,
      )
    );

    Categories.add(
      CategoryModels(
        name: 'Horror',
        iconName: 'Horror',
        boxColor: Colors.red.shade100,
      )
    );

    Categories.add(
      CategoryModels(
        name: 'Fashion',
        iconName: 'Fashion',
        boxColor: Colors.yellow.shade100,
      )
    );

    Categories.add(
      CategoryModels(
        name: 'Technology',
        iconName: 'Technology',
        boxColor: Colors.purple.shade100,
      )
    );

    Categories.add(
      CategoryModels(
        name: 'Psychology',
        iconName: 'Psychology',
        boxColor: Colors.teal.shade100,
      )
    );

    Categories.add(
      CategoryModels(
        name: 'Romance',
        iconName: 'Romance',
        boxColor: Colors.blue.shade100,
      )
    );

    Categories.add(
      CategoryModels(
        name: 'Fanfiction',
        iconName: 'Fanfiction',
        boxColor: Colors.pink.shade100,
      )
    );

    Categories.add(
      CategoryModels(
        name: 'Science Fiction',
        iconName: 'Science Fiction',
        boxColor: Colors.deepPurpleAccent.shade100,
      )
    );

    Categories.add(
      CategoryModels(
        name: 'Mystery',
        iconName: 'Mystery',
        boxColor: Colors.blueGrey.shade100,
      )
    );

    Categories.add(
      CategoryModels(
        name: 'Fantasy',
        iconName: 'Fantasy',
        boxColor: Colors.cyan.shade100,
      )
    );

    Categories.add(
      CategoryModels(
        name: 'Thriller',
        iconName: 'Thriller',
        boxColor: Colors.indigoAccent.shade100,
      )
    );

    Categories.add(
      CategoryModels(
        name: 'Historical',
        iconName: 'Historical',
        boxColor: Colors.brown.shade100,
      )
    );

    Categories.add(
      CategoryModels(
        name: 'Realistic Fiction',
        iconName: 'Realistic Fiction',
        boxColor: Colors.deepOrange.shade100,
      )
    );
    return Categories;
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

