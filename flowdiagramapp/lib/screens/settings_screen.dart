import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'help_screen.dart';
import 'privacy_notice_screen.dart';
import 'theme_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [Color(0xFF0F172A), Color(0xFF1E1B4B), Color(0xFF020617)]
                : const [Color(0xFFE8F5F3), Color(0xFFF3E7FC), Color(0xFFF5F0FF)],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.only(top: 16.0, left: 8.0),
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black87),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Text(
                  'Ajustes',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // List
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  children: [
                    _buildSectionHeader(context, 'Cuenta personal'),
                    _buildListItem(
                      context,
                      icon: Icons.person_outline,
                      title: 'Tu perfil',
                      destination: const ProfileScreen(),
                    ),
                    _buildListItem(
                      context,
                      icon: Icons.palette_outlined,
                      title: 'Ajustes de tema',
                      destination: const ThemeSettingsScreen(),
                    ),
                    _buildListItem(
                      context,
                      icon: Icons.lock_outline,
                      title: 'Privacidad',
                      destination: const PrivacyNoticeScreen(),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader(context, 'Soporte e información'),
                    _buildListItem(
                      context,
                      icon: Icons.help_outline,
                      title: 'Ayuda y Preguntas frecuentes',
                      destination: const HelpScreen(),
                    ),
                    _buildListItem(
                      context,
                      icon: Icons.info_outline,
                      title: 'Acerca de Flowcode',
                      onTap: () {
                        showAboutDialog(
                          context: context,
                          applicationName: 'Flowcode',
                          applicationVersion: '1.0.0',
                          applicationIcon: const Icon(Icons.account_tree, size: 48, color: Colors.deepPurple),
                          children: [
                            const Text('Aplicación para crear diagramas de flujo educativos.'),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildListItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    Widget? destination,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap ??
            () {
              if (destination != null) {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => destination),
                );
              }
            },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Row(
            children: [
              Icon(icon, color: isDark ? Colors.white : Colors.black87, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: isDark ? Colors.grey[400] : Colors.black54),
            ],
          ),
        ),
      ),
    );
  }
}
