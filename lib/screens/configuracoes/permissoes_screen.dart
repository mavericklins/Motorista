import 'package:flutter/material.dart';
import '../../services/overlay_service.dart';
import '../../constants/app_colors.dart';

class PermissoesScreen extends StatefulWidget {
  const PermissoesScreen({super.key});

  @override
  State<PermissoesScreen> createState() => _PermissoesScreenState();
}

class _PermissoesScreenState extends State<PermissoesScreen> {
  Map<String, bool> _permissions = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    setState(() => _isLoading = true);
    
    try {
      final permissions = await OverlayService.getPermissionsStatus();
      setState(() {
        _permissions = permissions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Erro ao verificar permissões: $e');
    }
  }

  Future<void> _requestAllPermissions() async {
    setState(() => _isLoading = true);
    
    final success = await OverlayService.requestAllPermissions();
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Todas as permissões foram concedidas!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Algumas permissões não foram concedidas'),
          backgroundColor: Colors.orange,
        ),
      );
    }
    
    await _checkPermissions();
  }

  String _getPermissionName(String permission) {
    final names = {
      'Permission.location': 'Localização',
      'Permission.locationAlways': 'Localização em Background',
      'Permission.camera': 'Câmera',
      'Permission.storage': 'Armazenamento',
      'Permission.notification': 'Notificações',
      'overlay': 'Popup sobre outras Apps (CRÍTICO)',
    };
    return names[permission] ?? permission;
  }

  IconData _getPermissionIcon(String permission) {
    final icons = {
      'Permission.location': Icons.location_on,
      'Permission.locationAlways': Icons.location_on,
      'Permission.camera': Icons.camera_alt,
      'Permission.storage': Icons.storage,
      'Permission.notification': Icons.notifications,
      'overlay': Icons.layers,
    };
    return icons[permission] ?? Icons.security;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VelloColors.creme,
      appBar: AppBar(
        title: const Text('Permissões do App'),
        backgroundColor: VelloColors.laranja,
        foregroundColor: VelloColors.branco,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Header explicativo
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: VelloColors.azul.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: VelloColors.azul.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.security,
                          color: VelloColors.azul,
                          size: 40,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Permissões Necessárias',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: VelloColors.azul,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Para funcionar corretamente, o Vello Motorista precisa das seguintes permissões:',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: VelloColors.cinza),
                        ),
                      ],
                    ),
                  ),

                  // Lista de permissões
                  Expanded(
                    child: ListView.builder(
                      itemCount: _permissions.length,
                      itemBuilder: (context, index) {
                        final permission = _permissions.keys.elementAt(index);
                        final isGranted = _permissions[permission] ?? false;
                        final isCritical = permission == 'overlay';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: VelloColors.branco,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isCritical 
                                  ? VelloColors.laranja.withOpacity(0.5)
                                  : Colors.grey.withOpacity(0.3),
                              width: isCritical ? 2 : 1,
                            ),
                          ),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isGranted 
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _getPermissionIcon(permission),
                                color: isGranted ? Colors.green : Colors.red,
                              ),
                            ),
                            title: Text(
                              _getPermissionName(permission),
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: isCritical 
                                ? const Text(
                                    'Necessário para popup de corridas',
                                    style: TextStyle(
                                      color: VelloColors.laranja,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  )
                                : null,
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isGranted ? Colors.green : Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                isGranted ? 'Concedida' : 'Negada',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Botão para solicitar permissões
                  Container(
                    width: double.infinity,
                    height: 56,
                    margin: const EdgeInsets.only(top: 16),
                    child: ElevatedButton(
                      onPressed: _requestAllPermissions,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: VelloColors.laranja,
                        foregroundColor: VelloColors.branco,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.security),
                          SizedBox(width: 8),
                          Text(
                            'Solicitar Todas as Permissões',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Botão de refresh
                  Container(
                    width: double.infinity,
                    height: 48,
                    margin: const EdgeInsets.only(top: 8),
                    child: OutlinedButton(
                      onPressed: _checkPermissions,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: VelloColors.azul,
                        side: const BorderSide(color: VelloColors.azul),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.refresh),
                          SizedBox(width: 8),
                          Text('Verificar Novamente'),
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