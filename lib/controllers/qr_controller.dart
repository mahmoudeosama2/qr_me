import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_generator_flutter/models/qr_code_model.dart';
import 'package:qr_generator_flutter/services/firebase_service.dart';

class QRController extends GetxController {
  // Form controllers
  final textController = TextEditingController();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  // Observable variables
  var qrCodes = <QRCodeModel>[].obs;
  var isLoading = false.obs;
  var selectedType = QRType.text.obs;
  var selectedColor = const Color(0xFF000000).obs;
  var selectedBackgroundColor = const Color(0xFFFFFFFF).obs;
  var selectedSize = 200.obs;

  // Analytics data
  var totalQRs = 0.obs;
  var totalViews = 0.obs;
  var mostViewedQR = Rxn<QRCodeModel>();

  @override
  void onInit() {
    super.onInit();
    fetchQRCodes();
  }

  @override
  void onClose() {
    textController.dispose();
    titleController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  // Fetch all QR codes
  Future<void> fetchQRCodes() async {
    try {
      isLoading.value = true;
      List<QRCodeModel> codes = await FirebaseService.getAllQRCodes();
      qrCodes.value = codes;
      _calculateAnalytics();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch QR codes: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Create new QR code
  Future<void> createQRCode() async {
    if (textController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter content for your QR code',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      
      QRCodeModel newQR = QRCodeModel(
        id: '',
        text: textController.text.trim(),
        type: selectedType.value.name,
        title: titleController.text.trim().isEmpty ? null : titleController.text.trim(),
        description: descriptionController.text.trim().isEmpty ? null : descriptionController.text.trim(),
        color: '#${selectedColor.value.value.toRadixString(16).substring(2)}',
        backgroundColor: '#${selectedBackgroundColor.value.value.toRadixString(16).substring(2)}',
        size: selectedSize.value,
        createdAt: DateTime.now(),
        viewCount: 0,
      );

      String id = await FirebaseService.createQRCode(newQR);
      
      // Clear form
      clearForm();
      
      // Refresh list
      await fetchQRCodes();
      
      Get.snackbar(
        'Success',
        'QR code created successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
      Get.back();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create QR code: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Delete QR code
  Future<void> deleteQRCode(String qrId) async {
    try {
      await FirebaseService.deleteQRCode(qrId);
      await fetchQRCodes();
      
      Get.snackbar(
        'Success',
        'QR code deleted successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete QR code: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Increment view count
  Future<void> incrementViewCount(String qrId) async {
    try {
      await FirebaseService.incrementViewCount(qrId);
      await fetchQRCodes();
    } catch (e) {
      print('Failed to increment view count: $e');
    }
  }

  // Clear form
  void clearForm() {
    textController.clear();
    titleController.clear();
    descriptionController.clear();
    selectedType.value = QRType.text;
    selectedColor.value = const Color(0xFF000000);
    selectedBackgroundColor.value = const Color(0xFFFFFFFF);
    selectedSize.value = 200;
  }

  // Calculate analytics
  void _calculateAnalytics() {
    totalQRs.value = qrCodes.length;
    totalViews.value = qrCodes.fold(0, (sum, qr) => sum + qr.viewCount);
    
    if (qrCodes.isNotEmpty) {
      mostViewedQR.value = qrCodes.reduce((a, b) => a.viewCount > b.viewCount ? a : b);
    }
  }

  // Filter QR codes by type
  List<QRCodeModel> getQRCodesByType(String type) {
    if (type == 'all') return qrCodes;
    return qrCodes.where((qr) => qr.type == type).toList();
  }

  // Search QR codes
  List<QRCodeModel> searchQRCodes(String query) {
    if (query.isEmpty) return qrCodes;
    return qrCodes.where((qr) {
      return qr.title?.toLowerCase().contains(query.toLowerCase()) == true ||
             qr.text.toLowerCase().contains(query.toLowerCase()) ||
             qr.type.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }
}