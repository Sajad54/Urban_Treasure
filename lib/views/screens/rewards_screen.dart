import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urban_treasure/views/screens/home_screen.dart';
import 'package:urban_treasure/views/screens/vendor_screen.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _favoritedCoupons = [];
  int _currentIndex = 2; // Rewards is the third tab.

  @override
  void initState() {
    super.initState();
    _fetchFavoritedCoupons();
  }

  /// Fetches the favorited coupon IDs for the current user, then queries the coupons table.
  ///
  /// The query leverages foreign table embedding to fetch vendor details (username and location)
  /// from the profiles table. We use the alias syntax "vendor:profiles(...)" which
  /// assumes that your foreign key from coupons.vendor_id to profiles.id is properly configured.
  Future<void> _fetchFavoritedCoupons() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    // First, fetch the coupon IDs that the user favorited.
    final favoritesResponse = await supabase
        .from('favorites')
        .select('coupon_id')
        .eq('user_id', user.id);

    final List<String> couponIds = List<Map<String, dynamic>>.from(favoritesResponse)
        .map((fav) => fav['coupon_id'] as String)
        .toList();

    if (couponIds.isEmpty) {
      setState(() {
        _favoritedCoupons = [];
      });
      return;
    }

    // Build a comma-separated list of quoted coupon IDs (e.g. "id1","id2",...)
    final quotedIds = couponIds.map((id) => '"$id"').join(',');
    final filterString = '($quotedIds)';

    // Query the coupons table.
    // Using foreign table embedding, we retrieve vendor details by aliasing the "profiles" table as "vendor".
    final couponsResponse = await supabase
        .from('coupons')
        .select('id, code, discount, vendor:profiles(username, location)')
        .filter('id', 'in', filterString);

    setState(() {
      _favoritedCoupons = List<Map<String, dynamic>>.from(couponsResponse);
    });
  }

  /// Removes a coupon from the favorites, then refreshes the list.
  Future<void> _removeFavorite(String couponId) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    await supabase
        .from('favorites')
        .delete()
        .eq('user_id', user.id)
        .eq('coupon_id', couponId);

    await _fetchFavoritedCoupons();
  }

  /// Handles bottom navigation tap.
  void _onItemTapped(int index) {
    if (_currentIndex == index) return;
    Widget screen;
    switch (index) {
      case 0:
        screen = const HomeScreen();
        break;
      case 1:
        screen = const VendorScreen();
        break;
      case 2:
        return; // Already on RewardsScreen.
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
        title: const Text("Rewards"),
        backgroundColor: const Color.fromARGB(255, 221, 178, 49),
      ),
      body: _favoritedCoupons.isEmpty
          ? const Center(child: Text("No favorited coupons found."))
          : ListView.builder(
              itemCount: _favoritedCoupons.length,
              itemBuilder: (context, index) {
                final coupon = _favoritedCoupons[index];
                // Retrieve the embedded vendor data.
                final vendor = coupon['vendor'] ?? {};
                final vendorName = vendor['username'] ?? 'Unknown Vendor';
                final vendorLocation = vendor['location'] ?? '';

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Vendor: $vendorName",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (vendorLocation.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
                            child: Text("Location: $vendorLocation"),
                          ),
                        ListTile(
                          title: Text("Code: ${coupon['code']}"),
                          subtitle: Text("Discount: ${coupon['discount']}%"),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _removeFavorite(coupon['id']),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
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
            label: 'Vendors',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard),
            label: 'Rewards',
          ),
        ],
      ),
    );
  }
}
