import 'package:flutter/material.dart';
import '../gamification/goals_screen.dart';
import '../../constants/app_colors.dart'; // Assuming VelloColors is within app_colors.dart

class CarteiraDigitalScreen extends StatefulWidget {
  const CarteiraDigitalScreen({super.key});

  @override
  _CarteiraDigitalScreenState createState() => _CarteiraDigitalScreenState();
}

class _CarteiraDigitalScreenState extends State<CarteiraDigitalScreen> {
  // Dados simulados da carteira
  double currentBalance = 245.80;
  double todayEarnings = 85.30;
  double weekEarnings = 420.50;
  int todayRides = 12;
  double get averagePerRide => todayRides > 0 ? todayEarnings / todayRides : 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VelloColors.creme, // Changed from AppColors.background
      appBar: AppBar(
        title: const Text('Carteira Digital'),
        backgroundColor: VelloColors.laranja, // Changed from AppColors.primary
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => _showTransactionHistory(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
          // Saldo principal
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [VelloColors.laranja, VelloColors.laranjaClaro], // Changed from AppColors.primary, AppColors.secondary
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: VelloColors.laranja.withOpacity(0.3), // Changed from AppColors.primary
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Saldo Disponível',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'R\$ ${currentBalance.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                      const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildQuickAction(
                        icon: Icons.add_circle,
                        label: 'Depositar',
                        onTap: () => _showDepositDialog(context),
                      ),
                      _buildQuickAction(
                        icon: Icons.flag,
                        label: 'Metas',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const GoalsScreen(),
                            ),
                          );
                        },
                      ),
                      _buildQuickAction(
                        icon: Icons.remove_circle,
                        label: 'Sacar',
                        onTap: () => _showWithdrawDialog(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Cards de informações rápidas
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    title: 'Ganhos Hoje',
                    value: 'R\$ ${todayEarnings.toStringAsFixed(2)}',
                    icon: Icons.today,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoCard(
                    title: 'Ganhos Semana',
                    value: 'R\$ ${weekEarnings.toStringAsFixed(2)}',
                    icon: Icons.date_range,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    title: 'Corridas Hoje',
                    value: '$todayRides',
                    icon: Icons.directions_car,
                    color: VelloColors.laranja, // Changed from AppColors.primary
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoCard(
                    title: 'Média/Corrida',
                    value: 'R\$ ${averagePerRide.toStringAsFixed(2)}',
                    icon: Icons.analytics,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
                const SizedBox(height: 24),

            // PIX e Transferências
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PIX e Transferências',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: VelloColors.laranja, // Changed from AppColors.primary
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: Icon(Icons.qr_code, color: VelloColors.laranja), // Changed from AppColors.primary
                    title: const Text('Receber via PIX'),
                    subtitle: const Text('Gere um código QR para receber'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _showPixReceiveDialog(context),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.send, color: Colors.green),
                    title: const Text('Enviar PIX'),
                    subtitle: const Text('Transferir para outra conta'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _showPixSendDialog(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showDepositDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Depositar'),
        content: const Text('Funcionalidade em desenvolvimento'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showWithdrawDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sacar'),
        content: const Text('Funcionalidade em desenvolvimento'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPixReceiveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Receber PIX'),
        content: const Text('Funcionalidade em desenvolvimento'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPixSendDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enviar PIX'),
        content: const Text('Funcionalidade em desenvolvimento'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showTransactionHistory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Histórico de Transações'),
            backgroundColor: VelloColors.laranja, // Changed from AppColors.primary
            foregroundColor: Colors.white,
          ),
          body: const Center(
            child: Text('Histórico em desenvolvimento'),
          ),
        ),
      ),
    );
  }
}