import 'package:flutter/material.dart';
import 'package:vello_motorista/services/advanced_security_service.dart';

class SOSScreen extends StatelessWidget {
  final AdvancedSecurityService _securityService = AdvancedSecurityService();

  SOSScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SOS Emergência'),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () => _securityService.shareLocation(),
              icon: const Icon(Icons.location_on),
              label: const Text('Compartilhar Localização'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _securityService.callEmergency('190'),
              icon: const Icon(Icons.phone),
              label: const Text('Ligar para Emergência'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _securityService.activateEmergency(),
              icon: const Icon(Icons.warning),
              label: const Text('Ativar Emergência'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            ),
          ],
        ),
      ),
    );
  }
}