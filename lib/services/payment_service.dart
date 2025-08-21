import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

/// Serviço de pagamentos integrado para o mercado brasileiro
class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // URLs dos gateways (configurar com suas credenciais)
  static const String _mercadoPagoBaseUrl = 'https://api.mercadopago.com';
  static const String _pagSeguroBaseUrl = 'https://ws.riodoce.pagseguro.uol.com.br';
  
  // Chaves de API (devem ser configuradas via environment ou Firebase Remote Config)
  String? _mercadoPagoAccessToken;
  String? _pagSeguroToken;
  
  /// Inicializa o serviço com as credenciais
  Future<void> initialize() async {
    try {
      // Busca credenciais do Firebase Remote Config ou Firestore
      final configDoc = await _firestore.collection('config').doc('payment').get();
      if (configDoc.exists) {
        final data = configDoc.data()!;
        _mercadoPagoAccessToken = data['mercadoPagoToken'];
        _pagSeguroToken = data['pagSeguroToken'];
      }
    } catch (e) {
      print('Erro ao inicializar serviço de pagamento: $e');
    }
  }

  /// Processa pagamento PIX via Mercado Pago
  Future<PaymentResult> processPixPayment({
    required double amount,
    required String description,
    required String payerEmail,
    required String payerName,
    required String payerDocument,
    required String rideId,
  }) async {
    try {
      if (_mercadoPagoAccessToken == null) {
        return PaymentResult.error('Token do Mercado Pago não configurado');
      }

      final paymentData = {
        'transaction_amount': amount,
        'description': description,
        'payment_method_id': 'pix',
        'payer': {
          'email': payerEmail,
          'first_name': payerName,
          'last_name': '',
          'identification': {
            'type': 'CPF',
            'number': payerDocument,
          },
        },
        'external_reference': rideId,
        'notification_url': 'https://vellomobilidade.com.br/webhook/mercadopago',
      };

      final response = await http.post(
        Uri.parse('$_mercadoPagoBaseUrl/v1/payments'),
        headers: {
          'Authorization': 'Bearer $_mercadoPagoAccessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode(paymentData),
      );

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        
        // Salva transação no Firestore
        await _saveTransaction({
          'id': responseData['id'].toString(),
          'rideId': rideId,
          'amount': amount,
          'method': 'pix',
          'status': responseData['status'],
          'gateway': 'mercadopago',
          'qrCode': responseData['point_of_interaction']['transaction_data']['qr_code'],
          'qrCodeBase64': responseData['point_of_interaction']['transaction_data']['qr_code_base64'],
          'createdAt': FieldValue.serverTimestamp(),
        });

        return PaymentResult.success(
          transactionId: responseData['id'].toString(),
          qrCode: responseData['point_of_interaction']['transaction_data']['qr_code'],
          qrCodeBase64: responseData['point_of_interaction']['transaction_data']['qr_code_base64'],
        );
      } else {
        final errorData = json.decode(response.body);
        return PaymentResult.error('Erro no pagamento: ${errorData['message']}');
      }
    } catch (e) {
      return PaymentResult.error('Erro ao processar pagamento PIX: $e');
    }
  }

  /// Processa pagamento com cartão via Mercado Pago
  Future<PaymentResult> processCardPayment({
    required double amount,
    required String description,
    required String payerEmail,
    required String payerName,
    required String payerDocument,
    required String cardToken,
    required int installments,
    required String rideId,
  }) async {
    try {
      if (_mercadoPagoAccessToken == null) {
        return PaymentResult.error('Token do Mercado Pago não configurado');
      }

      final paymentData = {
        'transaction_amount': amount,
        'token': cardToken,
        'description': description,
        'installments': installments,
        'payment_method_id': 'visa', // Detectar automaticamente
        'issuer_id': 310,
        'payer': {
          'email': payerEmail,
          'identification': {
            'type': 'CPF',
            'number': payerDocument,
          },
        },
        'external_reference': rideId,
        'notification_url': 'https://vellomobilidade.com.br/webhook/mercadopago',
      };

      final response = await http.post(
        Uri.parse('$_mercadoPagoBaseUrl/v1/payments'),
        headers: {
          'Authorization': 'Bearer $_mercadoPagoAccessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode(paymentData),
      );

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        
        await _saveTransaction({
          'id': responseData['id'].toString(),
          'rideId': rideId,
          'amount': amount,
          'method': 'card',
          'status': responseData['status'],
          'gateway': 'mercadopago',
          'installments': installments,
          'createdAt': FieldValue.serverTimestamp(),
        });

        return PaymentResult.success(
          transactionId: responseData['id'].toString(),
          status: responseData['status'],
        );
      } else {
        final errorData = json.decode(response.body);
        return PaymentResult.error('Erro no pagamento: ${errorData['message']}');
      }
    } catch (e) {
      return PaymentResult.error('Erro ao processar pagamento com cartão: $e');
    }
  }

  /// Processa pagamento via PagSeguro
  Future<PaymentResult> processPagSeguroPayment({
    required double amount,
    required String description,
    required String payerEmail,
    required String payerName,
    required String payerDocument,
    required String paymentMethod,
    required String rideId,
  }) async {
    try {
      if (_pagSeguroToken == null) {
        return PaymentResult.error('Token do PagSeguro não configurado');
      }

      // Implementação do PagSeguro
      // Nota: PagSeguro tem API mais complexa, esta é uma versão simplificada
      final paymentData = {
        'email': 'contato@vellomobilidade.com.br',
        'token': _pagSeguroToken,
        'currency': 'BRL',
        'itemId1': '1',
        'itemDescription1': description,
        'itemAmount1': amount.toStringAsFixed(2),
        'itemQuantity1': '1',
        'senderName': payerName,
        'senderEmail': payerEmail,
        'senderCPF': payerDocument,
        'reference': rideId,
        'notificationURL': 'https://vellomobilidade.com.br/webhook/pagseguro',
      };

      final response = await http.post(
        Uri.parse('$_pagSeguroBaseUrl/v2/checkout'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: paymentData.entries.map((e) => '${e.key}=${e.value}').join('&'),
      );

      if (response.statusCode == 200) {
        // Parse XML response do PagSeguro
        final responseBody = response.body;
        // Implementar parser XML aqui
        
        await _saveTransaction({
          'rideId': rideId,
          'amount': amount,
          'method': paymentMethod,
          'status': 'pending',
          'gateway': 'pagseguro',
          'createdAt': FieldValue.serverTimestamp(),
        });

        return PaymentResult.success(
          transactionId: 'pagseguro_${DateTime.now().millisecondsSinceEpoch}',
          status: 'pending',
        );
      } else {
        return PaymentResult.error('Erro no PagSeguro: ${response.body}');
      }
    } catch (e) {
      return PaymentResult.error('Erro ao processar pagamento PagSeguro: $e');
    }
  }

  /// Processa pagamento em dinheiro
  Future<PaymentResult> processCashPayment({
    required double amount,
    required String rideId,
    required String driverId,
  }) async {
    try {
      await _saveTransaction({
        'rideId': rideId,
        'amount': amount,
        'method': 'cash',
        'status': 'completed',
        'gateway': 'cash',
        'driverId': driverId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Atualiza saldo do motorista
      await _updateDriverBalance(driverId, amount);

      return PaymentResult.success(
        transactionId: 'cash_${DateTime.now().millisecondsSinceEpoch}',
        status: 'completed',
      );
    } catch (e) {
      return PaymentResult.error('Erro ao processar pagamento em dinheiro: $e');
    }
  }

  /// Verifica status de um pagamento
  Future<PaymentStatus> checkPaymentStatus(String transactionId, String gateway) async {
    try {
      switch (gateway) {
        case 'mercadopago':
          return await _checkMercadoPagoStatus(transactionId);
        case 'pagseguro':
          return await _checkPagSeguroStatus(transactionId);
        default:
          return PaymentStatus.unknown;
      }
    } catch (e) {
      print('Erro ao verificar status do pagamento: $e');
      return PaymentStatus.unknown;
    }
  }

  /// Verifica status no Mercado Pago
  Future<PaymentStatus> _checkMercadoPagoStatus(String transactionId) async {
    final response = await http.get(
      Uri.parse('$_mercadoPagoBaseUrl/v1/payments/$transactionId'),
      headers: {
        'Authorization': 'Bearer $_mercadoPagoAccessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final status = data['status'];
      
      switch (status) {
        case 'approved':
          return PaymentStatus.approved;
        case 'pending':
          return PaymentStatus.pending;
        case 'rejected':
          return PaymentStatus.rejected;
        case 'cancelled':
          return PaymentStatus.cancelled;
        default:
          return PaymentStatus.unknown;
      }
    }
    
    return PaymentStatus.unknown;
  }

  /// Verifica status no PagSeguro
  Future<PaymentStatus> _checkPagSeguroStatus(String transactionId) async {
    // Implementar verificação PagSeguro
    return PaymentStatus.unknown;
  }

  /// Processa reembolso
  Future<bool> processRefund(String transactionId, double amount, String reason) async {
    try {
      // Busca transação original
      final transactionDoc = await _firestore
          .collection('transactions')
          .where('id', isEqualTo: transactionId)
          .limit(1)
          .get();

      if (transactionDoc.docs.isEmpty) {
        return false;
      }

      final transaction = transactionDoc.docs.first.data();
      final gateway = transaction['gateway'];

      switch (gateway) {
        case 'mercadopago':
          return await _processMercadoPagoRefund(transactionId, amount, reason);
        case 'pagseguro':
          return await _processPagSeguroRefund(transactionId, amount, reason);
        default:
          return false;
      }
    } catch (e) {
      print('Erro ao processar reembolso: $e');
      return false;
    }
  }

  /// Processa reembolso no Mercado Pago
  Future<bool> _processMercadoPagoRefund(String transactionId, double amount, String reason) async {
    try {
      final refundData = {
        'amount': amount,
        'reason': reason,
      };

      final response = await http.post(
        Uri.parse('$_mercadoPagoBaseUrl/v1/payments/$transactionId/refunds'),
        headers: {
          'Authorization': 'Bearer $_mercadoPagoAccessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode(refundData),
      );

      return response.statusCode == 201;
    } catch (e) {
      print('Erro no reembolso Mercado Pago: $e');
      return false;
    }
  }

  /// Processa reembolso no PagSeguro
  Future<bool> _processPagSeguroRefund(String transactionId, double amount, String reason) async {
    // Implementar reembolso PagSeguro
    return false;
  }

  /// Salva transação no Firestore
  Future<void> _saveTransaction(Map<String, dynamic> transactionData) async {
    await _firestore.collection('transactions').add(transactionData);
  }

  /// Atualiza saldo do motorista
  Future<void> _updateDriverBalance(String driverId, double amount) async {
    await _firestore.collection('motoristas').doc(driverId).update({
      'totalEarnings': FieldValue.increment(amount),
    });
  }

  /// Obtém métodos de pagamento disponíveis
  List<PaymentMethod> getAvailablePaymentMethods() {
    return [
      PaymentMethod(
        id: 'pix',
        name: 'PIX',
        icon: 'pix_icon',
        enabled: _mercadoPagoAccessToken != null,
      ),
      PaymentMethod(
        id: 'credit_card',
        name: 'Cartão de Crédito',
        icon: 'credit_card_icon',
        enabled: _mercadoPagoAccessToken != null,
      ),
      PaymentMethod(
        id: 'debit_card',
        name: 'Cartão de Débito',
        icon: 'debit_card_icon',
        enabled: _mercadoPagoAccessToken != null,
      ),
      PaymentMethod(
        id: 'cash',
        name: 'Dinheiro',
        icon: 'cash_icon',
        enabled: true,
      ),
    ];
  }

  /// Calcula taxa da plataforma
  double calculatePlatformFee(double amount) {
    const feePercentage = 0.15; // 15% de taxa
    return amount * feePercentage;
  }

  /// Calcula valor líquido para o motorista
  double calculateDriverEarnings(double amount) {
    final fee = calculatePlatformFee(amount);
    return amount - fee;
  }
}

/// Resultado de um pagamento
class PaymentResult {
  final bool success;
  final String? transactionId;
  final String? qrCode;
  final String? qrCodeBase64;
  final String? status;
  final String? errorMessage;

  PaymentResult._({
    required this.success,
    this.transactionId,
    this.qrCode,
    this.qrCodeBase64,
    this.status,
    this.errorMessage,
  });

  factory PaymentResult.success({
    required String transactionId,
    String? qrCode,
    String? qrCodeBase64,
    String? status,
  }) {
    return PaymentResult._(
      success: true,
      transactionId: transactionId,
      qrCode: qrCode,
      qrCodeBase64: qrCodeBase64,
      status: status,
    );
  }

  factory PaymentResult.error(String message) {
    return PaymentResult._(
      success: false,
      errorMessage: message,
    );
  }
}

/// Status de pagamento
enum PaymentStatus {
  pending,
  approved,
  rejected,
  cancelled,
  unknown,
}

/// Método de pagamento
class PaymentMethod {
  final String id;
  final String name;
  final String icon;
  final bool enabled;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.icon,
    required this.enabled,
  });
}

