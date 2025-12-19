import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../auth/data/auth_repository.dart';
import 'tracker_controller.dart';
import '../data/tracker_repository.dart';
import '../data/daily_log.dart';

class LogEntryScreen extends ConsumerStatefulWidget {
  final DateTime date;

  const LogEntryScreen({super.key, required this.date});

  @override
  ConsumerState<LogEntryScreen> createState() => _LogEntryScreenState();
}

class _LogEntryScreenState extends ConsumerState<LogEntryScreen> {
  FlowIntensity _flow = FlowIntensity.none;
  Mood _mood = Mood.none;
  final List<String> _selectedSymptoms = [];
  final TextEditingController _notesController = TextEditingController();
  bool _isInitialized = false;

  final List<String> _commonSymptoms = [
    'Hot Flash', 'Cramps', 'Headache', 'Bloating', 
    'Fatigue', 'Insomnia', 'Nausea', 'Acne'
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _initForm(DailyLog? log) {
    if (log != null) {
      _flow = log.flow;
      _mood = log.mood;
      _selectedSymptoms.clear();
      _selectedSymptoms.addAll(log.symptoms);
      _notesController.text = log.notes ?? '';
    }
    _isInitialized = true;
  }

  // Loaded via Provider in build()

  Future<void> _saveLog() async {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please log in')));
       return;
    }

    final log = DailyLog()
      ..userId = user.uid
      ..date = widget.date
      ..flow = _flow
      ..mood = _mood
      ..symptoms = _selectedSymptoms.toList()
      ..notes = _notesController.text;
    
    await ref.read(trackerControllerProvider.notifier).saveLog(log);
    
    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final logAsync = ref.watch(logForDateProvider(widget.date));

    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat('MMM d, yyyy').format(widget.date)),
        actions: [
          TextButton(
            onPressed: logAsync.isLoading ? null : _saveLog,
            child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: logAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (existingLog) {
          if (!_isInitialized) {
            _initForm(existingLog);
          }
          
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildSectionHeader('Flow'),
              _buildFlowSelector(),
              const SizedBox(height: 24),
              _buildSectionHeader('Mood'),
              _buildMoodSelector(),
              const SizedBox(height: 24),
              _buildSectionHeader('Symptoms'),
              _buildSymptomChips(),
              const SizedBox(height: 24),
              _buildSectionHeader('Notes'),
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Any other details...',
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildFlowSelector() {
    return SegmentedButton<FlowIntensity>(
      segments: const [
        ButtonSegment(value: FlowIntensity.none, label: Text('None')),
        ButtonSegment(value: FlowIntensity.light, label: Text('Light')),
        ButtonSegment(value: FlowIntensity.medium, label: Text('Med')),
        ButtonSegment(value: FlowIntensity.heavy, label: Text('Heavy')),
      ],
      selected: {_flow},
      onSelectionChanged: (Set<FlowIntensity> newSelection) {
        setState(() {
          _flow = newSelection.first;
        });
      },
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  Widget _buildMoodSelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: Mood.values.where((m) => m != Mood.none).map((mood) {
        final isSelected = _mood == mood;
        return ChoiceChip(
          label: Text(mood.displayName.toUpperCase()),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _mood = selected ? mood : Mood.none;
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildSymptomChips() {
    return Wrap(
      spacing: 8,
      children: _commonSymptoms.map((symptom) {
        final isSelected = _selectedSymptoms.contains(symptom);
        return FilterChip(
          label: Text(symptom),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedSymptoms.add(symptom);
              } else {
                _selectedSymptoms.remove(symptom);
              }
            });
          },
        );
      }).toList(),
    );
  }
}
