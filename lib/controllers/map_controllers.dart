import 'dart:math';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:jvec/models/drivers_models.dart';

class RideMapController extends GetxController {
  final currentLocation = Rx<LatLng?>(null);
  final pickupLocation = Rx<LatLng?>(null);
  final dropoffLocation = Rx<LatLng?>(null);
  final isLoading = false.obs;
  final driverFound = false.obs;
  final isSearchingDriver = false.obs;
  final mapController = MapController();

  @override
  void onInit() {
    super.onInit();
    getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    try {
      isLoading.value = true;
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar('Error', 'Location permission is required');
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition();
      currentLocation.value = LatLng(position.latitude, position.longitude);

      // Animate to current location
      mapController.move(currentLocation.value!, 15);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void onMapTap(LatLng location) {
    if (pickupLocation.value == null) {
      pickupLocation.value = location;
    } else if (dropoffLocation.value == null) {
      dropoffLocation.value = location;
      showRideRequestButton();
    }
  }

  void showRideRequestButton() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        height: 200,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const Text(
              'Request Ride',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: findDriver,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Find Driver'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> findDriver() async {
    isSearchingDriver.value = true;
    Get.back(); // Close bottom sheet

    // Simulate finding driver
    await Future.delayed(const Duration(seconds: 15));

    if (Random().nextBool()) {
      driverFound.value = true;
      showDriverDetails();
    } else {
      Get.dialog(
        AlertDialog(
          title: const Text('No Drivers Found'),
          content: const Text('Would you like to retry?'),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
                findDriver();
              },
              child: const Text('Retry'),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                resetLocations();
              },
              child: const Text('Cancel'),
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
      plateNumber: 'ABC 123',
      photoUrl: 'assets/driver.png',
    );

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        height: 300,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const Text(
              'Driver Found!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.person),
              ),
              title: Text(driver.name),
              subtitle: Text(driver.vehicleType),
              trailing: Text('⭐ ${driver.rating}'),
            ),
            Text('Plate Number: ${driver.plateNumber}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: completeRide,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Complete Ride'),
            ),
          ],
        ),
      ),
    );
  }

  void completeRide() {
    Get.back();
    Get.snackbar(
      'Ride Completed',
      'Thank you for riding with us!',
      duration: const Duration(seconds: 3),
    );
    resetLocations();
  }

  void resetLocations() {
    pickupLocation.value = null;
    dropoffLocation.value = null;
    driverFound.value = false;
  }
}
