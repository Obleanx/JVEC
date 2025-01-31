import 'dart:math';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:jvec/models/drivers_models.dart';
// ignore_for_file: deprecated_member_use

class RideMapController extends GetxController {
  final currentLocation = Rx<LatLng?>(null);
  final pickupLocation = Rx<LatLng?>(null);
  final dropoffLocation = Rx<LatLng?>(null);
  final currentAddress = ''.obs;
  final pickupAddress = ''.obs;
  final dropoffAddress = ''.obs;
  final isLoading = false.obs;
  final driverFound = false.obs;
  final isSearchingDriver = false.obs;
  final mapController = MapController();

  static const basePrice = 1500.0;
  static const pricePerKm = 1000.0;

  @override
  void onInit() {
    super.onInit();
    getCurrentLocation();
  }

  Future<String> getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return '${place.street}, ${place.subLocality}, ${place.locality}';
      }
      return 'Unknown location';
    } catch (e) {
      return 'Error getting address';
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      isLoading.value = true;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar(
            'Error',
            'Location permission is required',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar(
          'Error',
          'Location permissions are permanently denied. Enable them in settings.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return;
      }

      // Ensure high accuracy mode
      await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).then((Position position) {
        currentLocation.value = LatLng(position.latitude, position.longitude);
        getAddressFromLatLng(currentLocation.value!).then((address) {
          currentAddress.value = address;
        });

        // Move map to location
        mapController.move(currentLocation.value!, 15);
      });
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to get location: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> onMapTap(LatLng location) async {
    if (pickupLocation.value == null) {
      pickupLocation.value = location;
      // Get pickup address
      pickupAddress.value = await getAddressFromLatLng(location);
      Get.snackbar(
        'Location Selected',
        'Pickup location set at: ${pickupAddress.value}\nNow tap for destination.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } else if (dropoffLocation.value == null) {
      dropoffLocation.value = location;
      // Get dropoff address
      dropoffAddress.value = await getAddressFromLatLng(location);
      Get.snackbar(
        'Perfect!',
        'Destination set at: ${dropoffAddress.value}',
        backgroundColor: Colors.blue.withOpacity(0.6),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      showRideRequestButton();
    }
  }

  Widget _buildLocationRow(
      IconData icon, Color color, String title, String? address) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (address != null &&
                  address.isNotEmpty) // Only show if not empty
                Text(
                  address,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ],
    );
  }

// Add these methods to your RideMapController class:

// Calculate distance between two points
  double calculateDistance(LatLng start, LatLng end) {
    var p = 0.017453292519943295; // Math.PI / 180
    var c = cos;
    var a = 0.5 -
        c((end.latitude - start.latitude) * p) / 2 +
        c(start.latitude * p) *
            c(end.latitude * p) *
            (1 - c((end.longitude - start.longitude) * p)) /
            2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }

// Calculate price based on distance
  double calculatePrice(double distance) {
    return basePrice + (distance * pricePerKm);
  }

// Helper method to build info cards
  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.blue.withOpacity(0.6), size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  void showRideRequestButton() {
    if (pickupLocation.value == null || dropoffLocation.value == null) return;

    final distance =
        calculateDistance(pickupLocation.value!, dropoffLocation.value!);
    final price = calculatePrice(distance);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Trip Details',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  _buildLocationRow(
                    Icons.my_location,
                    Colors.blue,
                    'Current Location',
                    currentAddress.value.isNotEmpty
                        ? currentAddress.value
                        : '123 Main St, City, Country',
                  ),
                  const Divider(height: 20),
                  _buildLocationRow(
                    Icons.location_on,
                    Colors.green,
                    'Pickup Location',
                    pickupAddress.value.isNotEmpty
                        ? pickupAddress.value
                        : '456 Elm St, City, Country',
                  ),
                  const Divider(height: 20),
                  _buildLocationRow(
                    Icons.location_on,
                    Colors.red,
                    'Dropoff Location',
                    dropoffAddress.value.isNotEmpty
                        ? dropoffAddress.value
                        : '789 Oak St, City, Country',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoCard(
                  'Distance',
                  '${distance.toStringAsFixed(1)} km',
                  Icons.straighten,
                ),
                _buildInfoCard(
                  'Price',
                  '₦${price.toStringAsFixed(2)}',
                  Icons.payments,
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: findDriver,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                elevation: 5,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                'Request Ride',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Future<void> findDriver() async {
    isSearchingDriver.value = true;
    Get.back(); // Close bottom sheet

    // Reduced waiting time
    await Future.delayed(const Duration(seconds: 5));

    if (Random().nextBool()) {
      driverFound.value = true;
      showDriverDetails();
    } else {
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'No Drivers Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E3192),
            ),
          ),
          content: const Text(
            'Would you like to try finding another driver?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
                findDriver();
              },
              child: const Text(
                'Retry',
                style: TextStyle(
                  color: Color(0xFF2E3192),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                resetLocations();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }

    isSearchingDriver.value = false;
  }

  void showDriverDetails() {
    final driver = DriverModel(
      id: '1',
      name: 'John Doe',
      vehicleType: 'Toyota Camry',
      rating: 4.8,
      plateNumber: 'IJK-234',
      photoUrl: 'lib/images/kk10.png',
    );

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Your Driver is Coming!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E3192),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundImage: const AssetImage('lib/images/kk10.png'),
                      backgroundColor:
                          Colors.grey[200], // Fallback background color
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 24, // Adjust size if needed
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          driver.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          driver.vehicleType,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            driver.rating.toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        driver.plateNumber,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: completeRide,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                minimumSize: const Size(double.infinity, 56),
              ),
              child: const Text(
                'Complete Ride',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void completeRide() {
    Get.back();
    Get.snackbar(
      'Thank You!',
      'Thank you for riding with us!',
      //backgroundColor: Colors.green,
      // colorText: Colors.white,
      duration: const Duration(seconds: 6),
      snackPosition: SnackPosition.TOP,
    );
    resetLocations();
  }

  void resetLocations() {
    pickupLocation.value = null;
    dropoffLocation.value = null;
    driverFound.value = false;
  }
}
