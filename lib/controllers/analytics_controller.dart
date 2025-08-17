import 'package:get/get.dart';
import 'package:qr_generator_flutter/models/qr_code_model.dart';
import 'package:qr_generator_flutter/services/firebase_service.dart';

class AnalyticsController extends GetxController {
  var qrCodes = <QRCodeModel>[].obs;
  var isLoading = false.obs;
  
  // Analytics data
  var totalQRs = 0.obs;
  var totalViews = 0.obs;
  var averageViews = 0.obs;
  var thisMonthQRs = 0.obs;
  var mostViewedQR = Rxn<QRCodeModel>();
  var recentActivity = <QRCodeModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchAnalytics();
  }

  Future<void> fetchAnalytics() async {
    try {
      isLoading.value = true;
      List<QRCodeModel> codes = await FirebaseService.getAllQRCodes();
      qrCodes.value = codes;
      _calculateAnalytics();
    } catch (e) {
      print('Failed to fetch analytics: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _calculateAnalytics() {
    totalQRs.value = qrCodes.length;
    totalViews.value = qrCodes.fold(0, (sum, qr) => sum + qr.viewCount);
    averageViews.value = totalQRs.value > 0 ? (totalViews.value / totalQRs.value).round() : 0;
    
    // Calculate this month's QR codes
    DateTime now = DateTime.now();
    thisMonthQRs.value = qrCodes.where((qr) {
      return qr.createdAt.month == now.month && qr.createdAt.year == now.year;
    }).length;
    
    // Find most viewed QR
    if (qrCodes.isNotEmpty) {
      mostViewedQR.value = qrCodes.reduce((a, b) => a.viewCount > b.viewCount ? a : b);
    }
    
    // Recent activity (last 5 QR codes)
    recentActivity.value = qrCodes.take(5).toList();
  }

  // Get QR codes created in the last 7 days
  List<QRCodeModel> getRecentQRCodes() {
    DateTime weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return qrCodes.where((qr) => qr.createdAt.isAfter(weekAgo)).toList();
  }

  // Get top performing QR codes
  List<QRCodeModel> getTopPerformingQRs({int limit = 5}) {
    List<QRCodeModel> sorted = List.from(qrCodes);
    sorted.sort((a, b) => b.viewCount.compareTo(a.viewCount));
    return sorted.take(limit).toList();
  }
}