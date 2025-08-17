import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_generator_flutter/controllers/qr_controller.dart';
import 'package:qr_generator_flutter/widgets/gradient_background.dart';
import 'package:qr_generator_flutter/widgets/qr_card.dart';
import 'package:qr_generator_flutter/routes/app_routes.dart';

class MyQRsView extends GetView<QRController> {
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final RxString selectedFilter = 'all'.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My QR Codes'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => Get.toNamed(AppRoutes.CREATE_QR),
          ),
        ],
      ),
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildSearchAndFilter(context),
              Expanded(child: _buildQRList(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: searchController,
            onChanged: (value) => searchQuery.value = value,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search QR codes...',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.5)),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', 'all'),
                _buildFilterChip('Text', 'text'),
                _buildFilterChip('URL', 'url'),
                _buildFilterChip('Email', 'email'),
                _buildFilterChip('WiFi', 'wifi'),
                _buildFilterChip('Contact', 'contact'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return Obx(() => Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selectedFilter.value == value,
        onSelected: (selected) {
          selectedFilter.value = value;
        },
        backgroundColor: Colors.white.withOpacity(0.1),
        selectedColor: Colors.white.withOpacity(0.3),
        labelStyle: TextStyle(
          color: selectedFilter.value == value ? Colors.white : Colors.white.withOpacity(0.7),
        ),
        side: BorderSide(color: Colors.white.withOpacity(0.2)),
      ),
    ));
  }

  Widget _buildQRList(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: Colors.white),
        );
      }

      // Filter QR codes based on search and filter
      var filteredQRs = controller.qrCodes.where((qr) {
        bool matchesSearch = searchQuery.value.isEmpty ||
            qr.title?.toLowerCase().contains(searchQuery.value.toLowerCase()) == true ||
            qr.text.toLowerCase().contains(searchQuery.value.toLowerCase());
        
        bool matchesFilter = selectedFilter.value == 'all' || qr.type == selectedFilter.value;
        
        return matchesSearch && matchesFilter;
      }).toList();

      if (filteredQRs.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.qr_code_2,
                size: 64,
                color: Colors.white.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                controller.qrCodes.isEmpty ? 'No QR codes created yet' : 'No QR codes match your search',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              if (controller.qrCodes.isEmpty) ...[
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Get.toNamed(AppRoutes.CREATE_QR),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Theme.of(context).primaryColor,
                  ),
                  child: const Text('Create Your First QR Code'),
                ),
              ],
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: filteredQRs.length,
        itemBuilder: (context, index) {
          final qr = filteredQRs[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: QRCard(
              qrCode: qr,
              onView: () => controller.incrementViewCount(qr.id),
              onDelete: () => _showDeleteDialog(context, qr.id),
            ),
          );
        },
      );
    });
  }

  void _showDeleteDialog(BuildContext context, String qrId) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete QR Code'),
        content: const Text('Are you sure you want to delete this QR code? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteQRCode(qrId);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}