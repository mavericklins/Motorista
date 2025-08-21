import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class CorridaCompletaScreen extends StatefulWidget {
  final String corridaId;
  final Map<String, dynamic> corridaData;

  const CorridaCompletaScreen({
    super.key,
    required this.corridaId,
    required this.corridaData,
  });

  @override
  State<CorridaCompletaScreen> createState() => _CorridaCompletaScreenState();
}

class _CorridaCompletaScreenState extends State<CorridaCompletaScreen> {
  final MapController _mapController = MapController();
  Map<String, dynamic>? _corridaAtualizada;
  bool _isLoading = false;
  
  // Estados da corrida
  String _statusCorrida = 'indo_buscar'; // indo_buscar, aguardando_embarque, em_andamento

  // Cores Vello
  static const Color velloOrange = Color(0xFFFF6B35);
  static const Color velloBlue = Color(0xFF2E3A59);
  static const Color velloGreen = Color(0xFF10B981);

  @override
  void initState() {
    super.initState();
    _corridaAtualizada = widget.corridaData;
    _escutarAtualizacoesCorrida();
    
    // Verificar status inicial da corrida
    final status = widget.corridaData['statusDetalhado'] ?? 'indo_buscar';
    setState(() {
      _statusCorrida = status;
    });
  }

  void _escutarAtualizacoesCorrida() {
    FirebaseFirestore.instance
        .collection('corridas')
        .doc(widget.corridaId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && mounted) {
        final data = snapshot.data();
        setState(() {
          _corridaAtualizada = data;
          _statusCorrida = data?['statusDetalhado'] ?? 'indo_buscar';
        });
      }
    });
  }

  Future<void> _abrirGPS(String endereco) async {
    try {
      setState(() => _isLoading = true);

      // Tentar abrir Google Maps primeiro
      final googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(endereco)}';
      final googleMapsUri = Uri.parse(googleMapsUrl);

      if (await canLaunchUrl(googleMapsUri)) {
        await launchUrl(googleMapsUri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback para navegador
        await launchUrl(googleMapsUri, mode: LaunchMode.inAppWebView);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.navigation, color: Colors.white),
              SizedBox(width: 8),
              Text('GPS aberto para navegação'),
            ],
          ),
          backgroundColor: velloGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao abrir GPS: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _ligarPassageiro() async {
    final telefone = _corridaAtualizada?['telefonePassageiro'];
    if (telefone == null || telefone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Telefone do passageiro não disponível'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final telUri = Uri.parse('tel:$telefone');
      if (await canLaunchUrl(telUri)) {
        await launchUrl(telUri);
      } else {
        throw Exception('Não foi possível fazer a ligação');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao ligar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _chegouAoPontoEmbarque() async {
    try {
      setState(() => _isLoading = true);

      // Atualizar status da corrida
      await FirebaseFirestore.instance
          .collection('corridas')
          .doc(widget.corridaId)
          .update({
        'statusDetalhado': 'aguardando_embarque',
        'chegouEmbarqueEm': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.location_on, color: Colors.white),
              SizedBox(width: 8),
              Text('Chegada confirmada! Aguardando passageiro embarcar.'),
            ],
          ),
          backgroundColor: velloOrange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: Duration(seconds: 3),
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao confirmar chegada: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _iniciarCorrida() async {
    try {
      setState(() => _isLoading = true);

      // Atualizar status da corrida
      await FirebaseFirestore.instance
          .collection('corridas')
          .doc(widget.corridaId)
          .update({
        'statusDetalhado': 'em_andamento',
        'iniciadaEm': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.play_arrow, color: Colors.white),
              SizedBox(width: 8),
              Text('Corrida iniciada! Siga para o destino.'),
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
          content: Text('Erro ao iniciar corrida: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _finalizarCorrida() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: velloGreen),
            SizedBox(width: 8),
            Text('Finalizar Corrida'),
          ],
        ),
        content: Text('Confirma que chegou ao destino e a corrida foi concluída?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: velloGreen),
            child: Text('Finalizar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        setState(() => _isLoading = true);

        // Atualizar status da corrida
        await FirebaseFirestore.instance
            .collection('corridas')
            .doc(widget.corridaId)
            .update({
          'status': 'concluida',
          'statusDetalhado': 'concluida',
          'finalizadaEm': FieldValue.serverTimestamp(),
        });

        // Atualizar status do motorista
        await FirebaseFirestore.instance
            .collection('motoristas')
            .doc(_corridaAtualizada?['motoristaId'])
            .update({
          'status': 'online',
          'corridaAtual': null,
          'ultimaAtualizacao': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Corrida finalizada com sucesso!'),
              ],
            ),
            backgroundColor: velloGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );

        // Voltar para home
        Navigator.of(context).popUntil((route) => route.isFirst);

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao finalizar corrida: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getStatusText() {
    switch (_statusCorrida) {
      case 'indo_buscar':
        return 'Indo buscar passageiro';
      case 'aguardando_embarque':
        return 'Aguardando embarque';
      case 'em_andamento':
        return 'Corrida em andamento';
      default:
        return 'Em andamento';
    }
  }

  Color _getStatusColor() {
    switch (_statusCorrida) {
      case 'indo_buscar':
        return velloOrange;
      case 'aguardando_embarque':
        return Colors.amber;
      case 'em_andamento':
        return velloGreen;
      default:
        return velloGreen;
    }
  }

  IconData _getStatusIcon() {
    switch (_statusCorrida) {
      case 'indo_buscar':
        return Icons.directions_car;
      case 'aguardando_embarque':
        return Icons.person_add;
      case 'em_andamento':
        return Icons.navigation;
      default:
        return Icons.directions_car;
    }
  }

  Widget _buildActionButton() {
    switch (_statusCorrida) {
      case 'indo_buscar':
        return ElevatedButton(
          onPressed: _isLoading ? null : _chegouAoPontoEmbarque,
          style: ElevatedButton.styleFrom(
            backgroundColor: velloOrange,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 4,
          ),
          child: _isLoading
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    ),
                    SizedBox(width: 12),
                    Text('Confirmando...', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_on, size: 24),
                    SizedBox(width: 8),
                    Text('Cheguei ao ponto de embarque', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
        );

      case 'aguardando_embarque':
        return ElevatedButton(
          onPressed: _isLoading ? null : _iniciarCorrida,
          style: ElevatedButton.styleFrom(
            backgroundColor: velloGreen,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 4,
          ),
          child: _isLoading
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    ),
                    SizedBox(width: 12),
                    Text('Iniciando...', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_arrow, size: 24),
                    SizedBox(width: 8),
                    Text('Iniciar corrida', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
        );

      case 'em_andamento':
        return ElevatedButton(
          onPressed: _isLoading ? null : _finalizarCorrida,
          style: ElevatedButton.styleFrom(
            backgroundColor: velloGreen,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 4,
          ),
          child: _isLoading
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    ),
                    SizedBox(width: 12),
                    Text('Finalizando...', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, size: 24),
                    SizedBox(width: 8),
                    Text('Finalizar corrida', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
        );

      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_corridaAtualizada == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: velloOrange),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: velloOrange,
        title: Text(
          _getStatusText(),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16, top: 8, bottom: 8),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor(),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_getStatusIcon(), color: Colors.white, size: 16),
                SizedBox(width: 4),
                Text(
                  _getStatusText().toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Informações do Passageiro
          Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: velloBlue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.person, color: Colors.white, size: 24),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _corridaAtualizada!['nomePassageiro'] ?? 'Passageiro',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: velloBlue,
                            ),
                          ),
                          if (_corridaAtualizada!['telefonePassageiro'] != null)
                            Text(
                              _corridaAtualizada!['telefonePassageiro'],
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _ligarPassageiro,
                      icon: Icon(Icons.phone, size: 18),
                      label: Text('Ligar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: velloGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Endereços e Navegação
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Origem (sempre visível)
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: velloGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.my_location, color: velloGreen, size: 20),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Origem',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            _corridaAtualizada!['origem'] ?? 'Endereço de origem',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: velloBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Mostrar GPS para origem apenas se indo buscar
                    if (_statusCorrida == 'indo_buscar')
                      ElevatedButton.icon(
                        onPressed: _isLoading 
                            ? null 
                            : () => _abrirGPS(_corridaAtualizada!['origem'] ?? ''),
                        icon: _isLoading 
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(Icons.navigation, size: 18),
                        label: Text('GPS'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: velloOrange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                  ],
                ),
                
                SizedBox(height: 16),
                
                // Linha conectora
                Container(
                  margin: EdgeInsets.only(left: 20),
                  child: Row(
                    children: [
                      Container(
                        width: 2,
                        height: 20,
                        color: Colors.grey[300],
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 16),
                
                // Destino
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.location_on, color: Colors.red, size: 20),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Destino',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            _corridaAtualizada!['destino'] ?? 'Endereço de destino',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: velloBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Mostrar GPS para destino apenas se corrida em andamento
                    if (_statusCorrida == 'em_andamento')
                      ElevatedButton.icon(
                        onPressed: _isLoading 
                            ? null 
                            : () => _abrirGPS(_corridaAtualizada!['destino'] ?? ''),
                        icon: _isLoading 
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(Icons.navigation, size: 18),
                        label: Text('GPS'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: velloOrange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 16),

          // Valor da Corrida
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: velloGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: velloGreen.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: velloGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.attach_money, color: Colors.white, size: 24),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Valor da Corrida',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'R\$ ${_corridaAtualizada!['valor']?.toString() ?? '0,00'}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: velloGreen,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: velloGreen,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _corridaAtualizada!['metodoPagamento'] ?? 'Dinheiro',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Instruções baseadas no status
          Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getStatusColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _getStatusColor().withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(_getStatusIcon(), color: _getStatusColor(), size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _statusCorrida == 'indo_buscar'
                        ? 'Use o GPS para ir até o passageiro. Quando chegar, clique em "Cheguei ao ponto de embarque".'
                        : _statusCorrida == 'aguardando_embarque'
                            ? 'Aguarde o passageiro embarcar no veículo. Quando estiver pronto, clique em "Iniciar corrida".'
                            : 'Use o GPS para ir até o destino. Quando chegar, clique em "Finalizar corrida".',
                    style: TextStyle(
                      fontSize: 14,
                      color: _getStatusColor(),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Spacer(),

          // Botão de Ação Principal
          Container(
            margin: EdgeInsets.all(16),
            width: double.infinity,
            child: _buildActionButton(),
          ),
        ],
      ),
    );
  }
}

