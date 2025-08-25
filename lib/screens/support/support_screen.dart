import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Não foi possível abrir $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Suporte"),
        backgroundColor: Colors.orange,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.help_outline, color: Colors.orange),
            title: const Text("FAQ"),
            subtitle: const Text("Perguntas frequentes"),
            trailing: const Icon(Icons.open_in_new),
            onTap: () {
              _launchUrl("https://www.vellomobilidade.com.br/faq");
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.chat, color: Colors.green), // ✅ corrigido
            title: const Text("WhatsApp"),
            subtitle: const Text("Fale com nosso suporte"),
            trailing: const Icon(Icons.open_in_new),
            onTap: () {
              _launchUrl("https://wa.me/14960000471");
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.email, color: Colors.orange),
            title: const Text("E-mail"),
            subtitle: const Text("suporte@vellomobilidade.com.br"),
            trailing: const Icon(Icons.open_in_new),
            onTap: () {
              _launchUrl("mailto:suporte@vellomobilidade.com.br");
            },
          ),
        ],
      ),
    );
  }
}
