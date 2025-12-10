import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/owner_provider.dart';
import '../widgets/student_card.dart';
import '../../../../core/theme/app_colors.dart';

class StudentsListScreen extends ConsumerStatefulWidget {
  const StudentsListScreen({super.key});

  @override
  ConsumerState<StudentsListScreen> createState() => _StudentsListScreenState();
}

class _StudentsListScreenState extends ConsumerState<StudentsListScreen> {
  String? _selectedFilter;
  String? _selectedBatch;
  String? _selectedCourse;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ownerProvider.notifier).fetchStudents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ownerState = ref.watch(ownerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Students'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(ownerProvider.notifier).refresh(),
        child: Column(
          children: [
            // Active filters display
            if (_hasActiveFilters()) _buildActiveFiltersChips(),

            // Students list
            Expanded(
              child: ownerState.isLoading && ownerState.students.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ownerState.error != null && ownerState.students.isEmpty
                  ? _buildErrorWidget(ownerState.error!)
                  : ownerState.students.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: ownerState.students.length,
                      itemBuilder: (context, index) {
                        return StudentCard(
                          student: ownerState.students[index],
                          onTap: () {
                            // Navigate to student details
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  bool _hasActiveFilters() {
    return _selectedFilter != null ||
        _selectedBatch != null ||
        _selectedCourse != null;
  }

  Widget _buildActiveFiltersChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          if (_selectedFilter != null)
            Chip(
              label: Text('Status: $_selectedFilter'),
              onDeleted: () {
                setState(() => _selectedFilter = null);
                _applyFilters();
              },
              deleteIcon: const Icon(Icons.close, size: 18),
            ),
          if (_selectedBatch != null)
            Chip(
              label: Text('Batch: $_selectedBatch'),
              onDeleted: () {
                setState(() => _selectedBatch = null);
                _applyFilters();
              },
              deleteIcon: const Icon(Icons.close, size: 18),
            ),
          if (_selectedCourse != null)
            Chip(
              label: Text('Course: $_selectedCourse'),
              onDeleted: () {
                setState(() => _selectedCourse = null);
                _applyFilters();
              },
              deleteIcon: const Icon(Icons.close, size: 18),
            ),
          if (_hasActiveFilters())
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _selectedFilter = null;
                  _selectedBatch = null;
                  _selectedCourse = null;
                });
                ref.read(ownerProvider.notifier).clearFilters();
              },
              icon: const Icon(Icons.clear_all, size: 18),
              label: const Text('Clear All'),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No students found',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            _hasActiveFilters()
                ? 'Try adjusting your filters'
                : 'No students have been added yet',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text('Error', style: TextStyle(fontSize: 18, color: Colors.red[700])),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => ref.read(ownerProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Students'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Payment Status',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('Fully Paid'),
                    selected: _selectedFilter == 'Fully Paid',
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = selected ? 'Fully Paid' : null;
                      });
                    },
                  ),
                  FilterChip(
                    label: const Text('Partially Paid'),
                    selected: _selectedFilter == 'Partially Paid',
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = selected ? 'Partially Paid' : null;
                      });
                    },
                  ),
                  FilterChip(
                    label: const Text('Pending'),
                    selected: _selectedFilter == 'Pending',
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = selected ? 'Pending' : null;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Course Type',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('2-Wheeler'),
                    selected: _selectedCourse == '2-Wheeler',
                    onSelected: (selected) {
                      setState(() {
                        _selectedCourse = selected ? '2-Wheeler' : null;
                      });
                    },
                  ),
                  FilterChip(
                    label: const Text('4-Wheeler'),
                    selected: _selectedCourse == '4-Wheeler',
                    onSelected: (selected) {
                      setState(() {
                        _selectedCourse = selected ? '4-Wheeler' : null;
                      });
                    },
                  ),
                  FilterChip(
                    label: const Text('Both'),
                    selected: _selectedCourse == 'Both',
                    onSelected: (selected) {
                      setState(() {
                        _selectedCourse = selected ? 'Both' : null;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Batch Timing',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children:
                    [
                      '7:00 AM - 8:00 AM',
                      '8:00 AM - 9:00 AM',
                      '5:00 PM - 6:00 PM',
                      '6:00 PM - 7:00 PM',
                    ].map((batch) {
                      return FilterChip(
                        label: Text(batch),
                        selected: _selectedBatch == batch,
                        onSelected: (selected) {
                          setState(() {
                            _selectedBatch = selected ? batch : null;
                          });
                        },
                      );
                    }).toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedFilter = null;
                _selectedBatch = null;
                _selectedCourse = null;
              });
            },
            child: const Text('Clear'),
          ),
          ElevatedButton(
            onPressed: () {
              _applyFilters();
              Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    // Implement search functionality
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search'),
        content: const TextField(
          decoration: InputDecoration(
            hintText: 'Search by name, phone...',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement search
              Navigator.pop(context);
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void _applyFilters() {
    ref
        .read(ownerProvider.notifier)
        .applyFilters(
          status: _selectedFilter,
          batchTiming: _selectedBatch,
          courseType: _selectedCourse,
        );
  }
}
