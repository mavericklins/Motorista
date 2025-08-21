import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'presence_service.dart'; // LINHA ADICIONADA

class AuthService extends ChangeNotifier {
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? errorMessage;

  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => currentUser != null;

  // ========== FUNÇÃO DE LOGIN ==========
  
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        final doc = await _firestore
            .collection('motoristas')
            .doc(credential.user!.uid)
            .get();

        if (doc.exists) {
          // ADICIONADO: Inicializar presença após login bem-sucedido
          await PresenceService().initializePresence();
          
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          await _auth.signOut();
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ========== FUNÇÃO DE CADASTRO COMPLETO ==========
  
  Future<bool> createAccount(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      _isLoading = false;
      errorMessage = null;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ========== FUNÇÃO PARA SALVAR MOTORISTA COMPLETO ==========
  
  Future<bool> salvarMotoristaCompleto({
    required String nome,
    required String email,
    required String cpf,
    required String telefone,
    required String modelo,
    required String ano,
    required String placa,
    File? cnhFile,
    File? selfieFile,
    File? carroFile,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      User? user = _auth.currentUser;
      if (user == null) {
        errorMessage = "Usuário não autenticado";
        _isLoading = false;
        notifyListeners();
        return false;
      }

      String uid = user.uid;

      // Upload das imagens para Firebase Storage
      String? cnhUrl;
      String? selfieUrl;
      String? carroUrl;

      if (cnhFile != null) {
        cnhUrl = await _uploadImage(cnhFile, 'cnh/$uid');
      }

      if (selfieFile != null) {
        selfieUrl = await _uploadImage(selfieFile, 'selfies/$uid');
      }

      if (carroFile != null) {
        carroUrl = await _uploadImage(carroFile, 'carros/$uid');
      }

      // Salvar dados completos no Firestore
      await _firestore.collection('motoristas').doc(uid).set({
        'uid': uid,
        'nome': nome,
        'email': email,
        'cpf': cpf,
        'telefone': telefone,
        'modelo': modelo,
        'ano': ano,
        'placa': placa.toUpperCase(),
        'cnhUrl': cnhUrl ?? '',
        'selfieUrl': selfieUrl ?? '',
        'carroUrl': carroUrl ?? '',
        'status': 'ativo',
        'aprovado': true, // Aprovação automática
        'criadoEm': FieldValue.serverTimestamp(),
        'atualizadoEm': FieldValue.serverTimestamp(),
        // ADICIONADO: Campos de presença
        'isOnline': false,
        'online': false,
        'statusOnline': false,
        'lastSeen': FieldValue.serverTimestamp(),
        'lastActivity': FieldValue.serverTimestamp(),
      });

      _isLoading = false;
      notifyListeners();
      return true;

    } catch (e) {
      errorMessage = "Erro ao salvar dados: ${e.toString()}";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ========== FUNÇÃO PARA UPLOAD DE IMAGENS ==========
  
  Future<String> _uploadImage(File imageFile, String path) async {
    try {
      // Criar referência no Storage
      Reference ref = _storage.ref().child(path);
      
      // Upload do arquivo
      UploadTask uploadTask = ref.putFile(imageFile);
      
      // Aguardar conclusão
      TaskSnapshot snapshot = await uploadTask;
      
      // Obter URL de download
      String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      print("Erro no upload da imagem: $e");
      return '';
    }
  }

  // ========== FUNÇÃO PARA SALVAR PARA APROVAÇÃO (COMPATIBILIDADE) ==========
  
  Future<void> salvarMotoristaParaAprovacao({
    required String uid,
    required String nome,
    required String email,
    required String cpf,
    required String modelo,
    required String ano,
    required String placa,
    required String cnhUrl,
    required String selfieUrl,
    required String carroUrl,
  }) async {
    // Salva na coleção principal (aprovação automática)
    await _firestore.collection('motoristas').doc(uid).set({
      'uid': uid,
      'nome': nome,
      'email': email,
      'cpf': cpf,
      'modelo': modelo,
      'ano': ano,
      'placa': placa.toUpperCase(),
      'cnhUrl': cnhUrl,
      'selfieUrl': selfieUrl,
      'carroUrl': carroUrl,
      'status': 'ativo',
      'aprovado': true,
      'criadoEm': FieldValue.serverTimestamp(),
      // ADICIONADO: Campos de presença
      'isOnline': false,
      'online': false,
      'statusOnline': false,
      'lastSeen': FieldValue.serverTimestamp(),
      'lastActivity': FieldValue.serverTimestamp(),
    });

    // Também salva na coleção de aprovação (para histórico)
    await _firestore.collection('motoristas_aguardando_aprovacao').doc(uid).set({
      'nome': nome,
      'email': email,
      'cpf': cpf,
      'modelo': modelo,
      'ano': ano,
      'placa': placa,
      'cnhUrl': cnhUrl,
      'selfieUrl': selfieUrl,
      'carroUrl': carroUrl,
      'status': 'aprovado', // Já aprovado automaticamente
      'criadoEm': FieldValue.serverTimestamp(),
    });
  }

  // ========== FUNÇÃO DE LOGOUT ==========
  
  Future<void> signOut() async {
    try {
      // ADICIONADO: Limpar presença antes de fazer logout
      await PresenceService().cleanup();
      
      await _auth.signOut();
      notifyListeners();
    } catch (e) {
      print('Erro no logout: $e');
      await _auth.signOut();
      notifyListeners();
    }
  }

  // ========== FUNÇÃO PARA BUSCAR DADOS DO MOTORISTA ==========
  
  Future<Map<String, dynamic>?> getDadosMotorista() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return null;

      DocumentSnapshot doc = await _firestore
          .collection('motoristas')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print("Erro ao buscar dados do motorista: $e");
      return null;
    }
  }

  // ========== FUNÇÃO PARA ATUALIZAR DADOS ==========
  
  Future<bool> atualizarDadosMotorista(Map<String, dynamic> dados) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return false;

      dados['atualizadoEm'] = FieldValue.serverTimestamp();

      await _firestore
          .collection('motoristas')
          .doc(user.uid)
          .update(dados);

      return true;
    } catch (e) {
      errorMessage = "Erro ao atualizar dados: ${e.toString()}";
      notifyListeners();
      return false;
    }
  }
}

