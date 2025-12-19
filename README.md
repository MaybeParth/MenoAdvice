# MenoAdvice 

**MenoAdvice** is a premium, AI-powered women's health companion designed to support and guide users through the various stages of menopause.

![MenoAdvice Logo](assets/images/logo.png)

## Core Features 🚀

- **AI Smart Insights**: leverages Google Gemini to analyze symptom patterns and provide actionable lifestyle advice.
- **Symptom Tracking**: A intuitive calendar-based logger for mood, flow, and specific menopause symptoms.
- **Personalized Onboarding**: Tailors the app experience based on the user's specific menopause phase.
- **Educational Library**: Rich content on hormone health and wellness.
- **Secure Auth**: Firebase integration with Email/Password and Google Sign-In support.

## Technical Highlights 🛠️

### AI Analysis Logic
The `AiRepository` constructs detailed prompts based on 30 days of user logs to generate empathetic analysis.

```dart
// Example of log analysis formatting
final logSummary = logs.map((log) {
  final date = log.date.toIso8601String().split('T').first;
  return '$date: Flow: ${log.flow.displayName}, Mood: ${log.mood.displayName}';
}).join('\n');
```

### Robust State Management
Powered by **Riverpod** for reactive UI and **Isar** for high-performance local data persistence.

```dart
final userProfileStreamProvider = StreamProvider<UserProfile?>((ref) async* {
  final authUser = ref.watch(authStateChangesProvider).value;
  if (authUser == null) yield null;
  else yield* ref.watch(onboardingRepositoryProvider).watchUserProfile(authUser.uid);
});
```

## Setup ⚙️

1. Clone the repository.
2. Create a `.env` file based on `.env.example`.
3. Add your `GEMINI_API_KEY`.
4. Run `flutter pub get` and `flutter run`.

---
*Built with care for women's health.*
