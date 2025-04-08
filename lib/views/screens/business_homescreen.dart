import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urban_treasure/views/screens/business_profile.dart';
import 'package:urban_treasure/views/screens/coupon_screen.dart';

class BusinessHomeScreen extends StatefulWidget {
  const BusinessHomeScreen({super.key});

  @override
  State<BusinessHomeScreen> createState() => _BusinessHomeScreenState();
}

class _BusinessHomeScreenState extends State<BusinessHomeScreen> {
  int _currentIndex = 0;
  String? _companyName;
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _loadCompanyName();
  }

  Future<void> _loadCompanyName() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      final response = await supabase
          .from('profiles')
          .select('username')
          .eq('id', user.id)
          .maybeSingle();

      if (mounted && response != null && response['username'] != null) {
        setState(() {
          _companyName = response['username'];
        });
      }
    }
  }

  /// Fetch total favorites count for all coupons of this vendor.
  Future<int> _fetchFavoritesCount() async {
    final user = supabase.auth.currentUser;
    if (user == null) return 0;

    // Get coupon IDs for this vendor.
    final couponsResponse = await supabase
        .from('coupons')
        .select('id')
        .eq('vendor_id', user.id);
    List<String> couponIds = List<Map<String, dynamic>>.from(couponsResponse)
        .map((coupon) => coupon['id'] as String)
        .toList();

    if (couponIds.isEmpty) return 0;

    // Build a filter string for the coupon IDs.
    final quotedIds = couponIds.map((id) => '"$id"').join(',');
    final filterString = '($quotedIds)';

    // Fetch favorites for these coupons.
    final favoritesResponse = await supabase
        .from('favorites')
        .select('coupon_id')
        .filter('coupon_id', 'in', filterString);

    int count = List<Map<String, dynamic>>.from(favoritesResponse).length;
    return count;
  }

  /// Fetch favorites data per coupon as a List of maps,
  /// each containing the coupon code and a favorites count.
  Future<List<Map<String, dynamic>>> _fetchFavoritesData() async {
    final user = supabase.auth.currentUser;
    if (user == null) return [];

    // Fetch this vendor's coupons.
    final couponsResponse = await supabase
        .from('coupons')
        .select('id, code')
        .eq('vendor_id', user.id);
    final coupons = List<Map<String, dynamic>>.from(couponsResponse);
    List<Map<String, dynamic>> data = [];

    // For each coupon, count the favorites.
    for (var coupon in coupons) {
      final countResponse = await supabase
          .from('favorites')
          .select('coupon_id')
          .eq('coupon_id', coupon['id']);
      int count = List<Map<String, dynamic>>.from(countResponse).length;
      data.add({'code': coupon['code'], 'count': count});
    }
    return data;
  }

  /// Builds a simple bar graph from the list of coupon favorites data.
  Widget buildFavoritesGraph(List<Map<String, dynamic>> data) {
    if (data.isEmpty) {
      return const Text("No favorites data available.");
    }
    // Determine the maximum count to scale the bars.
    int maxCount = data
        .map((item) => item['count'] as int)
        .fold(0, (prev, element) => element > prev ? element : prev);
    double maxHeight = 150.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: data.map((item) {
        int count = item['count'] as int;
        double barHeight = maxCount == 0 ? 0 : (count / maxCount) * maxHeight;
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: 20,
              height: barHeight,
              color: Colors.blueAccent,
            ),
            const SizedBox(height: 4),
            Text(item['code'], style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Text("$count", style: const TextStyle(fontSize: 12)),
          ],
        );
      }).toList(),
    );
  }

  void _onItemTapped(int index) {
    if (_currentIndex == index) return;

    setState(() {
      _currentIndex = index;
    });

    Widget screen;
    switch (index) {
      case 0:
        screen = const BusinessHomeScreen();
        break;
      case 1:
        screen = const CouponScreen();
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color.fromARGB(255, 221, 178, 49),
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.account_circle),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BusinessProfileScreen(),
                  ),
                );
              },
            ),
          ],
          title: const Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text(
              'Urban Treasures',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.symmetric(horizontal: 14.0, vertical: 20.0),
          child: Column(
            children: [
              // Vendor Welcome and Favorites Graph Section.
              FutureBuilder<int>(
                future: _fetchFavoritesCount(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  int favoritesCount = snapshot.data ?? 0;
                  return Column(
                    children: [
                      Text(
                        _companyName != null
                            ? 'Welcome $_companyName!'
                            : 'Welcome Vendor!',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Your coupons have been favorited by $favoritesCount user(s)",
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: _fetchFavoritesData(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }
                          final data = snapshot.data ?? [];
                          return buildFavoritesGraph(data);
                        },
                      ),
                      const SizedBox(height: 30),
                    ],
                  );
                },
              ),
              // Additional Business Analytics Section with Purchase Button.
              const Text(
                'Additional Business Analytics',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 221, 178, 49),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Purchase Complete")),
                  );
                },
                child: const Text(
                  "Purchase \$TBD",
                  style: TextStyle(fontWeight: FontWeight.bold),),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 221, 178, 49),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard),
            label: 'Coupons',
          ),
        ],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white60,
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
