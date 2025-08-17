import 'package:get/get.dart';
import 'package:qr_generator_flutter/controllers/home_controller.dart';
import 'package:qr_generator_flutter/controllers/qr_controller.dart';
import 'package:qr_generator_flutter/controllers/analytics_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<QRController>(() => QRController());
    Get.lazyPut<AnalyticsController>(() => AnalyticsController());
  }
}