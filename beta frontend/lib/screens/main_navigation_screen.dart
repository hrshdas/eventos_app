import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../core/auth/auth_controller.dart';
import 'home_screen.dart';
import 'event_screen.dart';
import 'profile_screen.dart';
import 'ai_planner_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final int? initialIndex;
  
  const MainNavigationScreen({super.key, this.initialIndex});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;
  
  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    // Use Consumer to rebuild when AuthController changes (when user logs in)
    return Consumer<AuthController>(
      builder: (context, authController, _) {
        // Get user ID to use as key for ProfileScreenContent - forces rebuild when user changes
        final userKey = authController.currentUser?.id ?? 'no-user';
        
        final screens = [
          const HomeScreenContent(),
          const AiPlannerScreenContent(),
          const EventScreenContent(),
          ProfileScreenContent(key: ValueKey('profile-$userKey')), // Key changes when user changes
        ];
        
        return Scaffold(
          backgroundColor: AppTheme.lightGrey,
          body: IndexedStack(
            index: _currentIndex,
            children: screens,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppTheme.primaryColor,
            unselectedItemColor: AppTheme.textGrey,
            backgroundColor: AppTheme.white,
            elevation: 8,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bolt),
                label: 'AI Planner',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today),
                label: 'My Events',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }
}

// Placeholder screen for tabs that don't have screens yet
class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      body: Center(
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
      ),
    );
  }
}
