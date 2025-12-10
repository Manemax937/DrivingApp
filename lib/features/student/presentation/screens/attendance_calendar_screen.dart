import 'package:driveapp/features/student/domain/entities/attendance.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/student_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';

class AttendanceCalendarScreen extends ConsumerStatefulWidget {
  const AttendanceCalendarScreen({super.key});

  @override
  ConsumerState<AttendanceCalendarScreen> createState() =>
      _AttendanceCalendarScreenState();
}

class _AttendanceCalendarScreenState
    extends ConsumerState<AttendanceCalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    // ✅ FIXED - Use addPostFrameCallback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAttendance();
    });
  }

  Future<void> _loadAttendance() async {
    // Get student ID from Firebase Auth
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await ref.read(studentProvider.notifier).fetchAttendance(user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final studentState = ref.watch(studentProvider);
    final attendanceDates = studentState.attendanceList
        .map(
          (a) => DateTime(
            a.attendanceDate.year,
            a.attendanceDate.month,
            a.attendanceDate.day,
          ),
        )
        .toSet();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showLegendDialog(),
          ),
        ],
      ),
      body: studentState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : studentState.error != null
          ? _buildErrorWidget(studentState.error!)
          : RefreshIndicator(
              onRefresh: _loadAttendance,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // Statistics Card
                    _buildStatisticsCard(studentState),

                    // Calendar
                    Card(
                      margin: const EdgeInsets.all(16),
                      child: TableCalendar(
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2030, 12, 31),
                        focusedDay: _focusedDay,
                        calendarFormat: _calendarFormat,
                        selectedDayPredicate: (day) {
                          return isSameDay(_selectedDay, day);
                        },
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                        },
                        onFormatChanged: (format) {
                          setState(() {
                            _calendarFormat = format;
                          });
                        },
                        onPageChanged: (focusedDay) {
                          _focusedDay = focusedDay;
                        },
                        calendarStyle: CalendarStyle(
                          // Present days
                          markerDecoration: const BoxDecoration(
                            color: AppColors.present,
                            shape: BoxShape.circle,
                          ),
                          // Today
                          todayDecoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          // Selected day
                          selectedDecoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          // Weekend days
                          weekendTextStyle: const TextStyle(
                            color: AppColors.error,
                          ),
                        ),
                        eventLoader: (day) {
                          final normalizedDay = DateTime(
                            day.year,
                            day.month,
                            day.day,
                          );
                          return attendanceDates.contains(normalizedDay)
                              ? ['present']
                              : [];
                        },
                        calendarBuilders: CalendarBuilders(
                          markerBuilder: (context, day, events) {
                            if (events.isNotEmpty) {
                              return Positioned(
                                bottom: 1,
                                child: Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: AppColors.present,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              );
                            }
                            return null;
                          },
                        ),
                      ),
                    ),

                    // Selected Day Details
                    if (_selectedDay != null)
                      _buildSelectedDayDetails(
                        _selectedDay!,
                        studentState.attendanceList,
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatisticsCard(StudentState state) {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month, 1);
    final nextMonth = DateTime(now.year, now.month + 1, 1);

    final monthlyAttendance = state.attendanceList.where((a) {
      return a.attendanceDate.isAfter(
            currentMonth.subtract(const Duration(days: 1)),
          ) &&
          a.attendanceDate.isBefore(nextMonth);
    }).length;

    final totalDays = now.day;
    final percentage = totalDays > 0
        ? (monthlyAttendance / totalDays) * 100
        : 0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          Text(
            DateFormatter.formatMonthYear(now),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Present',
                monthlyAttendance.toString(),
                Icons.check_circle,
              ),
              _buildStatItem(
                'Total Days',
                totalDays.toString(),
                Icons.calendar_today,
              ),
              _buildStatItem(
                'Percentage',
                '${percentage.toStringAsFixed(1)}%',
                Icons.percent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildSelectedDayDetails(
    DateTime day,
    List<Attendance> attendanceList,
  ) {
    // Find attendance for selected day
    Attendance? attendance;
    try {
      attendance = attendanceList.firstWhere(
        (a) => isSameDay(a.attendanceDate, day),
      );
    } catch (e) {
      attendance = null;
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  attendance != null ? Icons.check_circle : Icons.cancel,
                  color: attendance != null
                      ? AppColors.present
                      : AppColors.absent,
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormatter.formatDate(day),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            if (attendance != null) ...[
              _buildDetailRow('Status', 'Present'),
              const SizedBox(height: 8),
              _buildDetailRow(
                'Marked At',
                DateFormatter.formatTime(attendance.markedAt),
              ),
              const SizedBox(height: 8),
              _buildDetailRow('Method', attendance.method.toUpperCase()),
            ] else ...[
              const Text(
                'No attendance marked for this day',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: TextStyle(fontSize: 18, color: Colors.red[700]),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadAttendance,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _showLegendDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Calendar Legend'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLegendItem(AppColors.present, 'Present - Attendance marked'),
            const SizedBox(height: 8),
            _buildLegendItem(AppColors.primary.withOpacity(0.3), 'Today'),
            const SizedBox(height: 8),
            _buildLegendItem(AppColors.primary, 'Selected day'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Text(label),
      ],
    );
  }
}
