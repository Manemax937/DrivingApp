import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/theme/app_colors.dart';

class QRScannerWidget extends StatefulWidget {
  final Function(String) onQRScanned;
  final bool isScanning;

  const QRScannerWidget({
    super.key,
    required this.onQRScanned,
    this.isScanning = true,
  });

  @override
  State<QRScannerWidget> createState() => _QRScannerWidgetState();
}

class _QRScannerWidgetState extends State<QRScannerWidget> {
  MobileScannerController? _controller;
  bool _hasScanned = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned || !widget.isScanning) return;

    final List<Barcode> barcodes = capture.barcodes;

    if (barcodes.isNotEmpty) {
      final String? code = barcodes.first.rawValue;

      if (code != null && code.isNotEmpty) {
        setState(() => _hasScanned = true);
        widget.onQRScanned(code);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // QR Scanner Camera
        MobileScanner(controller: _controller, onDetect: _onDetect),

        // Scanning frame overlay
        CustomPaint(painter: ScannerOverlayPainter(), child: Container()),

        // Scanning frame
        Center(
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.qrBorder, width: 3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                // Corner decorations
                Positioned(top: 0, left: 0, child: _buildCorner(true, true)),
                Positioned(top: 0, right: 0, child: _buildCorner(true, false)),
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: _buildCorner(false, true),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: _buildCorner(false, false),
                ),
              ],
            ),
          ),
        ),

        // Scanning indicator
        if (widget.isScanning && !_hasScanned)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 280),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.qrOverlay,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.qrBorder,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Scanning...',
                        style: TextStyle(
                          color: AppColors.qrBorder,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCorner(bool isTop, bool isLeft) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        border: Border(
          top: isTop
              ? const BorderSide(color: AppColors.primary, width: 4)
              : BorderSide.none,
          bottom: !isTop
              ? const BorderSide(color: AppColors.primary, width: 4)
              : BorderSide.none,
          left: isLeft
              ? const BorderSide(color: AppColors.primary, width: 4)
              : BorderSide.none,
          right: !isLeft
              ? const BorderSide(color: AppColors.primary, width: 4)
              : BorderSide.none,
        ),
      ),
    );
  }
}

/// Custom painter for scanner overlay
class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.qrOverlay
      ..style = PaintingStyle.fill;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    const scanAreaSize = 250.0;

    // Draw overlay with transparent center
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(centerX, centerY),
            width: scanAreaSize,
            height: scanAreaSize,
          ),
          const Radius.circular(12),
        ),
      )
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// QR Scanner controls widget
class QRScannerControls extends StatelessWidget {
  final MobileScannerController? controller;
  final VoidCallback? onFlashToggle;
  final VoidCallback? onCameraSwitch;

  const QRScannerControls({
    super.key,
    this.controller,
    this.onFlashToggle,
    this.onCameraSwitch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Flash toggle
          _buildControlButton(
            icon: Icons.flash_on,
            label: 'Flash',
            onPressed: () {
              controller?.toggleTorch();
              onFlashToggle?.call();
            },
          ),

          // Camera switch
          _buildControlButton(
            icon: Icons.flip_camera_android,
            label: 'Switch',
            onPressed: () {
              controller?.switchCamera();
              onCameraSwitch?.call();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.9),
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      child: Row(
        children: [Icon(icon, size: 20), const SizedBox(width: 8), Text(label)],
      ),
    );
  }
}
