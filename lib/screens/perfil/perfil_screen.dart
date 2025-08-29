import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../widgets/common/vello_card.dart';
import '../../widgets/common/vello_button.dart';
import '../../widgets/common/status_chip.dart';
import '../../theme/vello_tokens.dart';
import 'package:vello_motorista/screens/configuracoes/alterar_senha/alterar_senha_screen.dart';
import 'package:vello_motorista/screens/configuracoes/notificacoes_screen.dart';
import 'package:vello_motorista/screens/suporte/suporte_screen.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  static const Color velloBlue = Color(0xFF1B3A57);
  static const Color velloOrange = Color(0xFFFF8C42);
  static const Color velloLightGray = Color(0xFFF8F9FA);
  static const Color velloCardBackground = Color(0xFFFFFFFF);

  String nomeMotorista = 'João Silva';
  String emailMotorista = 'joao.silva@email.com';
  String telefoneMotorista = '(11) 99999-9999';
  String placaVeiculo = 'ABC-1234';
  String modeloVeiculo = 'Honda Civic 2020';
  double avaliacaoMedia = 4.8;
  int totalCorridas = 1247;
  String statusMotorista = 'Ativo';

  // Mock data for the new design
  final Map<String, dynamic> _profileData = {
    'nome': 'João Silva',
    'email': 'joao.silva@email.com',
    'telefone': '(11) 99999-9999',
    'avaliacao': 4.8,
    'totalAvaliacoes': 156,
    'veiculo': 'Honda Civic 2020',
    'placa': 'ABC-1234',
    'status': 'Ativo',
    'totalCorridas': 1247,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VelloTokens.gray50,
      appBar: AppBar(
        title: const Text(
          'Meu Perfil',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: VelloTokens.brand,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editProfile,
            tooltip: 'Editar perfil',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 20),
            _buildProfileStats(),
            const SizedBox(height: 20),
            _buildProfileOptions(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return VelloCard.gradient(
      gradient: const LinearGradient(
        colors: [VelloTokens.brand, VelloTokens.brandLight],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.5),
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: VelloTokens.gray600,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: VelloTokens.success,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.verified,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _profileData['nome'] ?? 'Nome do Motorista',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.star,
                  color: VelloTokens.warning,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  '${_profileData['avaliacao'] ?? '4.8'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '(${_profileData['totalAvaliacoes'] ?? '156'} avaliações)',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.local_taxi,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Motorista Premium',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileStats() {
    return VelloCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Estatísticas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: VelloTokens.gray900,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: StatusChip(
                    icon: Icons.directions_car,
                    label: 'Corridas',
                    value: _profileData['totalCorridas'].toString(),
                    valueColor: VelloTokens.brand,
                    labelColor: VelloTokens.gray600,
                    iconColor: VelloTokens.brand,
                    status: DriverStatus.online,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatusChip(
                    icon: Icons.local_activity,
                    label: 'Status',
                    value: _profileData['status'] ?? 'Indisponível',
                    valueColor: VelloTokens.success,
                    labelColor: VelloTokens.gray600,
                    iconColor: VelloTokens.success,
                    status: DriverStatus.online,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOptions() {
    return VelloCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildActionItem(
              Icons.car_rental,
              'Meu Veículo',
              _profileData['veiculo'],
              () => _editVehicle(),
            ),
            const Divider(height: 24),
            _buildActionItem(
              Icons.security,
              'Alterar Senha',
              'Mantenha sua conta segura',
              () => _changePassword(),
            ),
            const Divider(height: 24),
            _buildActionItem(
              Icons.notifications,
              'Notificações',
              'Gerencie suas preferências',
              () => _configureNotifications(),
            ),
            const Divider(height: 24),
            _buildActionItem(
              Icons.help,
              'Suporte',
              'Precisa de ajuda?',
              () => _openSupport(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: VelloTokens.brand.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: VelloTokens.brand, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: VelloTokens.gray900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: VelloTokens.gray600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: VelloTokens.gray600,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return VelloButton.danger(
      onPressed: _logout,
      text: 'Sair da Conta',
      icon: Icons.logout,
    );
  }

  void _editProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Abrindo edição de perfil...')),
    );
  }

  void _editVehicle() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Abrindo edição de veículo...')),
    );
  }

  void _changePassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AlterarSenhaScreen()),
    );
  }

  void _configureNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotificacoesScreen()),
    );
  }

  void _openSupport() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SuporteScreen()),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Saída'),
          content: const Text('Tem certeza que deseja sair da sua conta?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
              ),
              child: const Text('Sair'),
            ),
          ],
        );
      },
    );
  }
}