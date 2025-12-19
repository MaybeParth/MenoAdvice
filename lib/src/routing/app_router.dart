import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/tracker/presentation/tracker_screen.dart';
import '../features/chat/presentation/chat_screen.dart';
import '../features/tracker/presentation/log_entry_screen.dart';
import '../features/insights/presentation/insights_screen.dart';
import '../features/education/presentation/education_screen.dart';
import '../features/education/presentation/article_detail_screen.dart';
import '../features/education/data/article_data.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/onboarding/data/user_providers.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/auth/presentation/splash_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  final isSplashComplete = ref.watch(splashCompleteProvider);
  final userProfileAsync = ref.watch(userProfileStreamProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isSplash = state.uri.path == '/splash';
      
      // If we are on splash, only redirect once it is "complete" and auth is ready
      if (isSplash) {
        if (!isSplashComplete || authState.isLoading) return null;
      }
      
      if (authState.isLoading) return '/splash';

      final user = authState.value;
      final isLoggingIn = state.uri.path == '/login';

      if (user == null) {
        return isLoggingIn ? null : '/login';
      }

      if (isLoggingIn || isSplash) {
        // Check onboarding status
        return userProfileAsync.maybeWhen(
          data: (profile) {
            if (profile == null || !profile.isOnboardingCompleted) {
              return '/onboarding';
            }
            return '/';
          },
          orElse: () => null, // Stay or wait for data
        );
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const DashboardScreen(),
        routes: [
           GoRoute(
            path: 'tracker',
            builder: (context, state) => const TrackerScreen(),
            routes: [
              GoRoute(
                path: 'log',
                builder: (context, state) {
                   final date = state.extra as DateTime? ?? DateTime.now();
                   return LogEntryScreen(date: date);
                },
              ),
            ],
          ),
          GoRoute(
            path: 'insights',
            builder: (context, state) => const InsightsScreen(),
          ),
          GoRoute(
            path: 'education',
            builder: (context, state) => const EducationScreen(),
            routes: [
               GoRoute(
                path: 'article',
                builder: (context, state) {
                   final article = state.extra as Article;
                   return ArticleDetailScreen(article: article);
                },
              ),
            ],
          ),
          GoRoute(
            path: 'chat',
            builder: (context, state) => const ChatScreen(),
          ),
          GoRoute(
            path: 'onboarding',
            builder: (context, state) => const OnboardingScreen(),
          ),
          GoRoute(
            path: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
});
