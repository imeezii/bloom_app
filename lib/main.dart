import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'screens/splash.dart';

void main() => runApp(
  DevicePreview(enabled: true, builder: (context) => const BloomApp()),
);

class BloomApp extends StatelessWidget {
  const BloomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const SplashScreen(),
    );
  }
}
