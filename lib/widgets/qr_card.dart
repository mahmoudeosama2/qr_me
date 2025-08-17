import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_generator_flutter/models/qr_code_model.dart';
import 'package:qr_generator_flutter/routes/app_routes.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

class QRCard extends StatelessWidget {
  final QRCodeModel qrCode;
  final VoidCallback onView;
  final VoidCallback onDelete;

  const QRCard({
    Key? key,
    required this.qrCode,
    required this.onView,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color foregroundColor = _parseColor(qrCode.color);
    Color backgroundColor = _parseColor(qrCode.backgroundColor);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          // QR Code Preview
          Container(
            width: 120,
            height: 120,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: QrImageView(
              data: qrCode.text,
              version: QrVersions.auto,
              foregroundColor: foregroundColor,
              backgroundColor: backgroundColor,
            ),
          ),
          const SizedBox(height: 12),
          
          // Title and Type
          Text(
            qrCode.title ?? 'QR Code',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            qrCode.type.toUpperCase(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          
          // Content Preview
          Text(
            qrCode.text.length > 30 
                ? '${qrCode.text.substring(0, 30)}...'
                : qrCode.text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white60,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          
          // Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.visibility, size: 14, color: Colors.white70),
                  const SizedBox(width: 4),
                  Text(
                    '${qrCode.viewCount} views',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              Text(
                DateFormat('MMM dd').format(qrCode.createdAt),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    onView();
                    Get.toNamed(AppRoutes.QR_DETAIL, arguments: qrCode);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.withOpacity(0.8),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.visibility, size: 16),
                      const SizedBox(width: 4),
                      const Text('View', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                icon: Icons.copy,
                color: Colors.purple,
                onPressed: () => _copyToClipboard(qrCode.text),
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                icon: Icons.share,
                color: Colors.green,
                onPressed: () => _shareQRCode(qrCode),
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                icon: Icons.delete,
                color: Colors.red,
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 36,
      height: 36,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.8),
          foregroundColor: Colors.white,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Icon(icon, size: 16),
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

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    Get.snackbar(
      'Copied',
      'Text copied to clipboard',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void _shareQRCode(QRCodeModel qrCode) {
    Share.share(
      'Check out this QR code: ${qrCode.text}',
      subject: qrCode.title ?? 'QR Code',
    );
  }
}