import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'core/auth/auth_controller.dart';
import 'core/location/location_provider.dart';
import 'features/listings/presentation/my_listings_viewmodel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthController()..initializeAuth(),
        ),
        ChangeNotifierProvider(
          create: (_) => LocationProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => MyListingsViewModel(),
        ),
      ],
      child: MaterialApp(
        title: 'EVENTOS',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.orange,
          useMaterial3: true,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        builder: (context, child) {
          final mq = MediaQuery.of(context);
          // Clamp text scale factor to avoid extreme scaling on very small/large devices
          final clampedTextScale = mq.textScaleFactor.clamp(0.85, 1.30);
          return MediaQuery(
            data: mq.copyWith(textScaleFactor: clampedTextScale),
            child: child ?? const SizedBox.shrink(),
          );
        },
        home: const SplashScreen(),
      ),
    );
  }
}
