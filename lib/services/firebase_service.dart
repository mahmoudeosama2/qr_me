import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_generator_flutter/models/qr_code_model.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _qrCodesCollection = 'qrcodes';

  // Create QR Code
  static Future<String> createQRCode(QRCodeModel qrCode) async {
    try {
      DocumentReference docRef = await _firestore
          .collection(_qrCodesCollection)
          .add(qrCode.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create QR code: $e');
    }
  }

  // Get all QR codes
  static Future<List<QRCodeModel>> getAllQRCodes() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(_qrCodesCollection)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => QRCodeModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch QR codes: $e');
    }
  }

  // Get QR codes by user ID
  static Future<List<QRCodeModel>> getQRCodesByUser(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(_qrCodesCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => QRCodeModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch user QR codes: $e');
    }
  }

  // Update QR code view count
  static Future<void> incrementViewCount(String qrId) async {
    try {
      DocumentReference docRef = _firestore.collection(_qrCodesCollection).doc(qrId);
      await docRef.update({
        'viewCount': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('Failed to increment view count: $e');
    }
  }

  // Delete QR code
  static Future<void> deleteQRCode(String qrId) async {
    try {
      await _firestore.collection(_qrCodesCollection).doc(qrId).delete();
    } catch (e) {
      throw Exception('Failed to delete QR code: $e');
    }
  }

  // Get QR code by ID
  static Future<QRCodeModel?> getQRCodeById(String qrId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(_qrCodesCollection)
          .doc(qrId)
          .get();

      if (doc.exists) {
        return QRCodeModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch QR code: $e');
    }
  }

  // Stream QR codes for real-time updates
  static Stream<List<QRCodeModel>> streamQRCodes() {
    return _firestore
        .collection(_qrCodesCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => QRCodeModel.fromFirestore(doc))
            .toList());
  }
}