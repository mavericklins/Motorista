import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InformacoesVeiculoScreen extends StatefulWidget {
  const InformacoesVeiculoScreen({super.key});

  @override
  State<InformacoesVeiculoScreen> createState() => _InformacoesVeiculoScreenState();
}

class _InformacoesVeiculoScreenState extends State<InformacoesVeiculoScreen> {
  // Cores da identidade visual Vello
  static const Color velloBlue = Color(0xFF1B3A57);
  static const Color velloOrange = Color(0xFFFF8C42);
  static const Color velloLightGray = Color(0xFFF8F9FA);
  static const Color velloCardBackground = Color(0xFFFFFFFF);

  final _formKey = GlobalKey<FormState>();
  final _marcaController = TextEditingController(text: 'Honda');
  final _modeloController = TextEditingController(text: 'Civic');
  final _anoController = TextEditingController(text: '2020');
  final _corController = TextEditingController(text: 'Prata');
  final _placaController = TextEditingController(text: 'ABC-1234');
  final _renavamController = TextEditingController(text: '12345678901');
  final _chassiController = TextEditingController(text: '9BWZZZ377VT004251');
  final _crlvController = TextEditingController(text: '123456789');

  bool _isLoading = false;
  bool _isEditing = false;
  String _tipoVeiculo = 'Sedan';
  String _combustivel = 'Flex';
  String _statusVeiculo = 'Ativo';

  final List<String> _tiposVeiculo = [
    'Sedan',
    'Hatch',
    'SUV',
    'Pickup',
    'Van',
    'Outro'
  ];

  final List<String> _tiposCombustivel = [
    'Flex',
    'Gasolina',
    'Etanol',
    'Diesel',
    'GNV',
    'Elétrico',
    'Híbrido'
  ];

  @override
  void dispose() {
    _marcaController.dispose();
    _modeloController.dispose();
    _anoController.dispose();
    _corController.dispose();
    _placaController.dispose();
    _renavamController.dispose();
    _chassiController.dispose();
    _crlvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: velloLightGray,
      appBar: AppBar(
        title: const Text(
          'Informações do Veículo',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: velloOrange,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => setState(() => _isEditing = !_isEditing),
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            tooltip: _isEditing ? 'Cancelar' : 'Editar',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Card de status do veículo
              _buildStatusCard(),
              
              const SizedBox(height: 20),
              
              // Card de informações básicas
              _buildBasicInfoCard(),
              
              const SizedBox(height: 20),
              
              // Card de documentação
              _buildDocumentationCard(),
              
              const SizedBox(height: 20),
              
              // Card de fotos do veículo
              _buildPhotosCard(),
              
              if (_isEditing) ...[
                const SizedBox(height: 32),
                _buildSaveButton(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    Color statusColor;
    IconData statusIcon;
    
    switch (_statusVeiculo) {
      case 'Ativo':
        statusColor = const Color(0xFF10B981);
        statusIcon = Icons.check_circle;
        break;
      case 'Pendente':
        statusColor = Colors.orange.shade600;
        statusIcon = Icons.schedule;
        break;
      default:
        statusColor = Colors.red.shade600;
        statusIcon = Icons.cancel;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [statusColor.withOpacity(0.1), statusColor.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              statusIcon,
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
                  'Status do Veículo',
                  style: TextStyle(
                    fontSize: 14,
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _statusVeiculo,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
                if (_statusVeiculo == 'Ativo')
                  const Text(
                    'Veículo aprovado para corridas',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: velloCardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Informações Básicas', Icons.directions_car),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _marcaController,
                  label: 'Marca',
                  icon: Icons.business,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Digite a marca';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _modeloController,
                  label: 'Modelo',
                  icon: Icons.car_rental,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Digite o modelo';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _anoController,
                  label: 'Ano',
                  icon: Icons.calendar_today,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Digite o ano';
                    }
                    final ano = int.tryParse(value);
                    if (ano == null || ano < 1990 || ano > DateTime.now().year + 1) {
                      return 'Ano inválido';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _corController,
                  label: 'Cor',
                  icon: Icons.palette,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Digite a cor';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildDropdownField(
                  value: _tipoVeiculo,
                  label: 'Tipo de Veículo',
                  icon: Icons.category,
                  items: _tiposVeiculo,
                  onChanged: (value) => setState(() => _tipoVeiculo = value!),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdownField(
                  value: _combustivel,
                  label: 'Combustível',
                  icon: Icons.local_gas_station,
                  items: _tiposCombustivel,
                  onChanged: (value) => setState(() => _combustivel = value!),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: velloCardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Documentação', Icons.description),
          const SizedBox(height: 16),
          
          _buildTextField(
            controller: _placaController,
            label: 'Placa',
            icon: Icons.confirmation_number,
            inputFormatters: [_PlacaInputFormatter()],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Digite a placa';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          _buildTextField(
            controller: _renavamController,
            label: 'RENAVAM',
            icon: Icons.assignment,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(11),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Digite o RENAVAM';
              }
              if (value.length != 11) {
                return 'RENAVAM deve ter 11 dígitos';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          _buildTextField(
            controller: _chassiController,
            label: 'Chassi',
            icon: Icons.vpn_key,
            inputFormatters: [
              LengthLimitingTextInputFormatter(17),
              FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Digite o chassi';
              }
              if (value.length != 17) {
                return 'Chassi deve ter 17 caracteres';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          _buildTextField(
            controller: _crlvController,
            label: 'CRLV (Número do Documento)',
            icon: Icons.credit_card,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Digite o número do CRLV';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: velloCardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Fotos do Veículo', Icons.photo_camera),
          const SizedBox(height: 16),
          
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _buildPhotoCard('Frente', Icons.camera_front),
              _buildPhotoCard('Traseira', Icons.camera_rear),
              _buildPhotoCard('Lateral Esquerda', Icons.camera_alt),
              _buildPhotoCard('Lateral Direita', Icons.camera_alt),
              _buildPhotoCard('Interior', Icons.airline_seat_recline_normal),
              _buildPhotoCard('Documento', Icons.description),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoCard(String label, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: velloLightGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _isEditing ? () => _adicionarFoto(label) : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: const Color(0xFF6B7280),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            if (_isEditing) ...[
              const SizedBox(height: 4),
              const Text(
                'Toque para adicionar',
                style: TextStyle(
                  fontSize: 10,
                  color: velloOrange,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
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
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: velloBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: velloBlue,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: _isEditing,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF6B7280)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: velloOrange, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            filled: true,
            fillColor: _isEditing ? Colors.white : const Color(0xFFF9FAFB),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String value,
    required String label,
    required IconData icon,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: velloBlue,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: _isEditing ? onChanged : null,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF6B7280)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: velloOrange, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            filled: true,
            fillColor: _isEditing ? Colors.white : const Color(0xFFF9FAFB),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _salvarInformacoes,
        style: ElevatedButton.styleFrom(
          backgroundColor: velloOrange,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Salvar Informações',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  void _adicionarFoto(String tipo) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Adicionar Foto - $tipo',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: velloBlue,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: velloOrange),
                title: const Text('Câmera'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Abrindo câmera para $tipo...')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: velloOrange),
                title: const Text('Galeria'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Abrindo galeria para $tipo...')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _salvarInformacoes() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    // Simular processamento
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
      _isEditing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Informações do veículo salvas com sucesso!'),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }
}

// Formatador para placa de veículo
class _PlacaInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    final buffer = StringBuffer();

    for (int i = 0; i < text.length && i < 7; i++) {
      if (i == 3) buffer.write('-');
      buffer.write(text[i]);
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

