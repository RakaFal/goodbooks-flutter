import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:goodbooks_flutter/pages/home.dart';
import 'package:goodbooks_flutter/pages/profile.dart';

class NavBar extends StatefulWidget {
  const NavBar({Key? key}) : super(key: key);

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const Center(child: Text('Search Page')),
    const Center(child: Text('Library Page')),
    const Profile(),
  ];

  final List<String> _titles = [
    'Goodbooks',
    'Search',
    'Library',
    'Profile',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Library'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        selectedItemColor: Color.fromRGBO(54, 105, 201, 1),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
      ),
    );
  }

  AppBar appBar() {
  return AppBar(
    title: Text(
      _titles[_selectedIndex],
      style: const TextStyle(
        color: Color.fromRGBO(54, 105, 201, 1),
        fontSize: 25,
        fontWeight: FontWeight.bold,
      ),
    ),
    backgroundColor: Colors.white,
    elevation: 0,
    centerTitle: _selectedIndex == 0,
    leading: _selectedIndex == 0
        ? GestureDetector(
            onTap: () {},
            child: Container(
              margin: const EdgeInsets.all(15),
              alignment: Alignment.center,
              child: SvgPicture.asset(
                'assets/icons/bell-svgrepo-com.svg',
                height: 30,
                width: 30,
              ),
            ),
          )
        : null, // Halaman selain Home tidak ada ikon di kiri
    actions: [
      if (_selectedIndex != 0)
      GestureDetector(
        onTap: () {},
        child: Container(
          margin: const EdgeInsets.all(15),
          alignment: Alignment.center,
          child: SvgPicture.asset(
            'assets/icons/bell-svgrepo-com.svg',
            height: 30,
            width: 30,
          ),
        ),
      ),
      GestureDetector(
        onTap: () {},
        child: Container(
          margin: const EdgeInsets.only(right: 15),
          alignment: Alignment.center,
          child: SvgPicture.asset(
            'assets/icons/shopping-cart-svgrepo-com.svg',
            height: 30,
            width: 30,
          ),
        ),
      ),
    ],
  );
}

}
