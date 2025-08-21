import 'package:flutter/material.dart';

class DinheiroScreen extends StatefulWidget {
  final double valorCorrida;

  const DinheiroScreen({Key? key, required this.valorCorrida}) : super(key: key);

  @override
  _DinheiroScreenState createState() => _DinheiroScreenState();
}

class _DinheiroScreenState extends State<DinheiroScreen> {
  bool _confirmado = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pagamento - Dinheiro'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 40),
            
            // Ícone de dinheiro
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.green, width: 3),
              ),
              child: Icon(
                Icons.attach_money,
                size: 64,
                color: Colors.green,
              ),
            ),
            
            SizedBox(height: 32),
            
            Text(
              'Pagamento em Dinheiro',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: 16),
            
            // Valor da corrida
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                children: [
                  Text(
                    'Valor da Corrida',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'R\$ ${widget.valorCorrida.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 32),
            
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue,
                    size: 32,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Instruções para Pagamento',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Tenha o valor exato da corrida\n'
                    '• Pague diretamente ao motorista\n'
                    '• Solicite o recibo se necessário\n'
                    '• Confirme o pagamento após a corrida',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue.shade600,
                    ),
                  ),
                ],
              ),
            ),
            
            Spacer(),
            
            // Checkbox de confirmação
            Row(
              children: [
                Checkbox(
                  value: _confirmado,
                  onChanged: (value) {
                    setState(() {
                      _confirmado = value ?? false;
                    });
                  },
                  activeColor: Colors.green,
                ),
                Expanded(
                  child: Text(
                    'Confirmo que tenho o valor exato da corrida em dinheiro',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16),
            
            // Botão de confirmação
            Container(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _confirmado ? _confirmarPagamento : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Confirmar Pagamento em Dinheiro',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmarPagamento() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 12),
            Text('Confirmado!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Pagamento em dinheiro confirmado.'),
            SizedBox(height: 16),
            Text(
              'Valor: R\$ ${widget.valorCorrida.toStringAsFixed(2)}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Pague diretamente ao motorista no final da corrida.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Fechar dialog
              Navigator.of(context).pop(true); // Voltar com sucesso
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

