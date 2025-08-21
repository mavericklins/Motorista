import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/app_colors.dart';

/// Widget simples para compartilhamento de viagem via WhatsApp - Versão Motorista
class SimpleTripSharingMotoristaWidget extends StatefulWidget {
  final String tripId;
  final String? passageiroNome;
  final String? destino;
  final VoidCallback? onShared;

  const SimpleTripSharingMotoristaWidget({
    Key? key,
    required this.tripId,
    this.passageiroNome,
    this.destino,
    this.onShared,
  }) : super(key: key);

  @override
  _SimpleTripSharingMotoristaWidgetState createState() => _SimpleTripSharingMotoristaWidgetState();
}

class _SimpleTripSharingMotoristaWidgetState extends State<SimpleTripSharingMotoristaWidget> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final List<Map<String, String>> _contacts = [];
  bool _isLoading = false;

  // Cores da identidade Vello Motorista
  static const Color velloBlue = Color(0xFF1B3A57);
  static const Color velloOrange = VelloColors.laranja;
  static const Color velloLightGray = Color(0xFFF8F9FA);

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: velloOrange.withOpacity(0.1),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: velloOrange,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.security, color: Colors.white, size: 20),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Compartilhar Corrida',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: velloBlue,
                            ),
                          ),
                          Text(
                            'Notifique familiares sobre sua corrida ativa',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (widget.passageiroNome != null || widget.destino != null) ...[
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.passageiroNome != null)
                          Text(
                            'Passageiro: ${widget.passageiroNome}',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        if (widget.destino != null)
                          Text(
                            'Destino: ${widget.destino}',
                            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Formulário para adicionar contatos
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nome do contato',
                    prefixIcon: Icon(Icons.person, color: velloOrange),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: velloOrange),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Telefone (com DDD)',
                    prefixIcon: Icon(Icons.phone, color: velloOrange),
                    hintText: '11999999999',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: velloOrange),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _addContact,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: velloBlue,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Adicionar Contato', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),

          // Lista de contatos adicionados
          if (_contacts.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Contatos Selecionados (${_contacts.length}/3)',
                  style: TextStyle(fontWeight: FontWeight.w600, color: velloBlue),
                ),
              ),
            ),
            SizedBox(height: 8),
          ],

          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: _contacts.length,
              itemBuilder: (context, index) {
                final contact = _contacts[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: velloOrange,
                      child: Text(
                        contact['name']!.substring(0, 1).toUpperCase(),
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(contact['name']!),
                    subtitle: Text(contact['phone']!),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeContact(index),
                    ),
                  ),
                );
              },
            ),
          ),

          // Botões de ação
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Cancelar'),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _contacts.isEmpty || _isLoading ? null : _shareTrip,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: velloOrange,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Compartilhar (${_contacts.length})',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addContact() {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      _showErrorDialog('Preencha nome e telefone');
      return;
    }

    if (_contacts.length >= 3) {
      _showErrorDialog('Máximo 3 contatos permitidos');
      return;
    }

    setState(() {
      _contacts.add({'name': name, 'phone': phone});
      _nameController.clear();
      _phoneController.clear();
    });
  }

  void _removeContact(int index) {
    setState(() {
      _contacts.removeAt(index);
    });
  }

  Future<void> _shareTrip() async {
    setState(() => _isLoading = true);

    try {
      final trackingLink = 'https://vellomotoristaseguro.app/track/${widget.tripId}';
      
      for (final contact in _contacts) {
        final message = _buildShareMessage(contact['name']!, trackingLink);
        await _sendWhatsAppMessage(contact['phone']!, message);
        await Future.delayed(Duration(milliseconds: 500)); // Evitar spam
      }

      Navigator.pop(context);
      widget.onShared?.call();
      _showSuccessDialog();
    } catch (e) {
      _showErrorDialog('Erro ao compartilhar: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _buildShareMessage(String contactName, String trackingLink) {
    final now = DateTime.now();
    final time = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    String message = '''
🚗 *Vello Motorista - Compartilhamento de Corrida*

Olá $contactName! 
Estou realizando uma corrida como motorista Vello e compartilhei com você para sua segurança.

⏰ *Iniciado às:* $time
''';

    if (widget.passageiroNome != null) {
      message += '👤 *Passageiro:* ${widget.passageiroNome}\n';
    }
    
    if (widget.destino != null) {
      message += '📍 *Destino:* ${widget.destino}\n';
    }

    message += '''

📍 *Acompanhe em tempo real:*
$trackingLink

🛡️ *Recursos de Segurança:*
• Localização em tempo real
• Dados do veículo e motorista
• Rota completa da corrida
• Contato direto com central

_Mensagem automática do Vello Motorista_
_"Dirigindo com segurança e transparência."_
    ''';

    return message;
  }

  Future<void> _sendWhatsAppMessage(String phone, String message) async {
    try {
      String cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
      if (!cleanPhone.startsWith('55')) {
        cleanPhone = '55$cleanPhone';
      }

      final whatsappUrl = 'https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}';
      
      if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
        await launchUrl(Uri.parse(whatsappUrl), mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('Erro ao enviar WhatsApp: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text('Erro'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Sucesso!'),
          ],
        ),
        content: Text('Corrida compartilhada! Os contatos receberão mensagens no WhatsApp com informações de segurança.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: velloOrange)),
          ),
        ],
      ),
    );
  }
}

