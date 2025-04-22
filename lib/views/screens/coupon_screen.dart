import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urban_treasure/views/screens/business_homescreen.dart';
class CouponScreen extends StatefulWidget {
  const CouponScreen({super.key});

  @override
  State<CouponScreen> createState() => _CouponScreenState();
}

class _CouponScreenState extends State<CouponScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _discountController = TextEditingController();
  bool _isLoading = false;
  int _currentIndex = 1;
  List<Map<String, dynamic>> _coupons = [];

  @override
  void initState() {
    super.initState();
    _fetchCoupons();
  }

  Future<void> _fetchCoupons() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final response = await Supabase.instance.client
        .from('coupons')
        .select()
        .eq('vendor_id', user.id);

    setState(() {
      _coupons = List<Map<String, dynamic>>.from(response);
    });
  }

  Future<void> _addCoupon() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception("User not logged in.");

      final code = _codeController.text.trim();
      final discount = double.parse(_discountController.text.trim());

      await Supabase.instance.client.from('coupons').insert({
        'vendor_id': user.id,
        'code': code,
        'discount': discount,
      });

      _codeController.clear();
      _discountController.clear();

      await _fetchCoupons();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Coupon added successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
Future<void> _deleteCoupon(String couponId) async {
  try {
    await Supabase.instance.client
        .from('coupons')
        .delete()
        .eq('id', couponId);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Coupon deleted")),
    );

    setState(() {
      _coupons.removeWhere((coupon) => coupon['id'] == couponId);
    });
  } catch (e) {
    debugPrint("Delete error: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failed to delete: $e")),
    );
  }
}



  Future<void> _editCoupon(Map<String, dynamic> coupon) async {
  _codeController.text = coupon['code'];
  _discountController.text = coupon['discount'].toString();

  showDialog(
    context: context,
    builder: (_) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text("Edit Coupon"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _codeController,
                  decoration: const InputDecoration(labelText: 'Coupon Code'),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _discountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Discount Amount'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  final updatedCode = _codeController.text.trim();
                  final updatedDiscount =
                      double.tryParse(_discountController.text.trim()) ?? 0;

                  await Supabase.instance.client
                      .from('coupons')
                      .update({
                        'code': updatedCode,
                        'discount': updatedDiscount,
                      })
                      .eq('id', coupon['id']);

                  _codeController.clear();
                  _discountController.clear();

                  if (!mounted) return;
                  Navigator.of(context).pop();
                  await _fetchCoupons();
                },
                child: const Text("Update"),
              ),
            ],
          );
        },
      );
    },
  );
}


  void _onTabTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BusinessHomeScreen()),
      );
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Manage Coupons"),
        backgroundColor: const Color.fromARGB(255, 221, 178, 49),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _codeController,
                    decoration: const InputDecoration(
                      labelText: 'Coupon Code',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Enter a coupon code'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _discountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Discount Amount (%)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final number = double.tryParse(value ?? '');
                      if (number == null || number <= 0) {
                        return 'Enter a valid discount amount';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _addCoupon,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Add Coupon"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color.fromARGB(255, 221, 178, 49),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Your Coupons",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ..._coupons.map((coupon) => ListTile(
                  title: Text(coupon['code']),
                  subtitle: Text("${coupon['discount']}% off"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _editCoupon(coupon),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteCoupon(coupon['id']),

                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 221, 178, 49),
        currentIndex: _currentIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white60,
        onTap: _onTabTapped,
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
      ),
    );
  }
}
