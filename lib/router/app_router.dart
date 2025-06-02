import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:outfitly/screens/calendar/calendar_planner_screen.dart';
import '../screens/login/login_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/login/splash_screen.dart';
import '../screens/user/user_screen.dart';
import '../screens/wardrobe/cloths/cloths_item_screen.dart';
import '../screens/wardrobe/outfits/outfits_screen.dart';
import '../screens/wardrobe/wardrobe_screen.dart';
import '../screens/login/register/register_screen.dart';
import '../widgets/nav_bars/desktop_sidebar.dart';
import '../widgets/nav_bars/mobile_botton_nav.dart';

class AuthStateListener extends ChangeNotifier {
  User? _currentUser;
  bool _initialized = false;
  StreamSubscription<User?>? _authSubscription;
  DateTime? _lastAuthChange;

  AuthStateListener() {
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      final now = DateTime.now();
      if (_lastAuthChange != null &&
          now.difference(_lastAuthChange!).inMilliseconds < 3000) {
        debugPrint('Auth state change ignored: Within 3s debounce');
        return;
      }
      _lastAuthChange = now;
      debugPrint('Auth state changed: user=${user?.uid}');
      _currentUser = user;
      _initialized = true;
      notifyListeners();
    });
  }

  User? get currentUser => _currentUser;
  bool get initialized => _initialized;

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

CustomTransitionPage _fadeTransition(Widget child) {
  return CustomTransitionPage(
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

final authStateListener = AuthStateListener();

// Splash state management
bool _isSplashing = false;
int _splashCount = 0;
DateTime? _lastRedirect;

void resetSplashState({bool immediate = false}) {
  if (immediate) {
    _isSplashing = false;
    _splashCount = 0;
    debugPrint('Splash state reset immediately');
  } else {
    Future.delayed(const Duration(milliseconds: 2500), () {
      _isSplashing = false;
      _splashCount = 0;
      debugPrint('Splash state reset after 2.5s delay');
    });
  }
}

final GoRouter appRouter = GoRouter(
  debugLogDiagnostics: true,
  initialLocation: '/',
  refreshListenable: authStateListener,
  routes: [
    GoRoute(
      path: '/splash',
      pageBuilder: (context, state) => _fadeTransition(const SplashScreen()),
    ),
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => _fadeTransition(const LoginScreen()),
    ),
    GoRoute(
      path: '/register',
      pageBuilder: (context, state) => _fadeTransition(const RegisterScreen()),
    ),
    ShellRoute(
      builder: (context, state, child) {
        return _SidebarShell(child: child);
      },
      routes: [
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) => _fadeTransition(const HomeScreen()),
        ),
        GoRoute(
          path: '/wardrobe',
          pageBuilder:
              (context, state) => _fadeTransition(const WardrobeScreen()),
          routes: [
            GoRoute(
              path: 'items',
              pageBuilder:
                  (context, state) => _fadeTransition(const ClothsItemScreen()),
            ),
            GoRoute(
              path: 'outfits',
              pageBuilder:
                  (context, state) => _fadeTransition(const OutfitsScreen()),
            ),
          ],
        ),
        GoRoute(
          path: '/calendar',
          pageBuilder:
              (context, state) =>
                  _fadeTransition(const CalenderPlannerScreen()),
        ),
        GoRoute(
          path: '/user',
          pageBuilder: (context, state) => _fadeTransition(const UserScreen()),
        ),
      ],
    ),
  ],
  redirect: (context, state) {
    debugPrint('Redirect triggered: ${state.matchedLocation}');
    final now = DateTime.now();
    if (_lastRedirect != null &&
        now.difference(_lastRedirect!).inMilliseconds < 3000) {
      debugPrint('Redirect: Skipped, within 3s debounce');
      return null;
    }
    _lastRedirect = now;

    final isLogout = state.uri.queryParameters['logout'] == 'true';
    if (isLogout && !_isSplashing) {
      debugPrint('Redirect: Allowing splash for logout');
      _isSplashing = true;
      _splashCount++;
      return '/splash';
    }

    if (!authStateListener.initialized && !isLogout) {
      debugPrint('Redirect: Auth not initialized');
      if (_isSplashing || _splashCount >= 1) {
        debugPrint(
          'Redirect: Skipping splash, already splashing or max attempts',
        );
        return null;
      }
      _isSplashing = true;
      _splashCount++;
      return '/splash';
    }

    final loggedIn = authStateListener.currentUser != null;
    debugPrint(
      'Redirect: location=${state.matchedLocation}, loggedIn=$loggedIn',
    );

    if (state.matchedLocation == '/splash') {
      return null;
    }

    final loggingIn = {'/', '/register'}.contains(state.matchedLocation);
    if (!loggedIn && !loggingIn) {
      debugPrint('Redirect: Not logged in, to /');
      return '/';
    }
    if (loggedIn && loggingIn) {
      debugPrint('Redirect: Logged in, to /home');
      return '/home';
    }

    debugPrint('Redirect: No redirect');
    return null;
  },
);

class _SidebarShell extends StatefulWidget {
  final Widget child;
  const _SidebarShell({required this.child});

  @override
  State<_SidebarShell> createState() => _SidebarShellState();
}

class _SidebarShellState extends State<_SidebarShell> {
  bool isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return MobileBottomNav(child: widget.child);
        }
        return Scaffold(
          body: Row(
            children: [
              DesktopSidebar(
                isExpanded: isExpanded,
                onToggle: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
              ),
              Expanded(child: widget.child),
            ],
          ),
        );
      },
    );
  }
}
