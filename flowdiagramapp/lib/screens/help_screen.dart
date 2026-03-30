import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'tutorial_list_screen.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const supportEmail = 'soporte.flowcode.app@gmail.com';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayuda'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Centro de ayuda',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Desde esta sección puedes revisar cómo usar la pantalla de carga y qué acciones te conviene realizar antes de editar o crear un diagrama.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const _HelpCard(
            title: '¿Qué puedes hacer en esta pantalla?',
            icon: Icons.dashboard_customize_outlined,
            items: [
              'Mis diagramas: abre, edita o elimina tus diagramas guardados.',
              'Plantillas: inicia más rápido a partir de una estructura base.',
              'Crear nuevo: abre el editor visual para construir un diagrama desde cero.',
              'Mi perfil: revisa tu cuenta y opciones personales.',
            ],
          ),
          const SizedBox(height: 12),
          const _HelpCard(
            title: 'Sugerencias de uso',
            icon: Icons.tips_and_updates_outlined,
            items: [
              'Usa una plantilla cuando necesites avanzar rápido en una estructura común.',
              'Nombra tus diagramas con un título claro para encontrarlos fácilmente.',
              'Guarda cambios con frecuencia mientras ajustas nodos y conexiones.',
              'Antes de compilar, revisa que el flujo tenga inicio y fin válidos.',
            ],
          ),
          const SizedBox(height: 12),
          const _FaqSection(),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.menu_book_outlined),
                      SizedBox(width: 8),
                      Text(
                        '¿Necesitas guía paso a paso?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Abre la sección de tutoriales para consultar instrucciones detalladas y ejemplos listos para usar.',
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const TutorialListScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.quiz_outlined),
                    label: const Text('Abrir tutoriales'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const _ContactSection(supportEmail: supportEmail),
        ],
      ),
    );
  }
}

class _HelpCard extends StatelessWidget {
  const _HelpCard({
    required this.title,
    required this.icon,
    required this.items,
  });

  final String title;
  final IconData icon;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• '),
                    Expanded(child: Text(item)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FaqSection extends StatelessWidget {
  const _FaqSection();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16, 6, 16, 2),
              child: Row(
                children: [
                  Icon(Icons.help_center_outlined),
                  SizedBox(width: 8),
                  Text(
                    'Preguntas frecuentes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 14),
            _FaqItem(
              question: '¿Dónde se guardan mis diagramas?',
              answer:
                  'Tus diagramas se almacenan localmente en el dispositivo y aparecen en la pestaña "Mis diagramas".',
            ),
            _FaqItem(
              question: '¿Cómo uso una plantilla?',
              answer:
                  'Abre la pestaña "Plantillas", selecciona una y se cargará en el editor para que la ajustes según tu necesidad.',
            ),
            _FaqItem(
              question: '¿Por qué no se genera código C?',
              answer:
                  'Verifica que el diagrama tenga inicio y fin válidos, y que las conexiones no tengan errores estructurales.',
            ),
            _FaqItem(
              question: '¿Qué hago si detecto un fallo?',
              answer:
                  'Usa el botón "Reportar problema" y comparte los pasos, el resultado esperado y una captura de pantalla.',
            ),
          ],
        ),
      ),
    );
  }
}

class _FaqItem extends StatelessWidget {
  const _FaqItem({
    required this.question,
    required this.answer,
  });

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(question),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(answer),
        ),
      ],
    );
  }
}

class _ContactSection extends StatelessWidget {
  const _ContactSection({required this.supportEmail});

  final String supportEmail;

  Future<String> _buildSupportMetadata() async {
    final timestamp = DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now());
    var appVersion = 'No disponible';

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      appVersion = packageInfo.buildNumber.isEmpty
          ? packageInfo.version
          : '${packageInfo.version} (${packageInfo.buildNumber})';
    } catch (_) {
      // Si no se puede leer la versión, se usa el valor por defecto.
    }

    return 'Fecha y hora: $timestamp\nVersión de app: $appVersion';
  }

  Future<void> _copyEmail(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: supportEmail));
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Correo copiado: $supportEmail')),
    );
  }

  void _showContactDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 12),
            const Text(
              'Correo de soporte:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            SelectableText(supportEmail),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await _copyEmail(context);
            },
            child: const Text('Copiar correo'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Future<void> _openEmailDraft(
    BuildContext context, {
    required String subject,
    required String body,
    required String fallbackTitle,
    required String fallbackMessage,
  }) async {
    final emailUri = Uri(
      scheme: 'mailto',
      path: supportEmail,
      queryParameters: {
        'subject': subject,
        'body': body,
      },
    );

    final opened = await launchUrl(emailUri);
    if (opened) return;
    if (!context.mounted) return;

    _showContactDialog(
      context,
      title: fallbackTitle,
      message:
          '$fallbackMessage\n\nNo se pudo abrir la app de correo en este dispositivo. Puedes copiar el correo y enviarlo manualmente.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.support_agent_outlined),
                SizedBox(width: 8),
                Text(
                  'Contacto y reporte',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Si necesitas asistencia o deseas reportar un problema, usa uno de los siguientes botones.',
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: () async {
                    final metadata = await _buildSupportMetadata();
                    if (!context.mounted) return;

                    await _openEmailDraft(
                      context,
                      subject: 'Soporte FlowCode - Consulta',
                      body:
                          'Hola equipo de FlowCode,\n\nNecesito ayuda con:\n\nDetalle:\n\n$metadata\n\nGracias.',
                      fallbackTitle: 'Contacto de soporte',
                      fallbackMessage:
                          'Puedes comunicarte con el equipo para consultas generales sobre la aplicación.',
                    );
                  },
                  icon: const Icon(Icons.mail_outline),
                  label: const Text('Contactar soporte'),
                ),
                OutlinedButton.icon(
                  onPressed: () async {
                    final metadata = await _buildSupportMetadata();
                    if (!context.mounted) return;

                    await _openEmailDraft(
                      context,
                      subject: 'FlowCode - Reporte de problema',
                      body:
                          'Hola equipo de FlowCode,\n\nQuiero reportar un problema:\n\nPasos para reproducir:\n1. \n2. \n3. \n\nResultado esperado:\n\nResultado obtenido:\n\nDispositivo/Android:\n\n$metadata\n\nGracias.',
                      fallbackTitle: 'Reportar problema',
                      fallbackMessage:
                          'Incluye pasos para reproducir el fallo, resultado esperado y una captura si es posible.',
                    );
                  },
                  icon: const Icon(Icons.bug_report_outlined),
                  label: const Text('Reportar problema'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
