import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../widgets/eventos_logo_svg.dart';
import '../api/api_client.dart';
import '../auth/auth_repository.dart';
import 'main_navigation_screen.dart';

// Optional: simple logger
void _log(Object? message) {
  // ignore: avoid_print
  print('[Splash] $message');
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _backgroundColorAnimation;
  late Animation<double> _logoYPositionAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<Color?> _logoColorAnimation;
  final ApiClient _api = ApiClient();
  late final AuthRepository _authRepo;
  bool _hasSession = false;

  @override
  void initState() {
    super.initState();

    _authRepo = AuthRepository(_api);

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    // Background color animation: red to white (0.0 - 0.4)
    _backgroundColorAnimation = ColorTween(
      begin: const Color(0xFFFF4F5A),
      end: Colors.white,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeInOut),
      ),
    );

    // Logo Y position animation: centered (0.0) to top (-0.5)
    // Starts when background is transitioning
    _logoYPositionAnimation = Tween<double>(
      begin: 0.0,
      end: -0.5,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.15, 0.55, curve: Curves.easeOut),
      ),
    );

    // Logo scale animation: 1.0 -> 1.15 -> 1.0 for pop effect
    _logoScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.15)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 0.4,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.15, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 0.6,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );

    // Logo color animation: white to red (0.3 - 0.45)
    // Starts when background is transitioning to white
    _logoColorAnimation = ColorTween(
      begin: Colors.white,
      end: const Color(0xFFFF4F5A),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.45, curve: Curves.easeInOut),
      ),
    );

    // Start animation
    _controller.forward();

    // Kick off a backend health check (non-blocking)
    _api.health().then((res) {
      _log('Backend health OK: $res');
    }).catchError((e) {
      _log('Backend health check failed: $e');
    });

    // Preload any existing session (non-blocking relative to animation)
    _authRepo.loadSessionIfAny().then((exists) {
      setState(() {
        _hasSession = exists;
      });
    }).catchError((_) {});

    // Navigate when animation completes
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _api.close();
        final Widget next = _hasSession
            ? MainNavigationScreen(initialIndex: 0)
            : const LoginScreen();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => next),
        );
      }
    });
  }

  @override
  void dispose() {
    _api.close();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          // Determine logo color based on animation progress
          Color logoColor;
          if (_controller.value < 0.3) {
            // White logo on red background
            logoColor = Colors.white;
          } else if (_controller.value < 0.45) {
            // Transitioning from white to red
            logoColor = _logoColorAnimation.value ?? const Color(0xFFFF4F5A);
          } else {
            // Red logo on white background
            logoColor = const Color(0xFFFF4F5A);
          }

          return Container(
            color: _backgroundColorAnimation.value ?? const Color(0xFFFF4F5A),
            child: Stack(
              children: [
                // Logo
                Align(
                  alignment: Alignment(
                    0.0,
                    _logoYPositionAnimation.value,
                  ),
                  child: Transform.scale(
                    scale: _logoScaleAnimation.value,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final screenWidth = MediaQuery.of(context).size.width;
                        final fontSize = (screenWidth * 0.12).clamp(32.0, 48.0);
                        // Render the official SVG logo (tinted by animation color)
                        return EventosLogoSvg(
                          height: screenWidth * 0.14,
                          color: logoColor,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
