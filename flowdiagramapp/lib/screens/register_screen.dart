import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import 'login_screen.dart';
import 'privacy_notice_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _privacyAccepted = false;
  bool _telemetryConsent = false;
  bool _crashReportsConsent = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _openPrivacyNotice() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PrivacyNoticeScreen(),
      ),
    );
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_privacyAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes aceptar el Aviso de Privacidad para continuar.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print('🔄 Iniciando registro para: ${_emailController.text.trim()}');

      final user = await _authService.registerWithEmailPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        displayName: _nameController.text.trim(),
        // Rol forzado para registros desde Play Store.
        role: UserRole.user,
        telemetryOptIn: _telemetryConsent,
        crashReportsOptIn: _crashReportsConsent,
      );

      if (user != null && mounted) {
        print('✅ Usuario registrado exitosamente: ${user.uid}');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                '¡Cuenta creada exitosamente! Inicia sesión para continuar.'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );

        // Cerrar sesión inmediatamente para forzar login explícito tras registro.
        await _authService.signOut();

        // Pequeña pausa para que el usuario vea el mensaje de éxito.
        await Future.delayed(const Duration(milliseconds: 500));

        if (!mounted) return;

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      } else {
        throw Exception('No se pudo crear la cuenta. Intenta nuevamente.');
      }
    } catch (e) {
      print('❌ Error en registro: $e');

      if (mounted) {
        String errorMessage = e.toString().replaceFirst('Exception: ', '');

        // Mejorar mensajes de error comunes
        if (errorMessage.contains('email-already-in-use')) {
          errorMessage =
              'Este email ya está registrado. ¿Quieres iniciar sesión?';
        } else if (errorMessage.contains('weak-password')) {
          errorMessage = 'La contraseña debe tener al menos 6 caracteres.';
        } else if (errorMessage.contains('invalid-email')) {
          errorMessage = 'El formato del email no es válido.';
        } else if (errorMessage.contains('network')) {
          errorMessage = 'Error de conexión. Verifica tu internet.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            action: errorMessage.contains('iniciar sesión')
                ? SnackBarAction(
                    label: 'Ir al Login',
                    textColor: Colors.white,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                : null,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Cuenta'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  Text(
                    'Únete a FlowCode',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Crea tu cuenta para comenzar a diseñar algoritmos',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),

                  const SizedBox(height: 32),

                  // Campo de nombre
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre completo',
                      prefixIcon: Icon(Icons.person_outlined),
                      border: OutlineInputBorder(),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa tu nombre';
                      }
                      if (value.length < 2) {
                        return 'El nombre debe tener al menos 2 caracteres';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Campo de email
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Correo electrónico',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa tu correo electrónico';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return 'Por favor ingresa un correo electrónico válido';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  /*
                  // Selector de rol
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tipo de cuenta',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          ListTile(
                            title: const Text('Usuario'),
                            subtitle: const Text(
                                'Acceso a diagramas personales y métricas propias'),
                            leading: Radio<UserRole>(
                              value: UserRole.user,
                              groupValue: _selectedRole,
                              onChanged: (UserRole? value) {
                                setState(() {
                                  _selectedRole = value!;
                                });
                              },
                            ),
                            contentPadding: EdgeInsets.zero,
                          ),
                          ListTile(
                            title: const Text('Administrador'),
                            subtitle: const Text(
                                'Acceso a métricas globales y gestión de usuarios'),
                            leading: Radio<UserRole>(
                              value: UserRole.admin,
                              groupValue: _selectedRole,
                              onChanged: (UserRole? value) {
                                setState(() {
                                  _selectedRole = value!;
                                });
                              },
                            ),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  */

                  // Campo de contraseña
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa una contraseña';
                      }
                      if (value.length < 6) {
                        return 'La contraseña debe tener al menos 6 caracteres';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Campo de confirmar contraseña
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Confirmar contraseña',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    obscureText: _obscureConfirmPassword,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _register(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor confirma tu contraseña';
                      }
                      if (value != _passwordController.text) {
                        return 'Las contraseñas no coinciden';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      children: [
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          controlAffinity: ListTileControlAffinity.leading,
                          title: const Text('Acepto el Aviso de Privacidad'),
                          subtitle:
                              const Text('Obligatorio para crear cuenta.'),
                          value: _privacyAccepted,
                          onChanged: _isLoading
                              ? null
                              : (value) {
                                  setState(() {
                                    _privacyAccepted = value ?? false;
                                  });
                                },
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: _isLoading ? null : _openPrivacyNotice,
                            icon: const Icon(Icons.privacy_tip_outlined),
                            label: const Text('Leer Aviso de Privacidad'),
                          ),
                        ),
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          controlAffinity: ListTileControlAffinity.leading,
                          title: const Text(
                              'Permitir envío de datos de uso (Analytics)'),
                          subtitle: const Text(
                            'Opcional. Se usa para mejorar la app y no envía correo ni nombre.',
                          ),
                          value: _telemetryConsent,
                          onChanged: _isLoading
                              ? null
                              : (value) {
                                  setState(() {
                                    _telemetryConsent = value ?? false;
                                  });
                                },
                        ),
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          controlAffinity: ListTileControlAffinity.leading,
                          title: const Text(
                              'Permitir envío de reportes de fallos (Crash Report)'),
                          subtitle: const Text(
                            'Opcional. Envía errores técnicos para diagnóstico.',
                          ),
                          value: _crashReportsConsent,
                          onChanged: _isLoading
                              ? null
                              : (value) {
                                  setState(() {
                                    _crashReportsConsent = value ?? false;
                                  });
                                },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Botón de registro
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(
                      onPressed:
                          (_isLoading || !_privacyAccepted) ? null : _register,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Crear Cuenta'),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Información adicional
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: Colors.blue[700], size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Se requiere conexión a internet para crear una cuenta nueva',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
