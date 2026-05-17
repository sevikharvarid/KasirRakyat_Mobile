import 'package:flutter/material.dart';
import 'package:kasir_rakyat/core/constants/app_colors.dart';
import 'package:kasir_rakyat/features/auth/screens/splash_screen.dart';
import 'package:kasir_rakyat/features/settings/repository/settings_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SettingsRepository.instance.init();
  runApp(const KasirRakyatApp());
}

class KasirRakyatApp extends StatelessWidget {
  const KasirRakyatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KasirRakyat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
        ),
        scaffoldBackgroundColor: AppColors.primarySurface,
        fontFamily: 'Roboto',
      ),
      home: const SplashScreen(),
    );
  }
}
