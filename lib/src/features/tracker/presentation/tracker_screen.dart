import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'tracker_controller.dart';
import '../data/daily_log.dart';

class TrackerScreen extends ConsumerWidget {
  const TrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMonth = ref.watch(selectedMonthProvider);
    final logsAsync = ref.watch(monthlyLogsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cycle Tracker'),
      ),
      body: Column(
        children: [
          _buildMonthSelector(context, ref, currentMonth),
          Expanded(
            child: logsAsync.when(
              data: (logs) => _buildCalendarGrid(context, currentMonth, logs),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Open Log Form for today
          // context.push('/tracker/log'); 
          // For now, simpler dialog or just mock action
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logging coming next!')));
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMonthSelector(BuildContext context, WidgetRef ref, DateTime currentMonth) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              ref.read(selectedMonthProvider.notifier).state = 
                  DateTime(currentMonth.year, currentMonth.month - 1);
            },
          ),
          Text(
            DateFormat('MMMM yyyy').format(currentMonth),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              ref.read(selectedMonthProvider.notifier).state = 
                  DateTime(currentMonth.year, currentMonth.month + 1);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(BuildContext context, DateTime month, List<DailyLog> logs) {
    // Days in month
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    // First weekday
    final firstWeekday = DateTime(month.year, month.month, 1).weekday; 
    // Adjust Sunday=7 to Sunday=0 or 1 depending on locale, usually specific logic needed.
    // Material DateUtils usually follows ISO (Mon=1, Sun=7). 
    // Let's assume standard grid (Sun-Sat).
    
    // Calculate offset. If 1st is Monday (1), and we want Sun start, offset is 1. 
    // If Sun(7), offset is 0.
    final offset = (firstWeekday % 7); 

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.0,
      ),
      itemCount: daysInMonth + offset,
      itemBuilder: (context, index) {
        if (index < offset) {
          return const SizedBox.shrink();
        }
        final day = index - offset + 1;
        final date = DateTime(month.year, month.month, day);
        
        // Find log for this day
        final log = logs.firstWhere(
           (l) => l.date.year == date.year && l.date.month == date.month && l.date.day == date.day,
           orElse: () => DailyLog()..date = date, // Dummy
        );

        final hasFlow = log.flow != FlowIntensity.none;
        final hasSymptom = log.symptoms.isNotEmpty;

        return InkWell(
          onTap: () {
             // Navigate to log entry
             context.go('/tracker/log', extra: date);
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: hasFlow ? Colors.red.withValues(alpha: 0.2) : (hasSymptom ? Colors.orange.withValues(alpha: 0.1) : Colors.transparent),
              shape: BoxShape.circle,
              border: hasFlow ? Border.all(color: Colors.red) : null,
            ),
            alignment: Alignment.center,
            child: Text(
              '$day',
              style: TextStyle(
                fontWeight: (hasFlow || hasSymptom) ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      },
    );
  }
}
