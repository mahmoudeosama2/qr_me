import 'package:get/get.dart';
import 'package:qr_generator_flutter/routes/app_routes.dart';
import 'package:qr_generator_flutter/views/home/home_view.dart';
import 'package:qr_generator_flutter/views/create_qr/create_qr_view.dart';
import 'package:qr_generator_flutter/views/my_qrs/my_qrs_view.dart';
import 'package:qr_generator_flutter/views/analytics/analytics_view.dart';
import 'package:qr_generator_flutter/views/qr_detail/qr_detail_view.dart';

class AppPages {
  static const INITIAL = AppRoutes.HOME;

  static final routes = [
    GetPage(
      name: AppRoutes.HOME,
      page: () => HomeView(),
    ),
    GetPage(
      name: AppRoutes.CREATE_QR,
      page: () => CreateQRView(),
    ),
    GetPage(
      name: AppRoutes.MY_QRS,
      page: () => MyQRsView(),
    ),
    GetPage(
      name: AppRoutes.ANALYTICS,
      page: () => AnalyticsView(),
    ),
    GetPage(
      name: AppRoutes.QR_DETAIL,
      page: () => QRDetailView(),
    ),
  ];
}