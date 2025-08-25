import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/login_screen.dart';
import '../settings/change_password_screen.dart';
import '../settings/notifications_screen.dart';
import '../support/support_screen.dart';

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

  String? _uid;
  DocumentReference<Map<String, dynamic>>? _driverDocRef;

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser?.uid;
    if (_uid != null) {
      _driverDocRef =
          FirebaseFirestore.instance.collection('motoristas').doc(_uid);
    }
    
    // Limpar qualquer SnackBar ou overlay que possa estar ativo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _clearAnyActiveOverlays();
    });
  }

  @override
  void dispose() {
    // Limpar recursos antes de sair da tela
    _clearAnyActiveOverlays();
    super.dispose();
  }

  /// Limpa qualquer overlay ativo que possa estar causando sobreposições
  void _clearAnyActiveOverlays() {
    try {
      // Remove qualquer SnackBar ativo
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        
        // Aguarda um frame e limpa novamente para garantir
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).clearSnackBars();
          }
        });
      }
    } catch (e) {
      // Ignora se não há context válido ainda
      print('Debug: Não foi possível limpar overlays: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Limpar overlays sempre que a tela for reconstruída
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _clearAnyActiveOverlays();
    });

    return WillPopScope(
      onWillPop: () async {
        // Limpar overlays ao sair da tela
        _clearAnyActiveOverlays();
        return true;
      },
      child: Scaffold(
        backgroundColor: velloLightGray,
        resizeToAvoidBottomInset: false, // Evitar redimensionamento que possa causar sobreposições
        appBar: AppBar(
          title: const Text(
            'Meu Perfil',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: velloOrange,
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              onPressed: _editarPerfil,
              icon: const Icon(Icons.edit),
              tooltip: 'Editar Perfil',
            ),
          ],
        ),
        // Usar um Stack para garantir isolamento total e controle de z-index
        body: Stack(
          children: [
            // Background container para garantir que não há vazamentos visuais
            Container(
              width: double.infinity,
              height: double.infinity,
              color: velloLightGray,
            ),
            // Conteúdo principal isolado
            Positioned.fill(
              child: _uid == null || _driverDocRef == null
                  ? const Center(child: Text('Usuário não autenticado.'))
                  : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: _driverDocRef!.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Center(
                      child: Text('Perfil não encontrado. Aguarde aprovação.'),
                    );
                  }

                  final data = snapshot.data!.data() ?? {};

                  final String nome = (data['nome'] ?? 'Sem nome').toString();
                  final String email = (data['email'] ?? '').toString();
                  final String telefone =
                  (data['telefone'] ?? data['telefoneE164'] ?? '').toString();
                  final String fotoUrl =
                  (data['selfieUrl'] ?? data['foto_url'] ?? '').toString();

                  final String modeloVeiculo =
                  (data['modelo'] ?? 'Sem modelo').toString();
                  final String placaVeiculo =
                  (data['placa'] ?? '---').toString();
                  final String carroUrl = (data['carroUrl'] ?? '').toString();

                  final double ratingMedia =
                  (data['rating_media'] ?? 0.0).toDouble();
                  final int totalCorridas =
                  (data['total_corridas'] ?? 0) is int
                      ? (data['total_corridas'] ?? 0)
                      : int.tryParse(
                      (data['total_corridas'] ?? '0').toString()) ??
                      0;
                  final String dataRegistro = _formatarData(
                      (data['createdAt'] ?? data['criadoEm'] ?? null));

                  return Container(
                    color: velloLightGray, // Background extra para garantir isolamento
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      physics: const ClampingScrollPhysics(), // Controle de scroll mais robusto
                      child: Column(
                        children: [
                          _buildPerfilCard(
                            nome: nome,
                            email: email,
                            telefone: telefone,
                            fotoUrl: fotoUrl,
                            ratingMedia: ratingMedia,
                          ),
                          const SizedBox(height: 16),
                          _buildEstatisticasCard(
                            totalCorridas: totalCorridas,
                            dataRegistro: dataRegistro,
                          ),
                          const SizedBox(height: 16),
                          _buildVeiculoCard(
                            modeloVeiculo: modeloVeiculo,
                            placaVeiculo: placaVeiculo,
                            carroUrl: carroUrl,
                          ),
                          const SizedBox(height: 16),
                          _buildConfiguracoesRapidasCard(),
                          const SizedBox(height: 16),
                          _buildLogoutButton(),
                          // Espaço extra para garantir que não há sobreposições
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // Overlay de debug para verificar se há elementos sobrepostos (opcional)
            if (false) // Mude para true para debugar
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red, width: 2),
                    ),
                    child: const Center(
                      child: Text(
                        'DEBUG: Tela de Perfil',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerfilCard({
    required String nome,
    required String email,
    required String telefone,
    required String fotoUrl,
    required double ratingMedia,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _boxStyle(),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: velloOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: velloOrange, width: 3),
            ),
            clipBehavior: Clip.antiAlias,
            child: fotoUrl.isNotEmpty
                ? Image.network(
              fotoUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
              const Icon(Icons.person, size: 40, color: velloOrange),
            )
                : const Icon(Icons.person, size: 40, color: velloOrange),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nome,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: velloBlue)),
                const SizedBox(height: 4),
                Text(email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 2),
                Text(telefone,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFBBF24).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.star,
                        color: Color(0xFFFBBF24), size: 20),
                    const SizedBox(width: 4),
                    Text(ratingMedia.toStringAsFixed(1),
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: velloBlue)),
                  ],
                ),
                const SizedBox(height: 4),
                const Text('Avaliação',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFBBF24))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstatisticasCard({
    required int totalCorridas,
    required String dataRegistro,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _boxStyle(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Estatísticas',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: velloBlue)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: _buildStatItem(Icons.directions_car,
                      'Total de Corridas', totalCorridas.toString(), velloOrange)),
              const SizedBox(width: 16),
              Expanded(
                  child: _buildStatItem(Icons.calendar_today, 'Membro desde',
                      dataRegistro, const Color(0xFF3B82F6))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
        ],
      ),
    );
  }

  Widget _buildVeiculoCard({
    required String modeloVeiculo,
    required String placaVeiculo,
    required String carroUrl,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 0),
      decoration: _boxStyle(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Cabeçalho da seção
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Meu Veículo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: velloBlue,
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: _editarVeiculo,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.edit,
                      size: 20,
                      color: velloOrange,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Conteúdo principal
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ícone do veículo
              Container(
                width: 64,
                height: 64,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: velloOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.directions_car,
                  color: velloOrange,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              
              // Informações do veículo
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Modelo do veículo
                    Text(
                      modeloVeiculo.isEmpty ? 'Modelo não informado' : modeloVeiculo,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: velloBlue,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    
                    // Placa do veículo
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: const Color(0xFFE5E7EB),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'Placa: ${placaVeiculo.isEmpty ? "---" : placaVeiculo.toUpperCase()}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF374151),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Imagem do veículo (se disponível)
          if (carroUrl.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFFF9FAFB),
                border: Border.all(
                  color: const Color(0xFFE5E7EB),
                  width: 1,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.network(
                carroUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(velloOrange),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_not_supported_outlined,
                          size: 32,
                          color: Color(0xFF9CA3AF),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Imagem não disponível',
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConfiguracoesRapidasCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _boxStyle(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ações Rápidas',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: velloBlue)),
          const SizedBox(height: 16),
          _buildActionItem(Icons.security, 'Alterar Senha',
              'Mantenha sua conta segura', () => _alterarSenha()),
          const Divider(height: 24),
          _buildActionItem(Icons.notifications, 'Notificações',
              'Gerencie suas preferências', () => _configurarNotificacoes()),
          const Divider(height: 24),
          _buildActionItem(Icons.help, 'Suporte', 'Precisa de ajuda?',
                  () => _abrirSuporte()),
        ],
      ),
    );
  }

  Widget _buildActionItem(
      IconData icon, String title, String subtitle, VoidCallback onTap) {
    return InkWell(onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: velloOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: velloOrange, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: velloBlue)),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF6B7280))),
                  ]),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 16, color: Color(0xFF6B7280)),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: _logout,
        icon: const Icon(Icons.logout),
        label: const Text('Sair da Conta',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade600,
          foregroundColor: Colors.white,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  // ---------- Utils ----------
  BoxDecoration _boxStyle() {
    return BoxDecoration(
      color: velloCardBackground,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  String _formatarData(dynamic ts) {
    try {
      if (ts is Timestamp) {
        final d = ts.toDate();
        return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
      }
      if (ts is DateTime) {
        return '${ts.day.toString().padLeft(2, '0')}/${ts.month.toString().padLeft(2, '0')}/${ts.year}';
      }
      return '--/--/----';
    } catch (_) {
      return '--/--/----';
    }
  }

  // ---------- Ações ----------
  void _editarPerfil() {}
  void _editarVeiculo() {}
  void _alterarSenha() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
    );
  }
  void _configurarNotificacoes() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    );
  }
  void _abrirSuporte() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SupportScreen()),
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
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                );
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