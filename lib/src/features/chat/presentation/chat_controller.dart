import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../insights/data/ai_repository.dart';
import '../domain/chat_message.dart';
import 'package:uuid/uuid.dart';

final chatControllerProvider = StateNotifierProvider<ChatController, List<ChatMessage>>((ref) {
  final aiRepo = ref.watch(aiRepositoryProvider);
  return ChatController(aiRepo);
});

class ChatController extends StateNotifier<List<ChatMessage>> {
  final AiRepository _aiRepository;
  final _uuid = const Uuid();

  ChatController(this._aiRepository) : super([]) {
    // Start session immediately or lazily
    _aiRepository.startChat();
    // Add initial greeting
    state = [
      ChatMessage(
        id: _uuid.v4(),
        text: "Hi! I'm MenoFriend. How can I help you today? ❤️",
        isUser: false,
        timestamp: DateTime.now(),
      )
    ];
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // 1. Add User Message
    final userMsg = ChatMessage(
        id: _uuid.v4(), 
        text: text, 
        isUser: true, 
        timestamp: DateTime.now()
    );
    state = [...state, userMsg];

    // 2. Add Loading/Typing placeholder (optional, or just wait)
    
    // 3. Get AI Response
    final responseText = await _aiRepository.sendMessage(text);

    // 4. Add AI Message
    final aiMsg = ChatMessage(
        id: _uuid.v4(), 
        text: responseText, 
        isUser: false, 
        timestamp: DateTime.now()
    );
    state = [...state, aiMsg];
  }
}
