import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ReportarProblemaScreen extends StatefulWidget {
  const ReportarProblemaScreen({super.key});

  @override
  State<ReportarProblemaScreen> createState() => _ReportarProblemaScreenState();
}

class _ReportarProblemaScreenState extends State<ReportarProblemaScreen> {
  // Cores da identidade visual Vello
  static const Color velloBlue = Color(0xFF1B3A57);
  static const Color velloOrange = Color(0xFFFF8C42);
  static const Color velloLightGray = Color(0xFFF8F9FA);
  static const Color velloCardBackground = Color(0xFFFFFFFF);

  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _passosController = TextEditingController();
  
  String _tipoProblema = 'Bug no App';
  String _severidade = 'Média';
  String _frequencia = 'Sempre';
  bool _isLoading = false;
  
  final List<String> _anexos = [];

  final List<String> _tiposProblema = [
    'Bug no App',
    'Problema de Performance',
    'Erro de Interface',
    'Problema de Conectividade',
    'Falha no GPS',
    'Problema com Pagamentos',
    'Erro nas Corridas',
    'Problema de Login',
    'Crash do Aplicativo',
    'Outro',
  ];

  final List<String> _severidades = [
    'Baixa',
    'Média',
    'Alta',
    'Crítica',
  ];

  final List<String> _frequencias = [
    'Sempre',
    'Frequentemente',
    'Às vezes',
    'Raramente',
    'Primeira vez',
  ];

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    _passosController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: velloLightGray,
      appBar: AppBar(
        title: const Text(
          'Reportar Problema',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: velloOrange,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Card de informações
              _buildInfoCard(),
              
              const SizedBox(height: 20),
              
              // Card do formulário
              _buildFormCard(),
              
              const SizedBox(height: 20),
              
              // Card de anexos
              _buildAnexosCard(),
              
              const SizedBox(height: 32),
              
              // Botão de enviar
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
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
        children: [
          Icon(
            Icons.bug_report,
            color: velloOrange,
            size: 32,
          ),
          const SizedBox(height: 12),
          const Text(
            'Reporte um Problema',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: velloBlue,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ajude-nos a melhorar o app reportando bugs e problemas técnicos. Sua contribuição é muito importante!',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
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
          const Text(
            'Detalhes do Problema',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: velloBlue,
            ),
          ),
          const SizedBox(height: 20),
          
          // Tipo de problema
          _buildDropdownField(
            label: 'Tipo de Problema',
            value: _tipoProblema,
            items: _tiposProblema,
            onChanged: (value) => setState(() => _tipoProblema = value!),
          ),
          
          const SizedBox(height: 16),
          
          // Severidade e Frequência
          Row(
            children: [
              Expanded(
                child: _buildDropdownField(
                  label: 'Severidade',
                  value: _severidade,
                  items: _severidades,
                  onChanged: (value) => setState(() => _severidade = value!),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdownField(
                  label: 'Frequência',
                  value: _frequencia,
                  items: _frequencias,
                  onChanged: (value) => setState(() => _frequencia = value!),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Título do problema
          _buildTextField(
            controller: _tituloController,
            label: 'Título do Problema',
            hint: 'Descreva brevemente o problema',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Digite um título para o problema';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // Descrição detalhada
          _buildTextField(
            controller: _descricaoController,
            label: 'Descrição Detalhada',
            hint: 'Descreva o problema em detalhes: o que aconteceu, quando aconteceu, qual era o resultado esperado...',
            maxLines: 5,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Digite uma descrição do problema';
              }
              if (value.length < 20) {
                return 'A descrição deve ter pelo menos 20 caracteres';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // Passos para reproduzir
          _buildTextField(
            controller: _passosController,
            label: 'Passos para Reproduzir (Opcional)',
            hint: '1. Abra o app\n2. Vá para a tela X\n3. Clique no botão Y\n4. O erro acontece...',
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildAnexosCard() {
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
          Row(
            children: [
              Icon(Icons.attach_file, color: velloOrange),
              const SizedBox(width: 8),
              const Text(
                'Anexos (Opcional)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: velloBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Adicione screenshots ou vídeos que ajudem a entender o problema',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 16),
          
          // Lista de anexos
          if (_anexos.isNotEmpty) ...[
            ...(_anexos.map((anexo) => _buildAnexoItem(anexo)).toList()),
            const SizedBox(height: 12),
          ],
          
          // Botões para adicionar anexos
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _adicionarScreenshot,
                  icon: const Icon(Icons.screenshot),
                  label: const Text('Screenshot'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: velloOrange,
                    side: const BorderSide(color: velloOrange),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _adicionarVideo,
                  icon: const Icon(Icons.videocam),
                  label: const Text('Vídeo'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: velloOrange,
                    side: const BorderSide(color: velloOrange),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnexoItem(String anexo) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: velloLightGray,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Icon(
            anexo.contains('video') ? Icons.videocam : Icons.image,
            color: velloOrange,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              anexo,
              style: const TextStyle(
                fontSize: 14,
                color: velloBlue,
              ),
            ),
          ),
          IconButton(
            onPressed: () => _removerAnexo(anexo),
            icon: const Icon(Icons.close, size: 18),
            color: Colors.red.shade600,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
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
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: velloOrange, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
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
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: velloOrange, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _enviarRelatorio,
        icon: _isLoading 
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.send),
        label: Text(_isLoading ? 'Enviando...' : 'Enviar Relatório'),
        style: ElevatedButton.styleFrom(
          backgroundColor: velloOrange,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  void _adicionarScreenshot() {
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
              const Text(
                'Adicionar Screenshot',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: velloBlue,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: velloOrange),
                title: const Text('Tirar foto agora'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _anexos.add('screenshot_${DateTime.now().millisecondsSinceEpoch}.jpg');
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Screenshot adicionado!')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: velloOrange),
                title: const Text('Escolher da galeria'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _anexos.add('imagem_galeria_${DateTime.now().millisecondsSinceEpoch}.jpg');
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Imagem adicionada!')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _adicionarVideo() {
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
              const Text(
                'Adicionar Vídeo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: velloBlue,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.videocam, color: velloOrange),
                title: const Text('Gravar vídeo'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _anexos.add('video_gravado_${DateTime.now().millisecondsSinceEpoch}.mp4');
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vídeo adicionado!')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.video_library, color: velloOrange),
                title: const Text('Escolher da galeria'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _anexos.add('video_galeria_${DateTime.now().millisecondsSinceEpoch}.mp4');
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vídeo adicionado!')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _removerAnexo(String anexo) {
    setState(() {
      _anexos.remove(anexo);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Anexo removido!')),
    );
  }

  void _enviarRelatorio() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Simular envio
    await Future.delayed(const Duration(seconds: 3));

    setState(() => _isLoading = false);

    if (mounted) {
      // Gerar número de protocolo
      final protocolo = 'VLO${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Color(0xFF10B981)),
              SizedBox(width: 8),
              Text('Relatório Enviado!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Seu relatório foi enviado com sucesso. Nossa equipe técnica irá analisar o problema.',
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: velloLightGray,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Número do Protocolo:',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    Text(
                      protocolo,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: velloBlue,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Guarde este número para acompanhar o status do seu relatório.',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: protocolo));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Protocolo copiado!')),
                );
              },
              child: const Text('Copiar Protocolo'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fechar dialog
                Navigator.of(context).pop(); // Voltar para configurações
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
              ),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}

