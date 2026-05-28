import 'package:flutter/material.dart';
import 'package:flowdiagramapp/widgets/auth_guard.dart';
import 'package:flowdiagramapp/screens/load_diagram_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // Wait for 2.5 seconds
    await Future.delayed(const Duration(milliseconds: 2500));

    if (!mounted) return;

    // Navigate to the main app screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const AuthGuard(
          child: LoadDiagramScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              Color(0xFF00E5FF),
              Color(0xFF651FFF),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(
            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
          ),
          child: const Text(
            'Flowcode',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              // The color must be white for the ShaderMask to work correctly
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
