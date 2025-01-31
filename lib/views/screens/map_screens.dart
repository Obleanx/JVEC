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
                  // Builder(
                  // builder: (context) => TileLayer(
                  // urlTemplate:
                  // 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                  // userAgentPackageName: 'com.example.jvec',
                  // retinaMode: RetinaMode.isHighDensity(context),
                  // ),
                  // TileLayer(
                  // urlTemplate:
                  //https://tile.openstreetmap.org
                  // 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                  // userAgentPackageName: 'com.example.jvec',
                  // retinaMode: true,
                  // ),
                  // ),

                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.jvec',
                    additionalOptions: const {
                      'useCache': 'true',
                      'maxZoom': '19',
                    },
                  ),
                  Obx(() => MarkerLayer(
                        markers: [
                          if (controller.currentLocation.value != null)
                            Marker(
                              point: controller.currentLocation.value!,
                              width: 40,
                              height: 40,
                              child: const Icon(Icons.location_on,
                                  color: Colors.blue, size: 40),
                            ),
                          if (controller.pickupLocation.value != null)
                            Marker(
                              point: controller.pickupLocation.value!,
                              width: 40,
                              height: 40,
                              child: const Icon(Icons.location_on,
                                  color: Colors.green, size: 40),
                            ),
                          if (controller.dropoffLocation.value != null)
                            Marker(
                              point: controller.dropoffLocation.value!,
                              width: 40,
                              height: 40,
                              child: const Icon(Icons.location_on,
                                  color: Colors.red, size: 40),
                            ),
                        ],
                      )),
                ],
              )),
          // Enhanced Top Card
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.withOpacity(0.6),
                      const Color(0xFF1BFFFF)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Where would you like to go?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Obx(() => Text(
                          controller.pickupLocation.value == null
                              ? '📍 Tap to select pickup location'
                              : controller.dropoffLocation.value == null
                                  ? '🎯 Tap to select destination'
                                  : '✨ Perfect! Ready to find your ride',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ),
          // Location Button
          Positioned(
            bottom: 100,
            right: 20,
            child: FloatingActionButton(
              onPressed: controller.getCurrentLocation,
              elevation: 4,
              backgroundColor: Colors.blue.withOpacity(0.6),
              child: const Icon(Icons.my_location, color: Colors.white),
            ),
          ),
          // Enhanced Loading Indicator
          Obx(
            () => controller.isSearchingDriver.value
                ? Container(
                    color: Colors.black54,
                    child: Center(
                      child: Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.withOpacity(0.6),
                                const Color(0xFF1BFFFF)
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 60,
                                height: 60,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                  strokeWidth: 3,
                                ),
                              ),
                              SizedBox(height: 24),
                              Text(
                                'Finding your perfect ride...',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Connecting you with nearby drivers',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
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
