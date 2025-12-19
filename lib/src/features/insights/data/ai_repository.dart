import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../tracker/data/daily_log.dart';

final aiRepositoryProvider = Provider<AiRepository>((ref) {
  // Get key from .env
  final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  
  // Using gemini-2.0-flash to avoid experimental quota limits
  final model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: apiKey);
  return AiRepository(model);
});

class AiRepository {
  final GenerativeModel _model;

  AiRepository(this._model);

  Future<String> analyzeLogs(List<DailyLog> logs, String userStage) async {
    if (logs.isEmpty) {
      return "You haven't logged any symptoms yet. Track for a few days so I can find patterns!";
    }

    // formatting logs into a readable string
    final logSummary = logs.map((log) {
      final date = log.date.toIso8601String().split('T').first;
      final details = [
        if (log.flow != FlowIntensity.none) 'Flow: ${log.flow.displayName}',
        if (log.mood != Mood.none) 'Mood: ${log.mood.displayName}',
        if (log.symptoms.isNotEmpty) 'Symptoms: ${log.symptoms.join(", ")}',
        if (log.notes != null && log.notes!.isNotEmpty) 'Note: ${log.notes}',
      ].join(' | ');
      return '$date: $details';
    }).join('\n');

    final prompt = '''
    You are a helpful, empathetic women's health assistant. 
    The user is in the "$userStage" phase.
    
    Here are her symptom logs for the last 30 days:
    $logSummary
    
    Analyze these logs and provide:
    1. A summary of any patterns (e.g. "Headaches seem to correlate with high anxiety").
    2. 3 actionable lifestyle tips relevant to her specific symptoms.
    3. A gentle, supportive closing.
    
    Keep it concise (under 200 words) and use Markdown formatting.
    ''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text ?? "I couldn't generate an analysis right now. Please try again.";
    } catch (e) {
      return "Error connecting to AI service: $e";
    }
  }

  // --- Chat Capabilities ---

  ChatSession? _chatSession;

  void startChat() {
    // Basic persona prompt
    _chatSession = _model.startChat(history: [
      Content.text('You are "MenoFriend", a kind, empathetic, and knowledgeable assistant for women going through menopause. '
          'Keep your answers concise, supportive, and medically grounded but easy to understand. '
          'Avoid long lectures. Use emojis occasionally.')
    ]);
  }

  Future<String> sendMessage(String message) async {
    if (_chatSession == null) startChat();
    
    try {
      final response = await _chatSession!.sendMessage(Content.text(message));
      return response.text ?? "I'm having trouble thinking right now. Please try again.";
    } catch (e) {
      return "Sorry, I couldn't connect. Please check your internet.";
    }
  }
}
