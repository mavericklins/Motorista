import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class CorridaPopupWidget extends StatefulWidget {
  final String corridaId;
  final Map<String, dynamic> corridaData;
  final String notificacaoId;
  final VoidCallback onAceitar;
  final VoidCallback onRecusar;

  const CorridaPopupWidget({
    Key? key,
    required this.corridaId,
    required this.corridaData,
    required this.notificacaoId,
    required this.onAceitar,
    required this.onRecusar,
  }) : super(key: key);

  @override
  State<CorridaPopupWidget> createState() => _CorridaPopupWidgetState();
}

class _CorridaPopupWidgetState extends State<CorridaPopupWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;
  
  int _countdown = 30; // 30 segundos para responder
  late Timer _timer;

  // Cores Vello
  static const Color velloOrange = Color(0xFFFF6B35);
  static const Color velloBlue = Color(0xFF2E3A59);
  static const Color velloGreen = Color(0xFF10B981);

  @override
  void initState() {
    super.initState();
    
    // Animação de pulso
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);

    // Animação de entrada
    _slideController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));
    _slideController.forward();

    // Timer de countdown
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _countdown--;
          if (_countdown <= 0) {
            _timer.cancel();
            widget.onRecusar(); // Auto-recusar quando tempo acabar
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    _timer.cancel();
    super.dispose();
  }

  String _formatarDistancia(double? distancia) {
    if (distancia == null) return 'N/A';
    if (distancia < 1000) {
      return '${distancia.round()}m';
    } else {
      return '${(distancia / 1000).toStringAsFixed(1)}km';
    }
  }

  String _formatarTempo(double? distancia) {
    if (distancia == null) return 'N/A';
    // Estimativa: 30 km/h média na cidade
    final tempoMinutos = (distancia / 1000) / 30 * 60;
    if (tempoMinutos < 1) {
      return '< 1 min';
    } else {
      return '${tempoMinutos.round()} min';
    }
  }

  @override
  Widget build(BuildContext context) {
    final passageiro = widget.corridaData['passageiro'] as Map<String, dynamic>? ?? {};
    final origem = widget.corridaData['origem'] as Map<String, dynamic>? ?? {};
    final destino = widget.corridaData['destino'] as Map<String, dynamic>? ?? {};
    final valor = widget.corridaData['valor'] as String? ?? '0,00';
    final distancia = widget.corridaData['distancia'] as double?;

    return Material(
      color: Colors.transparent,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          margin: EdgeInsets.all(20),
          child: Center(
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: double.infinity,
                    constraints: BoxConstraints(maxWidth: 400),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: velloOrange.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header com ícone e título
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [velloOrange, velloBlue],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.local_taxi,
                                  color: velloOrange,
                                  size: 30,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'NOVA CORRIDA!',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Responda em $_countdown segundos',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Countdown circular
                              Container(
                                width: 50,
                                height: 50,
                                child: Stack(
                                  children: [
                                    CircularProgressIndicator(
                                      value: _countdown / 30,
                                      backgroundColor: Colors.white30,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      strokeWidth: 4,
                                    ),
                                    Center(
                                      child: Text(
                                        '$_countdown',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Conteúdo da corrida
                        Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            children: [
                              // Informações do passageiro
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 25,
                                    backgroundColor: velloBlue.withOpacity(0.1),
                                    child: Icon(Icons.person, color: velloBlue, size: 30),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          passageiro['nome'] ?? 'Passageiro',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: velloBlue,
                                          ),
                                        ),
                                        if (passageiro['telefone'] != null && passageiro['telefone'].isNotEmpty)
                                          Text(
                                            passageiro['telefone'],
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  // Valor da corrida
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: velloGreen,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      'R\$ $valor',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 20),

                              // Origem e destino
                              Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
                                child: Column(
                                  children: [
                                    // Origem
                                    Row(
                                      children: [
                                        Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: velloGreen,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'ORIGEM',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Text(
                                                origem['endereco'] ?? 'Localização do passageiro',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: velloBlue,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                                    // Linha conectora
                                    Container(
                                      margin: EdgeInsets.symmetric(vertical: 8),
                                      child: Row(
                                        children: [
                                          SizedBox(width: 6),
                                          Container(
                                            width: 2,
                                            height: 20,
                                            color: Colors.grey[300],
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Destino
                                    Row(
                                      children: [
                                        Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: velloOrange,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'DESTINO',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Text(
                                                destino['endereco'] ?? 'Destino selecionado',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: velloBlue,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: 16),

                              // Informações adicionais
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildInfoCard(
                                    Icons.straighten,
                                    'Distância',
                                    _formatarDistancia(distancia),
                                  ),
                                  _buildInfoCard(
                                    Icons.access_time,
                                    'Tempo Est.',
                                    _formatarTempo(distancia),
                                  ),
                                  _buildInfoCard(
                                    Icons.payment,
                                    'Pagamento',
                                    widget.corridaData['metodoPagamento'] ?? 'N/A',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Botões de ação
                        Container(
                          padding: EdgeInsets.all(20),
                          child: Row(
                            children: [
                              // Botão Recusar
                              Expanded(
                                child: Container(
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: widget.onRecusar,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey[600],
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.close, size: 20),
                                        SizedBox(width: 8),
                                        Text(
                                          'RECUSAR',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(width: 16),

                              // Botão Aceitar
                              Expanded(
                                flex: 2,
                                child: Container(
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: widget.onAceitar,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: velloGreen,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.check, size: 20),
                                        SizedBox(width: 8),
                                        Text(
                                          'ACEITAR CORRIDA',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(icon, color: velloBlue, size: 20),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: velloBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}


