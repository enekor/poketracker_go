// lib/features/settings/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:poketracker_go/features/settings/settings_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = Get.put(SettingsService());
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes y Datos'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSectionHeader(context, 'GESTIÓN DE DATOS', Icons.storage_rounded),
          const SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                    child: Icon(Icons.share_rounded, color: theme.colorScheme.primary),
                  ),
                  title: const Text('Exportar Base de Datos', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Guarda tus capturas en un archivo JSON para tener copia.'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: service.exportData,
                ),
                Divider(height: 1, indent: 70, color: theme.colorScheme.onSurface.withOpacity(0.05)),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.secondary.withOpacity(0.1),
                    child: Icon(Icons.file_open_rounded, color: theme.colorScheme.secondary),
                  ),
                  title: const Text('Importar Base de Datos', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Restaura tus capturas desde un archivo .json exportado previamente.'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: service.importData,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Al importar datos, se sobreescribirán los datos actuales por los del archivo. ¡Asegúrate de tener la copia correcta!',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.primary.withOpacity(0.6)),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: theme.colorScheme.primary.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}
