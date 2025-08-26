
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/economia_combustivel_service.dart';

class EconomiaCombustivelWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<EconomiaCombustivelService>(
      builder: (context, economiaService, child) {
        if (!economiaService.monitorandoViagem || economiaService.dicasEconomia.isEmpty) {
          return SizedBox.shrink();
        }

        final dicaAtual = economiaService.dicasEconomia.first;

        return Positioned(
          top: 100,
          left: 16,
          right: 16,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            child: Card(
              elevation: 8,
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    colors: [
                      _getCorPrioridade(dicaAtual['prioridade']).withOpacity(0.1),
                      Colors.white,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getCorPrioridade(dicaAtual['prioridade']),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dicaAtual['titulo'] ?? '',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            dicaAtual['descricao'] ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, size: 16),
                      onPressed: () {
                        // Remove a dica atual
                        economiaService.dicasEconomia.removeAt(0);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getCorPrioridade(String? prioridade) {
    switch (prioridade) {
      case 'alta':
        return Colors.red;
      case 'media':
        return Colors.orange;
      case 'baixa':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
