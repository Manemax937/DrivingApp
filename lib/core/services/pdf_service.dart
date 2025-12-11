import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart'; // Add this to pubspec.yaml

class PDFService {
  static Future<void> downloadForm14PDF({
    required BuildContext context,
    required String studentName,
    required Map<String, dynamic> formData,
    required String? userPhotoUrl,
    required String? aadhaarPhotoUrl,
    required String? panPhotoUrl,
  }) async {
    final pdf = pw.Document();

    // Fetch images
    pw.ImageProvider? userPhoto;
    pw.ImageProvider? aadhaarPhoto;
    pw.ImageProvider? panPhoto;

    try {
      if (userPhotoUrl != null) {
        userPhoto = await _fetchImage(userPhotoUrl);
      }
      if (aadhaarPhotoUrl != null) {
        aadhaarPhoto = await _fetchImage(aadhaarPhotoUrl);
      }
      if (panPhotoUrl != null) {
        panPhoto = await _fetchImage(panPhotoUrl);
      }
    } catch (e) {
      print('Error loading images: $e');
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(40),
        build: (context) {
          return [
            // Header
            pw.Container(
              alignment: pw.Alignment.center,
              margin: pw.EdgeInsets.only(bottom: 30),
              child: pw.Column(
                children: [
                  pw.Text(
                    'FORM-14',
                    style: pw.TextStyle(
                      fontSize: 32,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    'Trainee Enrollment Register',
                    style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    'Student: $studentName',
                    style: pw.TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),

            // Photos Section
            if (userPhoto != null ||
                aadhaarPhoto != null ||
                panPhoto != null) ...[
              pw.Text(
                'Documents',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Row(
                children: [
                  if (userPhoto != null)
                    pw.Expanded(
                      child: pw.Column(
                        children: [
                          pw.Image(userPhoto, height: 100, width: 80),
                          pw.SizedBox(height: 5),
                          pw.Text(
                            'User Photo',
                            style: pw.TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  if (aadhaarPhoto != null)
                    pw.Expanded(
                      child: pw.Column(
                        children: [
                          pw.Image(aadhaarPhoto, height: 100, width: 80),
                          pw.SizedBox(height: 5),
                          pw.Text(
                            'Aadhaar Card',
                            style: pw.TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  if (panPhoto != null)
                    pw.Expanded(
                      child: pw.Column(
                        children: [
                          pw.Image(panPhoto, height: 100, width: 80),
                          pw.SizedBox(height: 5),
                          pw.Text(
                            'PAN Card',
                            style: pw.TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              pw.SizedBox(height: 30),
            ],

            // Information Sections
            pw.Text(
              'Basic Information',
              style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            _buildInfoTable([
              ['Enrollment Number', formData['enrollment_number'] ?? ''],
              ['Trainee Name', formData['trainee_name'] ?? ''],
              ['Son/Wife/Daughter of', formData['relation_name'] ?? ''],
              ['Date of Birth', _formatDate(formData['date_of_birth'])],
            ]),
            pw.SizedBox(height: 20),

            pw.Text(
              'Address Details',
              style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            _buildInfoTable([
              ['Permanent Address', formData['permanent_address'] ?? ''],
              ['Temporary Address', formData['temporary_address'] ?? ''],
            ]),
            pw.SizedBox(height: 20),

            pw.Text(
              'Identity Documents',
              style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            _buildInfoTable([
              ['Aadhaar Number', formData['aadhaar_number'] ?? ''],
              ['PAN Number', formData['pan_number'] ?? ''],
            ]),
            pw.SizedBox(height: 20),

            pw.Text(
              'Training Details',
              style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            _buildInfoTable([
              ['Class of Vehicle', formData['vehicle_class'] ?? ''],
              ['Enrollment Date', _formatDate(formData['enrollment_date'])],
              [
                'Course Completion',
                _formatDate(formData['course_completion_date']),
              ],
              ['Test Pass Date', _formatDate(formData['test_pass_date'])],
            ]),
            pw.SizedBox(height: 20),

            pw.Text(
              'License Information',
              style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            _buildInfoTable([
              ["Learner's License", formData['learner_license_number'] ?? ''],
              [
                'License Expiry',
                _formatDate(formData['learner_license_expiry']),
              ],
              ['Driving License', formData['driving_license_number'] ?? ''],
              [
                'License Issue Date',
                _formatDate(formData['driving_license_issue_date']),
              ],
              ['Licensing Authority', formData['licensing_authority'] ?? ''],
            ]),
          ];
        },
      ),
    );

    // Save and share
    await _savePDF(
      context,
      pdf,
      'Form14_${studentName.replaceAll(' ', '_')}.pdf',
    );
  }

  static Future<void> downloadForm15PDF({
    required BuildContext context,
    required String studentName,
    required List<Map<String, dynamic>> drivingHours,
  }) async {
    final pdf = pw.Document();

    final totalHours = drivingHours.fold<double>(
      0,
      (sum, item) => sum + (item['hours_spent'] ?? 0).toDouble(),
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(40),
        build: (context) {
          return [
            // Header
            pw.Container(
              alignment: pw.Alignment.center,
              margin: pw.EdgeInsets.only(bottom: 30),
              child: pw.Column(
                children: [
                  pw.Text(
                    'FORM-15',
                    style: pw.TextStyle(
                      fontSize: 32,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    'Driving Hours Register',
                    style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    'Student: $studentName',
                    style: pw.TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),

            // Summary Card
            pw.Container(
              padding: pw.EdgeInsets.all(15),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(width: 2),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  pw.Column(
                    children: [
                      pw.Text(
                        'Total Sessions',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        drivingHours.length.toString(),
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Text(
                        'Total Hours',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        '${totalHours.toStringAsFixed(1)} hrs',
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Driving Hours Table
            pw.Text(
              'Driving Sessions',
              style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Table(
              border: pw.TableBorder.all(width: 1),
              columnWidths: {
                0: pw.FlexColumnWidth(1.5),
                1: pw.FlexColumnWidth(1.2),
                2: pw.FlexColumnWidth(1.2),
                3: pw.FlexColumnWidth(0.8),
                4: pw.FlexColumnWidth(1),
                5: pw.FlexColumnWidth(1.3),
              },
              children: [
                // Header Row
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    _buildTableCell('Date', bold: true),
                    _buildTableCell('From', bold: true),
                    _buildTableCell('To', bold: true),
                    _buildTableCell('Hours', bold: true),
                    _buildTableCell('Vehicle', bold: true),
                    _buildTableCell('Instructor', bold: true),
                  ],
                ),
                // Data Rows
                ...drivingHours.map((hour) {
                  return pw.TableRow(
                    children: [
                      _buildTableCell(_formatDate(hour['date'])),
                      _buildTableCell(_formatTime(hour['time_from'])),
                      _buildTableCell(_formatTime(hour['time_to'])),
                      _buildTableCell(
                        (hour['hours_spent'] ?? 0).toStringAsFixed(1),
                      ),
                      _buildTableCell(hour['vehicle_class'] ?? ''),
                      _buildTableCell(hour['instructor_name'] ?? ''),
                    ],
                  );
                }).toList(),
              ],
            ),
            pw.SizedBox(height: 40),

            // Signature Section
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                pw.Column(
                  children: [
                    pw.SizedBox(height: 50),
                    pw.Container(width: 120, height: 1, color: PdfColors.black),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      'Instructor Signature',
                      style: pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
                pw.Column(
                  children: [
                    pw.SizedBox(height: 50),
                    pw.Container(width: 120, height: 1, color: PdfColors.black),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      'Student Signature',
                      style: pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          ];
        },
      ),
    );

    // Save and share
    await _savePDF(
      context,
      pdf,
      'Form15_${studentName.replaceAll(' ', '_')}.pdf',
    );
  }

  static Future<void> _savePDF(
    BuildContext context,
    pw.Document pdf,
    String filename,
  ) async {
    try {
      final bytes = await pdf.save();
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$filename');
      await file.writeAsBytes(bytes);

      // Share the file
      await Share.shareXFiles([XFile(file.path)], text: 'Download $filename');
    } catch (e) {
      print('Error saving PDF: $e');
      rethrow;
    }
  }

  static pw.Widget _buildInfoTable(List<List<String>> data) {
    return pw.Table(
      border: pw.TableBorder.all(width: 0.5),
      columnWidths: {0: pw.FlexColumnWidth(2), 1: pw.FlexColumnWidth(3)},
      children: data.map((row) {
        return pw.TableRow(
          children: [
            pw.Padding(
              padding: pw.EdgeInsets.all(6),
              child: pw.Text(
                row[0],
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
            pw.Padding(
              padding: pw.EdgeInsets.all(6),
              child: pw.Text(row[1], style: pw.TextStyle(fontSize: 10)),
            ),
          ],
        );
      }).toList(),
    );
  }

  static pw.Widget _buildTableCell(String text, {bool bold = false}) {
    return pw.Padding(
      padding: pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  static String _formatDate(dynamic timestamp) {
    if (timestamp == null) return '';
    try {
      final date = (timestamp as dynamic).toDate();
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return '';
    }
  }

  static String _formatTime(dynamic timestamp) {
    if (timestamp == null) return '';
    try {
      final time = (timestamp as dynamic).toDate();
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '';
    }
  }

  static Future<pw.ImageProvider> _fetchImage(String url) async {
    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return pw.MemoryImage(response.bodyBytes);
      }
    } catch (e) {
      print('Error fetching image: $e');
    }
    throw Exception('Failed to fetch image');
  }
}
