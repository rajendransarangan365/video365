import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/video365_colors.dart';
import 'features/dashboard/screens/home_dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Dark system navigation and status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Video365Colors.mainBg,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    const ProviderScope(
      child: Video365App(),
    ),
  );
}

class Video365App extends StatelessWidget {
  const Video365App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video365',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Video365Colors.mainBg,
        primaryColor: Video365Colors.activeGreen,
        colorScheme: const ColorScheme.dark(
          primary: Video365Colors.activeGreen,
          secondary: Video365Colors.cyanAccent,
          surface: Video365Colors.panelBg,
          background: Video365Colors.mainBg,
        ),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const HomeDashboardScreen(),
    );
  }
}
