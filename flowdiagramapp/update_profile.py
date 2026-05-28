import re

file_path = r'lib\screens\profile_screen.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

pattern_build = re.compile(r'  @override\n  Widget build\(BuildContext context\) \{.*', re.MULTILINE | re.DOTALL)

new_build = '''  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    if (user == null) {
      return const LoginScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              if (_settingsKey.currentContext != null) {
                Scrollable.ensureVisible(_settingsKey.currentContext!, duration: const Duration(milliseconds: 500));
              }
            },
          )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0C3FC), Color(0xFF8EC5FC)], // Nuevo degradado de fondo claro
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 32.0, left: 16, right: 16, bottom: 24),
            child: Column(
              children: [
                // Tarjeta de perfil con avatar superpuesto
                Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 50),
                      width: double.infinity,
                      padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            user.displayName.isEmpty ? 'Usuario' : user.displayName,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '@${user.email.split("@")[0]}',
                            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    // Imagen de perfil circular sobresaliendo arriba
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          GestureDetector(
                            onTap: _isPickingImage ? null : _pickAndSaveProfileImage,
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: user.isAdmin ? Colors.purple : Colors.blue,
                              foregroundImage: _profileImagePath != null
                                  ? FileImage(File(_profileImagePath!))
                                  : null,
                              child: _profileImagePath == null
                                  ? Text(
                                      user.displayName.isNotEmpty
                                          ? user.displayName.substring(0, 1).toUpperCase()
                                          : 'U',
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                          Positioned(
                            right: -4,
                            bottom: -4,
                            child: Material(
                              color: Theme.of(context).primaryColor,
                              shape: const CircleBorder(),
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: _isPickingImage ? null : _pickAndSaveProfileImage,
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: _isPickingImage
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.photo_camera,
                                          size: 18,
                                          color: Colors.white,
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                _buildGradientButton(
                  text: 'Editar Perfil',
                  colors: [const Color(0xFF6A11CB), const Color(0xFF2575FC)],
                  onTap: () => _showComingSoonToast('Editar Perfil'),
                ),
                const SizedBox(height: 12),
                _buildGradientButton(
                  text: 'Suscripción',
                  colors: [const Color(0xFF00B4DB), const Color(0xFF0083B0)],
                  onTap: _showSubscriptionModal,
                ),

                const SizedBox(height: 24),

                _buildSectionCard(
                  title: 'Información de la cuenta',
                  children: [
                    _buildListTile(icon: Icons.email_outlined, title: user.email, subtitle: 'Correo electrónico'),
                    _buildListTile(icon: Icons.admin_panel_settings_outlined, title: user.isAdmin ? 'Administrador' : 'Usuario', subtitle: 'Tipo de cuenta'),
                    _buildListTile(icon: Icons.calendar_today_outlined, title: DateFormat("dd/MM/yyyy").format(user.createdAt), subtitle: 'Fecha de registro'),
                    _buildListTile(icon: Icons.access_time_outlined, title: DateFormat("dd/MM/yyyy HH:mm").format(user.lastLogin), subtitle: 'Último acceso'),
                  ],
                ),

                _buildSectionCard(
                  title: 'Mis Métricas',
                  children: [
                    ListTile(
                      leading: const Icon(Icons.analytics_outlined),
                      title: const Text('Ver estadísticas de uso y progreso'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const MetricsScreen()));
                      },
                    ),
                    if (user.metrics.isNotEmpty) ...[
                      const Divider(height: 1),
                      if (user.metrics.containsKey("diagramas_creados"))
                        _buildListTile(icon: Icons.account_tree, title: user.metrics["diagramas_creados"].toString(), subtitle: 'Diagramas creados'),
                      if (user.metrics.containsKey("codigo_generado"))
                        _buildListTile(icon: Icons.code, title: user.metrics["codigo_generado"].toString(), subtitle: 'Código generado'),
                      if (user.metrics.containsKey("total_validaciones"))
                        _buildListTile(icon: Icons.check_circle, title: user.metrics["total_validaciones"].toString(), subtitle: 'Validaciones realizadas'),
                    ]
                  ],
                ),

                _buildSectionCard(
                  title: 'Estado de suscripción',
                  children: [
                    _buildListTile(icon: Icons.workspace_premium_outlined, title: 'Plan Gratuito', subtitle: 'Actualiza para obtener más funciones'),
                  ],
                ),

                _buildSectionCard(
                  title: 'Seguridad',
                  children: [
                    ListTile(
                      leading: const Icon(Icons.security_outlined),
                      title: const Text('Cambiar contraseña, sesiones'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showComingSoonToast('Seguridad'),
                    ),
                  ],
                ),

                _buildSectionCard(
                  title: 'Cuentas conectadas',
                  children: [
                    ListTile(
                      leading: const Icon(Icons.link_outlined),
                      title: Row(
                        children: [
                          _buildIconBadge(Icons.code, Colors.black),
                          const SizedBox(width: 8),
                          _buildIconBadge(Icons.brush, Colors.blue),
                          const SizedBox(width: 8),
                          _buildIconBadge(Icons.g_mobiledata, Colors.red),
                        ],
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showComingSoonToast('Cuentas conectadas'),
                    ),
                  ],
                ),

                _buildSectionCard(
                  key: _settingsKey,
                  title: 'Configuración general',
                  children: [
                    ListTile(
                      leading: const Icon(Icons.palette_outlined),
                      title: const Text('Tema'),
                      subtitle: Text(ThemeService().getThemeName()),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ThemeSettingsScreen()));
                      },
                    ),
                    const Divider(height: 1),
                    SwitchListTile.adaptive(
                      secondary: const Icon(Icons.save_as_outlined),
                      title: const Text('Autoguardado (2s)'),
                      subtitle: Text(_updatingAutoSavePreference ? 'Guardando...' : 'Guarda cambios automáticamente'),
                      value: _autoSaveEnabled,
                      onChanged: _updatingAutoSavePreference ? null : _updateAutoSavePreference,
                    ),
                    const Divider(height: 1),
                    SwitchListTile.adaptive(
                      secondary: const Icon(Icons.analytics_outlined),
                      title: const Text('Telemetría de uso'),
                      value: user.isGuest ? false : _telemetryConsent,
                      onChanged: user.isGuest || _updatingTelemetryConsent ? null : _updateTelemetryConsent,
                    ),
                    const Divider(height: 1),
                    SwitchListTile.adaptive(
                      secondary: const Icon(Icons.bug_report_outlined),
                      title: const Text('Reportes de fallos'),
                      value: user.isGuest ? false : _crashReportsConsent,
                      onChanged: user.isGuest || _updatingCrashReportsConsent ? null : _updateCrashReportsConsent,
                    ),
                  ],
                ),

                _buildSectionCard(
                  key: _syncKey,
                  title: 'Datos',
                  children: [
                    ListTile(
                      leading: _isSyncing
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.cloud_sync, color: Colors.blue),
                      title: const Text('Sincronizar datos'),
                      subtitle: Text(user.isGuest ? 'No disponible para invitados' : 'Respalda tus diagramas en la nube'),
                      trailing: user.isGuest ? const Icon(Icons.lock_outline, color: Colors.grey) : const Icon(Icons.chevron_right),
                      enabled: !user.isGuest && !_isSyncing,
                      onTap: user.isGuest ? null : _performSync,
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: _isDeleting
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red))
                          : const Icon(Icons.delete_forever, color: Colors.red),
                      title: Text(user.isGuest ? 'Eliminar datos locales' : 'Eliminar cuenta', style: const TextStyle(color: Colors.red)),
                      trailing: const Icon(Icons.chevron_right, color: Colors.red),
                      enabled: !_isDeleting,
                      onTap: user.isGuest ? _deleteGuestData : _showDeleteAccountDialog,
                    ),
                  ],
                ),

                if (user.isAdmin) ...[
                  _buildSectionCard(
                    title: 'Administración',
                    children: [
                      ListTile(
                        leading: const Icon(Icons.admin_panel_settings, color: Colors.purple),
                        title: const Text('Panel de Administración'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AdminMetricsScreen()));
                        },
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 16),

                _buildGradientButton(
                  text: 'Cerrar Sesión',
                  colors: [Colors.red.shade400, Colors.red.shade700],
                  onTap: _signOut,
                ),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGradientButton({required String text, required List<Color> colors, required VoidCallback onTap}) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: colors.last.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: onTap,
          child: Center(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required List<Widget> children, Key? key}) {
    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 8),
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildListTile({required IconData icon, required String title, required String subtitle}) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle),
    );
  }

  Widget _buildIconBadge(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 20, color: color),
    );
  }
}'''

content = pattern_build.sub(new_build, content)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
