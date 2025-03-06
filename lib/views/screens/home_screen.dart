import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50), // AppBar height
        child: AppBar(
          backgroundColor: const Color.fromARGB(255, 221, 178, 49),
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.account_circle),
              onPressed: () {
                // Navigate to profile screen
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView( // Entire page scrollable
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Categories Section
            const Text(
              'Categories:',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 20),
            // Categories Row inside a non-scrollable container
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _categoryBox(Icons.fastfood, "Food"),
                _categoryBox(Icons.storefront, "Retail"),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _categoryBox(Icons.favorite, "Favorites"),
                _categoryBox(Icons.location_pin, "Near Me"),
              ],
            ),
            const SizedBox(height: 30),
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "Search...",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Featured Shops Title
            const Text(
              'Featured Shops',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 20),
            // Featured Shops Placeholders
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _shopPlaceholder(),
                _shopPlaceholder(),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar( // Using BottomNavigationBar instead of BottomAppBar
        backgroundColor: const Color.fromARGB(255, 221, 178, 49),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star_border),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none),
            label: '',
          ),
        ],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white60,
      ),
    );
  }

  // Widget to create category box
  Widget _categoryBox(IconData icon, String label) {
    return Container(
      width: MediaQuery.of(context).size.width / 2 - 30, // Adjust width for spacing
      height: 150, // Fixed height
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 221, 178, 49),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: Colors.white),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Widget to create shop placeholder
  Widget _shopPlaceholder() {
    return Container(
      width: MediaQuery.of(context).size.width / 2 - 20,
      height: 200,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 221, 178, 49),
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Center(
        child: Text(
          'Shop Placeholder',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
