import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

/// Serviço para gerenciar permissões de overlay no Android
/// Necessário para popup sobrepor todas as aplicações
class OverlayService {
  static const MethodChannel _channel = MethodChannel('com.vello.motorista/overlay');
  
  /// Verifica se a permissão de overlay está concedida
  static Future<bool> checkOverlayPermission() async {
    try {
      final bool hasPermission = await _channel.invokeMethod('checkOverlayPermission');
      return hasPermission;
    } catch (e) {
      print('❌ Erro ao verificar permissão de overlay: $e');
      return false;
    }
  }
  
  /// Solicita permissão de overlay ao usuário
  static Future<void> requestOverlayPermission() async {
    try {
      await _channel.invokeMethod('requestOverlayPermission');
    } catch (e) {
      print('❌ Erro ao solicitar permissão de overlay: $e');
    }
  }
  
  /// Configura a tela para aparecer sobre a tela de bloqueio
  static Future<void> showOnLockScreen() async {
    try {
      await _channel.invokeMethod('showOnLockScreen');
    } catch (e) {
      print('❌ Erro ao configurar tela de bloqueio: $e');
    }
  }
  
  /// Solicita todas as permissões necessárias para o aplicativo
  static Future<bool> requestAllPermissions() async {
    try {
      print('🔐 Solicitando permissões necessárias...');
      
      // Lista de permissões necessárias
      final permissions = [
        Permission.location,
        Permission.locationAlways,
        Permission.camera,
        Permission.storage,
        Permission.notification,
      ];
      
      // Solicitar permissões básicas
      Map<Permission, PermissionStatus> statuses = await permissions.request();
      
      // Verificar se todas foram concedidas
      bool allGranted = statuses.values.every((status) => 
          status == PermissionStatus.granted || 
          status == PermissionStatus.limited);
      
      // Solicitar permissão de overlay separadamente
      if (!await checkOverlayPermission()) {
        await requestOverlayPermission();
      }
      
      if (allGranted) {
        print('✅ Todas as permissões foram concedidas');
      } else {
        print('⚠️ Algumas permissões não foram concedidas');
        // Log das permissões negadas
        statuses.forEach((permission, status) {
          if (status != PermissionStatus.granted && status != PermissionStatus.limited) {
            print('❌ Permissão negada: $permission - Status: $status');
          }
        });
      }
      
      return allGranted;
      
    } catch (e) {
      print('❌ Erro ao solicitar permissões: $e');
      return false;
    }
  }
  
  /// Verifica se todas as permissões estão concedidas
  static Future<bool> checkAllPermissions() async {
    try {
      final permissions = [
        Permission.location,
        Permission.locationAlways,
        Permission.camera,
        Permission.storage,
        Permission.notification,
      ];
      
      // Verificar permissões básicas
      bool allGranted = true;
      for (Permission permission in permissions) {
        final status = await permission.status;
        if (status != PermissionStatus.granted && status != PermissionStatus.limited) {
          allGranted = false;
          break;
        }
      }
      
      // Verificar permissão de overlay
      final hasOverlay = await checkOverlayPermission();
      
      return allGranted && hasOverlay;
      
    } catch (e) {
      print('❌ Erro ao verificar permissões: $e');
      return false;
    }
  }
  
  /// Obtém informações sobre o status das permissões
  static Future<Map<String, bool>> getPermissionsStatus() async {
    try {
      final permissions = [
        Permission.location,
        Permission.locationAlways,
        Permission.camera,
        Permission.storage,
        Permission.notification,
      ];
      
      Map<String, bool> status = {};
      
      for (Permission permission in permissions) {
        final permissionStatus = await permission.status;
        status[permission.toString()] = permissionStatus == PermissionStatus.granted ||
                                       permissionStatus == PermissionStatus.limited;
      }
      
      // Adicionar status de overlay
      status['overlay'] = await checkOverlayPermission();
      
      return status;
      
    } catch (e) {
      print('❌ Erro ao obter status das permissões: $e');
      return {};
    }
  }
  
  /// Força o aplicativo a aparecer sobre outras aplicações
  /// Útil quando uma corrida chega
  static Future<void> bringAppToForeground() async {
    try {
      // Configurar para aparecer na tela de bloqueio
      await showOnLockScreen();
      
      // Aqui você pode adicionar lógica adicional para trazer o app para frente
      print('📱 App configurado para aparecer sobre outras aplicações');
      
    } catch (e) {
      print('❌ Erro ao trazer app para frente: $e');
    }
  }
}