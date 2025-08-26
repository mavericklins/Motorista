import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const Color velloOrange = Color(0xFFFF8C42);
  static const Color velloLightGray = Color(0xFFF8F9FA);

  late final String? _uid;
  late final DocumentReference<Map<String, dynamic>> _doc;

  bool _loadingWrite = false;

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser?.uid;
    _doc = FirebaseFirestore.instance
        .collection('motoristas')
        .doc(_uid)
        .collection('preferencias')
        .doc('notificacoes');
  }

  Future<void> _primeIfMissing() async {
    final snap = await _doc.get();
    if (!snap.exists) {
      await _doc.set({
        'push': true,
        'corridas': true,
        'marketing': false,
        'atualizadoEm': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  Future<void> _set(String key, bool val) async {
    try {
      setState(() => _loadingWrite = true);
      await _doc.set({
        key: val,
        'atualizadoEm': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Falha ao salvar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingWrite = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_uid == null) {
      return const Scaffold(
        body: Center(child: Text('Usuário não autenticado.')),
      );
    }

    return Scaffold(
      backgroundColor: velloLightGray,
      appBar: AppBar(
        title: const Text('Notificações'),
        backgroundColor: velloOrange,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder(
        future: _primeIfMissing(),
        builder: (context, _) {
          return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: _doc.snapshots(),
            builder: (context, snap) {
              final data = snap.data?.data() ?? {};
              bool push = (data['push'] ?? true) as bool;
              bool corridas = (data['corridas'] ?? true) as bool;
              bool marketing = (data['marketing'] ?? false) as bool;

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _tile(
                    title: 'Notificações push',
                    subtitle: 'Permitir push do app',
                    value: push,
                    onChanged: (v) => _set('push', v),
                  ),
                  const Divider(),
                  _tile(
                    title: 'Atualizações de corridas',
                    subtitle: 'Aceitas, canceladas e em andamento',
                    value: corridas,
                    onChanged: (v) => _set('corridas', v),
                  ),
                  const Divider(),
                  _tile(
                    title: 'Ofertas e novidades',
                    subtitle: 'Comunicados e campanhas',
                    value: marketing,
                    onChanged: (v) => _set('marketing', v),
                  ),
                  if (_loadingWrite) ...[
                    const SizedBox(height: 8),
                    const Center(child: CircularProgressIndicator()),
                  ]
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _tile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: Switch.adaptive(
        value: value,
        onChanged: (v) => onChanged(v),
        activeColor: velloOrange,
      ),
      onTap: () => onChanged(!value), // toque na linha também alterna
    );
  }
}
