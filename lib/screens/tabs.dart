import 'package:flutter3_firestore_passenger/screens/home_screen.dart';
import 'package:flutter3_firestore_passenger/screens/orders.dart';
import 'package:flutter3_firestore_passenger/screens/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class TabsScreen extends StatefulWidget {
  TabsScreen({Key? key}) : super(key: key);

  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  late PageController pageController;

  int pageIndex = 0;

  @override
  void initState() {
    super.initState();

    pageController = PageController();

    setState(() {
      pageIndex = 0;
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex) {
    pageController.animateToPage(
      pageIndex,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: PageView(
          children: <Widget>[
            HomeScreen(),
            Profile(),
            Orders(),
            //Maps(),
          ],
          controller: pageController,
          onPageChanged: onPageChanged,
          physics: NeverScrollableScrollPhysics(),
        ),
      ), //page
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: pageIndex,
        onTap: onTap,
        // activeColor: Colors.redAccent.shade700,
        activeColor: Colors.black,
        // backgroundColor: Colors.redAccent.shade100,
        backgroundColor: Color(0xFFfd0011),
        inactiveColor: Colors.white,
        items: [
          BottomNavigationBarItem(
              //icon: Icon(Icons.shopping_cart),

              icon: Icon(Icons.share_location),
              label: "Search Taxi"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_search_sharp), label: "My Profile"),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_road),
            label: "My Trips",
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.map),
          // ),
        ],
      ),
    );
  }
}
