import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:urban_treasure/views/screens/home_screen.dart';
import 'package:urban_treasure/views/screens/rewards_screen.dart';

const String kGoogleApiKey = "YOUR_GOOGLE_API_KEY";

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  LatLng _initialPosition = const LatLng(38.9072, -77.0369); // Default to DC
  String? _distance;
  String? _duration;
  int _currentIndex = 1;

  @override
  void initState() {
    super.initState();
    _setInitialPosition();
  }

  Future<void> _setInitialPosition() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _initialPosition = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      debugPrint("Could not get location, using DC fallback: $e");
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _moveCamera(_initialPosition);
  }

  void _moveCamera(LatLng target) {
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: 14.0),
      ),
    );
  }

  Future<void> _getDistanceTo(LatLng destination) async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final origin = '${position.latitude},${position.longitude}';
      final dest = '${destination.latitude},${destination.longitude}';

      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/distancematrix/json?origins=$origin&destinations=$dest&mode=driving&units=imperial&key=$kGoogleApiKey');

      final response = await http.get(url);
      final data = jsonDecode(response.body);

      if (data['status'] == 'OK' &&
          data['rows'][0]['elements'][0]['status'] == 'OK') {
        final element = data['rows'][0]['elements'][0];
        setState(() {
          _distance = element['distance']['text'];
          _duration = element['duration']['text'];
        });
      } else {
        debugPrint("Failed to fetch distance: ${data['status']}");
      }
    } catch (e) {
      debugPrint("Error fetching distance: $e");
    }
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
        title: const Text("Map Screen"),
        backgroundColor: const Color.fromARGB(255, 221, 178, 49),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 12.0,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          if (_distance != null && _duration != null)
            Positioned(
              bottom: 72,
              left: 16,
              right: 16,
              child: Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    'Distance: $_distance | Duration: $_duration',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            )
        ],
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
            label: 'Map',
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
