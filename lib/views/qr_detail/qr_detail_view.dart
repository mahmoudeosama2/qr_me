import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_generator_flutter/models/qr_code_model.dart';
import 'package:qr_generator_flutter/widgets/gradient_background.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

class QRDetailView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final QRCodeModel qrCode = Get.arguments as QRCodeModel;

    return Scaffold(
      appBar: AppBar(
        title: Text(qrCode.title ?? 'QR Code'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () => _shareQRCode(qrCode),
          ),
        ],
      ),
      body: GradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildQRCodeSection(context, qrCode),
                const SizedBox(height: 24),
                _buildDetailsSection(context, qrCode),
                const SizedBox(height: 24),
                _buildStatsSection(context, qrCode),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQRCodeSection(BuildContext context, QRCodeModel qrCode) {
    Color foregroundColor = _parseColor(qrCode.color);
    Color backgroundColor = _parseColor(qrCode.backgroundColor);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: QrImageView(
              data: qrCode.text,
              version: QrVersions.auto,
              size: 250.0,
              foregroundColor: foregroundColor,
              backgroundColor: backgroundColor,
            ),
          ),
          if (qrCode.title != null) ...[
            const SizedBox(height: 16),
            Text(
              qrCode.title!,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailsSection(BuildContext context, QRCodeModel qrCode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Details',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(context, 'Type', qrCode.type.toUpperCase()),
          _buildDetailRow(context, 'Content', qrCode.text),
          if (qrCode.description != null)
            _buildDetailRow(context, 'Description', qrCode.description!),
          _buildDetailRow(context, 'Created', DateFormat('MMM dd, yyyy').format(qrCode.createdAt)),
          _buildDetailRow(context, 'Size', '${qrCode.size}px'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, QRCodeModel qrCode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistics',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  'Views',
                  qrCode.viewCount.toString(),
                  Icons.visibility,
                  const Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  context,
                  'Age',
                  '${DateTime.now().difference(qrCode.createdAt).inDays} days',
                  Icons.calendar_today,
                  const Color(0xFF6366F1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.black;
    }
  }

  void _shareQRCode(QRCodeModel qrCode) {
    Share.share(
      'Check out this QR code: ${qrCode.text}',
      subject: qrCode.title ?? 'QR Code',
    );
  }
}