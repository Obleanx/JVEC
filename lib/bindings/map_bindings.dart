import 'package:get/get.dart';
import 'package:jvec/controllers/map_controllers.dart';

class MapBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(MapController());
  }
}
