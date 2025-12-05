import 'package:flutter/material.dart';
// import '../services/auth_service.dart'; // COMENTADO: No se usa m\u00e1s con autenticaci\u00f3n manual
import '../screens/login_screen.dart';

class AuthGuard extends StatefulWidget {
  final Widget child;

  const AuthGuard({super.key, required this.child});

  @override
  State<AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> {
  // final AuthService _authService = AuthService(); // COMENTADO: No se usa más
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // COMENTADO: Verificación automática deshabilitada
    // Ahora el usuario debe iniciar sesión manualmente o continuar como invitado

    try {
      // final user = await _authService.initialize();
      setState(() {
        _isAuthenticated = false; // Siempre mostrar login/invitado
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isAuthenticated = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Verificando autenticación...'),
            ],
          ),
        ),
      );
    }

    if (!_isAuthenticated) {
      return const LoginScreen();
    }

    return widget.child;
  }
}
