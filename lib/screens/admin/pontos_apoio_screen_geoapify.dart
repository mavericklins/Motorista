import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/app_colors.dart';
import '../../services/support_points_service_geoapify.dart';

class PontosApoioScreenGeoapify extends StatefulWidget {
  const PontosApoioScreenGeoapify({Key? key}) : super(key: key);

  @override
  State<PontosApoioScreenGeoapify> createState() => _PontosApoioScreenGeoapifyState();
}

class _PontosApoioScreenGeoapifyState extends State<PontosApoioScreenGeoapify> {
  final MapController _mapController = MapController();
  List<SupportPoint> _pontosApoio = [];
  Position? _posicaoAtual;
  bool _loading = true;
  String _filtroSelecionado = 'todos';

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() => _loading = true);
    
    try {
      // Obter posição atual
      _posicaoAtual = await Geolocator.getCurrentPosition();
      
      // Carregar pontos de apoio usando Geoapify
      _pontosApoio = await SupportPointsServiceGeoapify.obterPontosApoio(
        latitude: _posicaoAtual?.latitude,
        longitude: _posicaoAtual?.longitude,
        raioKm: 50.0,
      );
      
      setState(() => _loading = false);
    } catch (e) {
      print('Erro ao carregar dados: $e');
      setState(() => _loading = false);
    }
  }

  List<SupportPoint> get _pontosFiltrados {
    if (_filtroSelecionado == 'todos') return _pontosApoio;
    return _pontosApoio.where((ponto) => ponto.tipo == _filtroSelecionado).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VelloColors.creme,
      appBar: AppBar(
        title: const Text(
          'Pontos de Apoio',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: VelloColors.laranja,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregarDados,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildFiltros(),
                Expanded(
                  child: _buildMapa(),
                ),
                _buildListaPontos(),
              ],
            ),
    );
  }

  Widget _buildFiltros() {
    final tipos = SupportPointsServiceGeoapify.obterTiposPontos();
    
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tipos.length,
        itemBuilder: (context, index) {
          final tipo = tipos[index];
          final selecionado = _filtroSelecionado == tipo['id'];
          
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              label: Text(tipo['nome']),
              selected: selecionado,
              onSelected: (selected) {
                setState(() {
                  _filtroSelecionado = tipo['id'];
                });
              },
              selectedColor: VelloColors.laranja.withOpacity(0.3),
              checkmarkColor: VelloColors.laranja,
            ),
          );
        },
      ),
    );
  }

  Widget _buildMapa() {
    return Container(
      height: 300,
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          center: _posicaoAtual != null
              ? LatLng(_posicaoAtual!.latitude, _posicaoAtual!.longitude)
              : LatLng(-23.5505, -46.6333), // São Paulo como padrão
          zoom: 13.0,
        ),
        children: [
          // Usando Geoapify tiles (mesma API que você já usa)
          TileLayer(
            urlTemplate: 'https://maps.geoapify.com/v1/tile/osm-bright/{z}/{x}/{y}.png?apiKey=203ba4a0a4304d349299a8aa22e1dcae',
            userAgentPackageName: 'com.vello.motorista', // CORRIGIDO: Warning do flutter_map
          ),
          MarkerLayer(
            markers: [
              // Marcador da posição atual
              if (_posicaoAtual != null)
                Marker(
                  point: LatLng(_posicaoAtual!.latitude, _posicaoAtual!.longitude),
                  builder: (context) => Container(
                    decoration: BoxDecoration(
                      color: VelloColors.azul,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: const Icon(
                      Icons.my_location,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              // Marcadores dos pontos de apoio
              ..._pontosFiltrados.map((ponto) => Marker(
                point: LatLng(ponto.latitude, ponto.longitude),
                builder: (context) => GestureDetector(
                  onTap: () => _mostrarDetalhesPonto(ponto),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _getCorTipo(ponto.tipo),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(
                      _getIconeTipo(ponto.tipo),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              )).toList(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildListaPontos() {
    return Container(
      height: 200,
      child: ListView.builder(
        itemCount: _pontosFiltrados.length,
        itemBuilder: (context, index) {
          final ponto = _pontosFiltrados[index];
          return _buildCardPonto(ponto);
        },
      ),
    );
  }

  Widget _buildCardPonto(SupportPoint ponto) {
    final distancia = _posicaoAtual != null
        ? Geolocator.distanceBetween(
            _posicaoAtual!.latitude,
            _posicaoAtual!.longitude,
            ponto.latitude,
            ponto.longitude,
          ) / 1000
        : 0.0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getCorTipo(ponto.tipo),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getIconeTipo(ponto.tipo),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          ponto.nome,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(ponto.endereco),
            if (distancia > 0)
              Text(
                '${distancia.toStringAsFixed(1)} km',
                style: TextStyle(
                  color: VelloColors.azul,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (ponto.telefone.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.phone, color: VelloColors.laranja),
                onPressed: () => _ligarPonto(ponto.telefone),
              ),
            IconButton(
              icon: const Icon(Icons.navigation, color: VelloColors.azul),
              onPressed: () => _navegarPonto(ponto),
            ),
          ],
        ),
        onTap: () => _mostrarDetalhesPonto(ponto),
      ),
    );
  }

  void _mostrarDetalhesPonto(SupportPoint ponto) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle do modal
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Cabeçalho
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _getCorTipo(ponto.tipo),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getIconeTipo(ponto.tipo),
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ponto.nome,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _getNomeTipo(ponto.tipo),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Informações
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    _buildInfoItem(Icons.location_on, 'Endereço', ponto.endereco),
                    if (ponto.telefone.isNotEmpty)
                      _buildInfoItem(Icons.phone, 'Telefone', ponto.telefone),
                    _buildInfoItem(Icons.access_time, 'Horário', ponto.horarioFuncionamento),
                    if (ponto.servicos.isNotEmpty)
                      _buildInfoItem(Icons.build, 'Serviços', ponto.servicos.join(', ')),
                    if (ponto.avaliacao != null)
                      _buildInfoItem(Icons.star, 'Avaliação', '${ponto.avaliacao}/5.0'),
                  ],
                ),
              ),
              
              // Botões de ação
              Row(
                children: [
                  if (ponto.telefone.isNotEmpty)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _ligarPonto(ponto.telefone),
                        icon: const Icon(Icons.phone),
                        label: const Text('Ligar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: VelloColors.laranja,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  if (ponto.telefone.isNotEmpty) const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _navegarPonto(ponto),
                      icon: const Icon(Icons.navigation),
                      label: const Text('Navegar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: VelloColors.azul,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icone, String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, color: VelloColors.azul, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  valor,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getCorTipo(String tipo) {
    switch (tipo) {
      case 'combustivel':
        return Colors.red;
      case 'mecanica':
        return Colors.orange;
      case 'alimentacao':
        return Colors.green;
      case 'descanso':
        return Colors.purple;
      case 'saude':
        return Colors.pink;
      case 'banco':
        return Colors.indigo;
      default:
        return VelloColors.azul;
    }
  }

  IconData _getIconeTipo(String tipo) {
    switch (tipo) {
      case 'combustivel':
        return Icons.local_gas_station;
      case 'mecanica':
        return Icons.build;
      case 'alimentacao':
        return Icons.restaurant;
      case 'descanso':
        return Icons.hotel;
      case 'saude':
        return Icons.local_hospital;
      case 'banco':
        return Icons.account_balance;
      default:
        return Icons.location_on;
    }
  }

  String _getNomeTipo(String tipo) {
    switch (tipo) {
      case 'combustivel':
        return 'Posto de Combustível';
      case 'mecanica':
        return 'Oficina Mecânica';
      case 'alimentacao':
        return 'Restaurante';
      case 'descanso':
        return 'Hotel/Pousada';
      case 'saude':
        return 'Saúde';
      case 'banco':
        return 'Banco/ATM';
      default:
        return 'Ponto de Apoio';
    }
  }

  Future<void> _ligarPonto(String telefone) async {
    final url = 'tel:$telefone';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  Future<void> _navegarPonto(SupportPoint ponto) async {
    // Usar OpenStreetMap para navegação (compatível com Geoapify)
    final url = 'https://www.openstreetmap.org/directions?'
        'to=${ponto.latitude},${ponto.longitude}';
    
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      // Fallback para app de mapas do sistema
      final mapsUrl = 'geo:${ponto.latitude},${ponto.longitude}?q=${ponto.latitude},${ponto.longitude}(${ponto.nome})';
      if (await canLaunchUrl(Uri.parse(mapsUrl))) {
        await launchUrl(Uri.parse(mapsUrl));
      }
    }
  }
}

// Classe SupportPoint (mantendo compatibilidade)
class SupportPoint {
  final String id;
  final String nome;
  final String tipo;
  final String endereco;
  final double latitude;
  final double longitude;
  final String telefone;
  final bool aberto24h;
  final String horarioFuncionamento;
  final List<String> servicos;
  final double? avaliacao;
  final String? fonte; // 'firebase' ou 'geoapify'

  SupportPoint({
    required this.id,
    required this.nome,
    required this.tipo,
    required this.endereco,
    required this.latitude,
    required this.longitude,
    required this.telefone,
    required this.aberto24h,
    required this.horarioFuncionamento,
    required this.servicos,
    this.avaliacao,
    this.fonte = 'firebase',
  });
}