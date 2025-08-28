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
import 'package:flutter/material.dart';
import '../../services/emergencia_service.dart';
import '../../constants/app_colors.dart';

class SosScreen extends StatefulWidget {
  @override
  _SosScreenState createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> {
  final EmergenciaService _emergenciaService = EmergenciaService();
  bool _emergenciaAtiva = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SOS - Emergência'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.warning,
              size: 100,
              color: Colors.red,
            ),
            SizedBox(height: 20),
            Text(
              'Botão de Emergência',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40),
            GestureDetector(
              onTap: _emergenciaAtiva ? null : _ativarEmergencia,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: _emergenciaAtiva ? Colors.grey : Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      spreadRadius: 5,
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'SOS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            if (_emergenciaAtiva) CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  void _ativarEmergencia() async {
    setState(() {
      _emergenciaAtiva = true;
    });
    
    try {
      await _emergenciaService.acionarEmergencia();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Emergência acionada com sucesso!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao acionar emergência: $e')),
      );
    }
    
    setState(() {
      _emergenciaAtiva = false;
    });
  }
}
import 'package:flutter/material.dart';

class SosScreen extends StatelessWidget {
  const SosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SOS'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emergency,
              size: 100,
              color: Colors.red,
            ),
            SizedBox(height: 20),
            Text(
              'Emergência',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Funcionalidade em desenvolvimento',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
