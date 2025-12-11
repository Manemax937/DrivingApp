import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/date_formatter.dart';
import 'package:intl/intl.dart';

class OwnerViewAttendanceScreen extends StatefulWidget {
  final String studentId;
  final String studentName;

  const OwnerViewAttendanceScreen({
    super.key,
    required this.studentId,
    required this.studentName,
  });

  @override
  State<OwnerViewAttendanceScreen> createState() =>
      _OwnerViewAttendanceScreenState();
}

class _OwnerViewAttendanceScreenState extends State<OwnerViewAttendanceScreen> {
  List<Map<String, dynamic>> _attendanceRecords = [];
  bool _isLoading = true;
  String _selectedFilter = 'All'; // All, This Month, This Week

  @override
  void initState() {
    super.initState();
    _loadAttendance();
  }

  Future<void> _loadAttendance() async {
    setState(() => _isLoading = true);
    try {
      Query query = FirebaseFirestore.instance
          .collection('attendance')
          .where('student_id', isEqualTo: widget.studentId);

      // Optional date filters – use marked_at field
      if (_selectedFilter == 'This Month') {
        final now = DateTime.now();
        final startOfMonth = DateTime(now.year, now.month, 1);
        query = query.where(
          'marked_at',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth),
        );
      } else if (_selectedFilter == 'This Week') {
        final now = DateTime.now();
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final startDate = DateTime(
          startOfWeek.year,
          startOfWeek.month,
          startOfWeek.day,
        );
        query = query.where(
          'marked_at',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        );
      }

      final snapshot = await query.orderBy('marked_at', descending: true).get();

      setState(() {
        _attendanceRecords = snapshot.docs
            .map((d) => d.data() as Map<String, dynamic>)
            .toList();
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFA726),
              Color(0xFFFF7043),
              Color(0xFFEC407A),
              Color(0xFFAB47BC),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              _buildFilterChips(),
              Expanded(
                child: _isLoading
                    ? Center(
                        child: Container(
                          padding: EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(
                                  Color(0xFFFF7043),
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Loading attendance...',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _attendanceRecords.isEmpty
                    ? _buildEmptyState()
                    : _buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Attendance',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                Text(
                  widget.studentName,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          _buildFilterChip('All'),
          SizedBox(width: 8),
          _buildFilterChip('This Month'),
          SizedBox(width: 8),
          _buildFilterChip('This Week'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedFilter = label);
        _loadAttendance();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(colors: [Color(0xFFFFA726), Color(0xFFFF7043)])
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : Color(0xFFFF7043).withOpacity(0.3),
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Color(0xFFFF7043).withOpacity(0.4),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Color(0xFFFF7043),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    // Calculate statistics
    final totalDays = _attendanceRecords.length;
    final presentDays = _attendanceRecords
        .where((r) => r['status'] == 'Present')
        .length;
    final absentDays = _attendanceRecords
        .where((r) => r['status'] == 'Absent')
        .length;
    final lateDays = _attendanceRecords
        .where((r) => r['status'] == 'Late')
        .length;

    return RefreshIndicator(
      onRefresh: _loadAttendance,
      color: Color(0xFFFF7043),
      child: Column(
        children: [
          _buildStatisticsCard(totalDays, presentDays, absentDays, lateDays),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _attendanceRecords.length,
              itemBuilder: (context, index) {
                return _buildAttendanceCard(_attendanceRecords[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCard(int total, int present, int absent, int late) {
    final attendance = total > 0
        ? (present / total * 100).toStringAsFixed(1)
        : '0.0';

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF66BB6A), Color(0xFF81C784)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.calendar_today,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Attendance Rate',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '$attendance%',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatChip(
                  'Present',
                  present.toString(),
                  Icons.check_circle,
                  [Color(0xFF66BB6A), Color(0xFF81C784)],
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _buildStatChip(
                  'Absent',
                  absent.toString(),
                  Icons.cancel,
                  [Color(0xFFEF5350), Color(0xFFE57373)],
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _buildStatChip(
                  'Late',
                  late.toString(),
                  Icons.access_time,
                  [Color(0xFFFFA726), Color(0xFFFFB74D)],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(
    String label,
    String value,
    IconData icon,
    List<Color> colors,
  ) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors.map((c) => c.withOpacity(0.15)).toList(),
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors[0].withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: colors[0], size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colors[0],
            ),
          ),
          SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildAttendanceCard(Map<String, dynamic> record) {
    final timestamp = (record['marked_at'] as Timestamp).toDate();
    final status = record['status'] ?? 'Present';
    final location = record['location'] ?? 'N/A';

    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case 'Present':
        statusColor = Color(0xFF66BB6A);
        statusIcon = Icons.check_circle;
        break;
      case 'Absent':
        statusColor = Color(0xFFEF5350);
        statusIcon = Icons.cancel;
        break;
      case 'Late':
        statusColor = Color(0xFFFFA726);
        statusIcon = Icons.access_time;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(statusIcon, color: statusColor, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEEE, dd MMM yyyy').format(timestamp),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  DateFormat('hh:mm a').format(timestamp),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                if (location != 'N/A') ...[
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 12,
                        color: Colors.grey[500],
                      ),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [statusColor, statusColor.withOpacity(0.7)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: EdgeInsets.all(32),
        padding: EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFFFA726).withOpacity(0.2),
                    Color(0xFFFF7043).withOpacity(0.2),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.calendar_today,
                size: 64,
                color: Color(0xFFFF7043),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Attendance Records',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This student has not marked any attendance yet',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
