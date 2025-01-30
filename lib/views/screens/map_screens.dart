import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:jvec/controllers/map_controllers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends GetView<MapController> {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Obx(() => GoogleMap(
                initialCameraPosition: CameraPosition(
                  target:
                      controller.currentLocation.value ?? const LatLng(0, 0),
                  zoom: 15,
                ),
                onMapCreated: (GoogleMapController mapController) {
                  controller.mapController = mapController;
                },
                markers: controller.markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                onTap: controller.onMapTap,
              )),
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text('Tap on map to select:'),
                    Obx(() => Text(
                          controller.pickupLocation.value == null
                              ? '1. Pickup Location'
                              : controller.dropoffLocation.value == null
                                  ? '2. Dropoff Location'
                                  : 'Locations Selected',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        )),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            right: 20,
            child: FloatingActionButton(
              onPressed: controller.getCurrentLocation,
              child: const Icon(Icons.my_location),
            ),
          ),
          Obx(
            () => controller.isSearchingDriver.value
                ? const Center(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Finding nearby drivers...'),
                          ],
                        ),
                      ),
                    ),
                  )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }
}
