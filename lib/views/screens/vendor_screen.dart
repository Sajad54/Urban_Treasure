import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urban_treasure/views/screens/home_screen.dart';
import 'package:urban_treasure/views/screens/rewards_screen.dart';

class VendorScreen extends StatefulWidget {
  const VendorScreen({super.key});

  @override
  State<VendorScreen> createState() => _VendorScreenState();
}

class _VendorScreenState extends State<VendorScreen> {
  final supabase = Supabase.instance.client;

  final List<String> categories = ['Food', 'Clothes', 'Skin/Body Care', 'Crafts'];
  final List<String> locations = ['Washington, DC', 'Fairfax, VA', 'Frederick, MD'];

  String _selectedCategory = 'Food';
  String _selectedLocation = 'Washington, DC';

  List<Map<String, dynamic>> _vendors = [];
  List<String> _favoriteCouponIds = [];
  int _currentIndex = 1;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _fetchVendors();
  }

  Future<void> _loadFavorites() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final response = await supabase
        .from('favorites')
        .select('coupon_id')
        .eq('user_id', user.id);

    setState(() {
      _favoriteCouponIds = List<Map<String, dynamic>>.from(response)
          .map((fav) => fav['coupon_id'] as String)
          .toList();
    });
  }

  Future<void> _fetchVendors() async {
    debugPrint("Fetching vendors where category=$_selectedCategory and location=$_selectedLocation");

    final response = await supabase
        .from('profiles')
        .select('id, username')
        .eq('role', 'vendor')
        .eq('location', _selectedLocation)
        .eq('category', _selectedCategory);

    final List<Map<String, dynamic>> vendors = List<Map<String, dynamic>>.from(response);
    debugPrint("Raw vendor result: $vendors");

    for (var vendor in vendors) {
      final couponsResponse = await supabase
          .from('coupons')
          .select('id, code, discount')
          .eq('vendor_id', vendor['id']);

      vendor['coupons'] = List<Map<String, dynamic>>.from(couponsResponse);
    }

    setState(() {
      _vendors = vendors;
    });

    debugPrint("Final vendor list: ${_vendors.length} vendors");
  }

  Future<void> _toggleFavorite(String couponId) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final isFavorited = _favoriteCouponIds.contains(couponId);

    if (isFavorited) {
      await supabase
          .from('favorites')
          .delete()
          .eq('user_id', user.id)
          .eq('coupon_id', couponId);
    } else {
      await supabase.from('favorites').insert({
        'user_id': user.id,
        'coupon_id': couponId,
      });
    }

    _loadFavorites();
  }

  bool _isFavorited(String couponId) {
    return _favoriteCouponIds.contains(couponId);
  }

  void _onItemTapped(int index) {
    if (_currentIndex == index) return;

    Widget screen;
    switch (index) {
      case 0:
        screen = const HomeScreen();
        break;
      case 2:
        screen = const RewardsScreen();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Explore Vendors"),
        backgroundColor: const Color.fromARGB(255, 221, 178, 49),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: _selectedCategory,
              isExpanded: true,
              items: categories.map((value) {
                return DropdownMenuItem(value: value, child: Text(value));
              }).toList(),
              onChanged: (val) {
                setState(() => _selectedCategory = val!);
                _fetchVendors();
              },
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: _selectedLocation,
              isExpanded: true,
              items: locations.map((value) {
                return DropdownMenuItem(value: value, child: Text(value));
              }).toList(),
              onChanged: (val) {
                setState(() => _selectedLocation = val!);
                _fetchVendors();
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _vendors.isEmpty
                  ? const Center(child: Text("No vendors found."))
                  : ListView.builder(
                      itemCount: _vendors.length,
                      itemBuilder: (context, index) {
                        final vendor = _vendors[index];
                        final coupons = vendor['coupons'] ?? [];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          color: const Color.fromARGB(255, 247, 234, 189),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  vendor['username'] ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                ...coupons.map<Widget>((coupon) {
                                  return ListTile(
                                    title: Text("Code: ${coupon['code']}"),
                                    subtitle: Text("${coupon['discount']}% off"),
                                    trailing: IconButton(
                                      icon: Icon(
                                        _isFavorited(coupon['id'])
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: Colors.red,
                                      ),
                                      onPressed: () =>
                                          _toggleFavorite(coupon['id']),
                                    ),
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 221, 178, 49),
        currentIndex: _currentIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white60,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Local Treasures',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
        ],
      ),
    );
  }
}
