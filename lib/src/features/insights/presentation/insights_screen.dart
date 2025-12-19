import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'insights_controller.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(insightsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Health Insights'),
        actions: [
          if (state.hasValue && !state.isLoading)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => ref.read(insightsControllerProvider.notifier).generateInsights(),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            if (state.value == null || state.value!.isEmpty) 
               if (!state.isLoading) _buildIntro(ref) else const SizedBox()
            else
               // Result
               Expanded(
                 child: Container(
                   margin: const EdgeInsets.only(top: 16),
                   decoration: BoxDecoration(
                     color: Colors.white,
                     borderRadius: BorderRadius.circular(24),
                     boxShadow: [
                       BoxShadow(
                         color: Colors.black.withValues(alpha: 0.05),
                         blurRadius: 10,
                         offset: const Offset(0, 4),
                       ),
                     ],
                   ),
                   child: ClipRRect(
                     borderRadius: BorderRadius.circular(24),
                     child: SingleChildScrollView(
                       padding: const EdgeInsets.all(24),
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Row(
                             children: [
                               Icon(Icons.lightbulb_outline, color: Theme.of(context).primaryColor),
                               const SizedBox(width: 8),
                               Text(
                                 'Analysis Result',
                                 style: TextStyle(
                                   color: Theme.of(context).primaryColor,
                                   fontWeight: FontWeight.bold,
                                   fontSize: 14,
                                 ),
                               ),
                             ],
                           ),
                           const Divider(height: 32),
                           MarkdownBody(
                             data: state.value!,
                             styleSheet: MarkdownStyleSheet(
                               h1: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                               h2: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF8BA894), height: 1.5),
                               p: const TextStyle(fontSize: 16, height: 1.6, color: Colors.black87),
                               listBullet: const TextStyle(fontSize: 16, color: Color(0xFFD4A5A5)), // Dusty Rose bullets
                               strong: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2D312F)),
                             ),
                           ),
                         ],
                       ),
                     ),
                   ),
                 ),
               ),
               
            if (state.isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator())),
              
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Error: ${state.error}', style: const TextStyle(color: Colors.red)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
     return const Card(
       color: Color(0xFFF0F4F1), // Light Sage
       child: Padding(
         padding: EdgeInsets.all(16.0),
         child: Row(
           children: [
             Icon(Icons.auto_awesome, size: 32, color: Color(0xFF8BA894)),
             SizedBox(width: 16),
             Expanded(
               child: Text(
                 'AI Analysis uses your last 30 days of symptoms to find patterns.',
                 style: TextStyle(fontSize: 14, color: Colors.black87),
               ),
             ),
           ],
         ),
       ),
     );
  }

  Widget _buildIntro(WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 48),
        const Icon(Icons.analytics_outlined, size: 80, color: Colors.grey),
        const SizedBox(height: 16),
        const Text(
          'Ready to analyze?',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'We will look at your mood, flow, and symptoms.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () {
            ref.read(insightsControllerProvider.notifier).generateInsights();
          },
          child: const Text('Generate Insights'),
        ),
      ],
    );
  }
}
