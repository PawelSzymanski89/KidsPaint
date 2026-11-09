import 'package:flutter/material.dart';
import 'services/image_loader.dart';
import 'services/window_service.dart';
import 'ui/kids_paint_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await WindowService.instance.initialize();
  await TuxImageCache.preloadAllBrushes();
  runApp(const KidsPaintApp());
}

class KidsPaintApp extends StatelessWidget {
  const KidsPaintApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KidsPaint',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF5A5F),
          surface: const Color(0xFFF0F4F8),
        ),
      ),
      home: const KidsPaintScreen(),
    );
  }
}
