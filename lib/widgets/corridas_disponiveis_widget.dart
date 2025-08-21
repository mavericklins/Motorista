import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import '../services/sound_service.dart';

class CorridasDisponiveisWidget extends StatelessWidget {
  final String motoristaId;

  const CorridasDisponiveisWidget({Key? key, required this.motoristaId}) : super(key: key);

  // Cores Vello
  static const Color velloOrange = Color(0xFFFF6B35);
  static const Color velloBlue = Color(0xFF2E3A59);
  static const Color velloGreen = Color(0xFF10B981);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('corridas')
          .where('status', isEqualTo: 'pendente')
          .where('disponivel', isEqualTo: true)
          .where('tempoLimite', isGreaterThan: Timestamp.now())
          .orderBy('tempoLimite')
          .orderBy('prioridade')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(velloOrange),
            ),
          );
        }

        final corridas = snapshot.data!.docs;

        if (corridas.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.local_taxi, size: 64, color: Colors.grey[400]),
                SizedBox(height: 16),
                Text(
                  'Nenhuma corrida disponível',
                  style: TextStyle(
                    fontSize: 18, 
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Aguarde novas solicitações',
                  style: TextStyle(
                    fontSize: 14, 
                    color: Colors.grey[500],
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: velloOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: velloOrange.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.info_outline, color: velloOrange, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Mantenha-se online para receber corridas',
                        style: TextStyle(
                          color: velloOrange,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: corridas.length,
          itemBuilder: (context, index) {
            final corrida = corridas[index].data() as Map<String, dynamic>;
            final corridaId = corridas[index].id;
            
            return CorridaCard(
              corridaId: corridaId,
              corrida: corrida,
              motoristaId: motoristaId,
            );
          },
        );
      },
    );
  }
}

class CorridaCard extends StatefulWidget {
  final String corridaId;
  final Map<String, dynamic> corrida;
  final String motoristaId;

  const CorridaCard({
    Key? key,
    required this.corridaId,
    required this.corrida,
    required this.motoristaId,
  }) : super(key: key);

  @override
  State<CorridaCard> createState() => _CorridaCardState();
}

class _CorridaCardState extends State<CorridaCard> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isProcessing = false;

  // Cores Vello
  static const Color velloOrange = Color(0xFFFF6B35);
  static const Color velloBlue = Color(0xFF2E3A59);
  static const Color velloGreen = Color(0xFF10B981);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final passageiro = widget.corrida['passageiro'] ?? {};
    final origem = widget.corrida['origem'] ?? {};
    final destino = widget.corrida['destino'] ?? {};
    final valor = widget.corrida['valor'] ?? '0,00';
    final metodoPagamento = widget.corrida['metodoPagamento'] ?? 'dinheiro';
    final localizacao = widget.corrida['localizacao'];

    // Calcular distância se tiver localização
    String distanciaTexto = '';
    if (localizacao != null) {
      // Aqui você pode calcular a distância real do motorista até o passageiro
      distanciaTexto = '2.3 km'; // Placeholder
    }

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: EdgeInsets.only(bottom: 16),
            child: Card(
              elevation: 8,
              shadowColor: velloBlue.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      Colors.grey[50]!,
                    ],
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cabeçalho com passageiro e valor
                      Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [velloOrange, velloOrange.withOpacity(0.8)],
                              ),
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: velloOrange.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  passageiro['nome'] ?? 'Passageiro',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: velloBlue,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _getPaymentColor(metodoPagamento).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _getPaymentColor(metodoPagamento).withOpacity(0.3),
                                    ),
                                  ),
                                  child: Text(
                                    metodoPagamento.toUpperCase(),
                                    style: TextStyle(
                                      color: _getPaymentColor(metodoPagamento),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [velloGreen, velloGreen.withOpacity(0.8)],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: velloGreen.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Text(
                              'R\$ $valor',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 20),

                      // Origem e Destino
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Column(
                          children: [
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
                                  child: Text(
                                    origem['endereco'] ?? 'Origem não informada',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: velloBlue,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Container(
                              margin: EdgeInsets.only(left: 6),
                              width: 1,
                              height: 20,
                              color: Colors.grey[300],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    destino['endereco'] ?? 'Destino não informado',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: velloBlue,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      if (distanciaTexto.isNotEmpty) ...[
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.straighten, size: 16, color: Colors.grey[600]),
                            SizedBox(width: 8),
                            Text(
                              'Distância: $distanciaTexto',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],

                      SizedBox(height: 20),

                      // Botões de ação
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isProcessing ? null : () => _recusarCorrida(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[400],
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 2,
                              ),
                              child: Text(
                                'Recusar',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: _isProcessing ? null : () => _aceitarCorrida(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: velloGreen,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 4,
                                shadowColor: velloGreen.withOpacity(0.3),
                              ),
                              child: _isProcessing
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : Text(
                                      'Aceitar Corrida',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getPaymentColor(String metodo) {
    switch (metodo.toLowerCase()) {
      case 'dinheiro':
        return velloGreen;
      case 'cartao':
      case 'credito':
      case 'debito':
        return velloBlue;
      default:
        return velloOrange;
    }
  }

  Future<void> _aceitarCorrida() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Som de aceitação
      await SoundService.playNewRideSound();

      // Atualizar corrida no Firebase
      await FirebaseFirestore.instance
          .collection('corridas')
          .doc(widget.corridaId)
          .update({
        'status': 'aceita',
        'motoristaId': widget.motoristaId,
        'aceitaEm': FieldValue.serverTimestamp(),
        'disponivel': false,
      });

      // Atualizar status do motorista
      await FirebaseFirestore.instance
          .collection('motoristas')
          .doc(widget.motoristaId)
          .update({
        'status': 'ocupado',
        'corridaAtual': widget.corridaId,
        'disponivel': false,
      });

      // Feedback visual
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Corrida aceita! Dirija-se ao passageiro.',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: velloGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: Duration(seconds: 3),
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao aceitar corrida: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _recusarCorrida() async {
    await SoundService.playOfflineSound();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.cancel, color: Colors.white),
            SizedBox(width: 12),
            Text(
              'Corrida recusada',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        backgroundColor: Colors.grey[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

