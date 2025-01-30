import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:jvec/controllers/map_controllers.dart';

class MapScreen extends StatelessWidget {
  final RideMapController controller = Get.put(RideMapController());

  MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Obx(() => FlutterMap(
                mapController: controller.mapController,
                options: MapOptions(
                  initialCenter:
                      controller.currentLocation.value ?? const LatLng(0, 0),
                  initialZoom: 15,
                  onTap: (tapPosition, point) => controller.onMapTap(point),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.jvec',
                  ),
                  Obx(() => MarkerLayer(
                        markers: [
                          if (controller.currentLocation.value != null)
                            Marker(
                              point: controller.currentLocation.value!,
                              width: 40,
                              height: 40,
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.blue,
                                size: 40,
                              ),
                            ),
                          if (controller.pickupLocation.value != null)
                            Marker(
                              point: controller.pickupLocation.value!,
                              width: 40,
                              height: 40,
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.green,
                                size: 40,
                              ),
                            ),
                          if (controller.dropoffLocation.value != null)
                            Marker(
                              point: controller.dropoffLocation.value!,
                              width: 40,
                              height: 40,
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 40,
                              ),
                            ),
                        ],
                      )),
                ],
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
            bottom: 100,
            right: 50,
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
