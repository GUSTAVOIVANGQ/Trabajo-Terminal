import 'package:flutter/material.dart';

class PrivacyNoticeScreen extends StatelessWidget {
  const PrivacyNoticeScreen({super.key});

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required String body,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aviso de Privacidad', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2), Color(0xFF4CA1AF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark 
                ? const [Color(0xFF0F172A), Color(0xFF1E293B)]
                : const [Color(0xFFE0C3FC), Color(0xFF8EC5FC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FlowCode - Aviso de Privacidad',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Última actualización: abril 2026',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 20),
              _buildSection(
                context: context,
                title: '1. Responsable del tratamiento',
                body:
                    'El equipo de desarrollo de FlowCode administra la información relacionada con el funcionamiento de la aplicación y la sincronización de diagramas.',
              ),
              _buildSection(
                context: context,
                title: '2. Datos que se procesan',
                body:
                    'Para cuentas registradas se procesan correo electrónico, nombre visible y datos de diagramas cuando el usuario utiliza sincronización. En modo invitado la operación es local y no requiere cuenta.',
              ),
              _buildSection(
                context: context,
                title: '3. Autenticación y seguridad',
                body:
                    'La autenticación se realiza con Firebase Authentication. FlowCode no almacena contraseñas en texto plano dentro de su base local.',
              ),
              _buildSection(
                context: context,
                title: '4. Telemetría de uso (opcional)',
                body:
                    'Si el usuario habilita el envío de telemetría, se registran eventos técnicos de uso mediante Firebase Analytics. Esta telemetría se configura de forma anónima y no se asocia al correo ni al nombre del usuario.',
              ),
              _buildSection(
                context: context,
                title: '5. Modo invitado',
                body:
                    'En modo invitado no se habilita telemetría remota y la información se conserva localmente en el dispositivo, salvo que el usuario decida registrarse posteriormente.',
              ),
              _buildSection(
                context: context,
                title: '6. Derechos y eliminación',
                body:
                    'El usuario con cuenta puede solicitar la eliminación de su cuenta y datos asociados desde la pantalla de perfil. Esta acción elimina información de autenticación y datos sincronizados.',
              ),
              _buildSection(
                context: context,
                title: '7. Cambios al aviso',
                body:
                    'Este aviso puede actualizarse para reflejar cambios funcionales o normativos. Las nuevas versiones se publican dentro de la aplicación y documentación del proyecto.',
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Entendido'),
                ),
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }
}
