import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/services/firebase_service.dart';
import '../../../../core/theme/app_colors.dart';

class QRCodeScreen extends ConsumerStatefulWidget {
  const QRCodeScreen({super.key});

  @override
  ConsumerState<QRCodeScreen> createState() => _QRCodeScreenState();
}

class _QRCodeScreenState extends ConsumerState<QRCodeScreen> {
  String? _currentQRId;
  DateTime? _validUntil;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentQR();
    });
  }

  Future<void> _loadCurrentQR() async {
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final snapshot = await FirebaseFirestore.instance
          .collection(FirebaseService.qrCodesCollection)
          .where('school_id', isEqualTo: user.uid)
          .where('is_active', isEqualTo: true)
          .orderBy('created_at', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        final data = doc.data();
        setState(() {
          _currentQRId = doc.id;
          _validUntil = (data['valid_until'] as Timestamp).toDate();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _generateNewQR() async {
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Deactivate old QR codes
      final oldQRs = await FirebaseFirestore.instance
          .collection(FirebaseService.qrCodesCollection)
          .where('school_id', isEqualTo: user.uid)
          .where('is_active', isEqualTo: true)
          .get();

      for (var doc in oldQRs.docs) {
        await doc.reference.update({'is_active': false});
      }

      // Generate new QR
      final now = DateTime.now();
      final validUntil = now.add(const Duration(days: 30));
      final qrId = 'qr-${DateTime.now().millisecondsSinceEpoch}';

      await FirebaseFirestore.instance
          .collection(FirebaseService.qrCodesCollection)
          .doc(qrId)
          .set({
            'school_id': user.uid,
            'qr_payload': qrId,
            'valid_from': Timestamp.fromDate(now),
            'valid_until': Timestamp.fromDate(validUntil),
            'is_active': true,
            'created_at': FieldValue.serverTimestamp(),
          });

      setState(() {
        _currentQRId = qrId;
        _validUntil = validUntil;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('New QR code generated!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCurrentQR,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentQRId == null
          ? _buildNoQRState()
          : _buildQRDisplay(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : _generateNewQR,
        icon: const Icon(Icons.add),
        label: const Text('Generate New QR'),
      ),
    );
  }

  Widget _buildNoQRState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.qr_code, size: 100, color: Colors.grey[400]),
          const SizedBox(height: 24),
          Text(
            'No Active QR Code',
            style: TextStyle(fontSize: 20, color: Colors.grey[600]),
          ),
          const SizedBox(height: 12),
          const Text('Generate a QR code for student attendance'),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _generateNewQR,
            icon: const Icon(Icons.add),
            label: const Text('Generate QR Code'),
          ),
        ],
      ),
    );
  }

  Widget _buildQRDisplay() {
    final isExpired =
        _validUntil != null && DateTime.now().isAfter(_validUntil!);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  QrImageView(
                    data: _currentQRId!,
                    version: QrVersions.auto,
                    size: 300.0,
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'QR Code for Attendance',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ID: $_currentQRId',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (_validUntil != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isExpired ? Colors.red[50] : Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isExpired ? Colors.red : Colors.green,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isExpired ? Icons.error : Icons.check_circle,
                      color: isExpired ? Colors.red : Colors.green,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isExpired
                          ? 'Expired'
                          : 'Valid until ${_validUntil!.day}/${_validUntil!.month}/${_validUntil!.year}',
                      style: TextStyle(
                        color: isExpired ? Colors.red : Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            const Text(
              'Students can scan this QR code to mark attendance',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
