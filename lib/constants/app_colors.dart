// Importa o pacote Material do Flutter para usar a classe Color
import 'package:flutter/material.dart';

// Classe que define todas as cores utilizadas no aplicativo Vello Motorista
import 'package:flutter/material.dart';

class VelloColors {

  // ========== CORES PRINCIPAIS DA IDENTIDADE VISUAL VELLO ==========

  // Cor laranja principal da marca Vello (cor primária do aplicativo)
  static const Color laranja = Color(0xFFFF6B35);
  static const Color laranjaClaro = Color(0xFFFFB094);
  static const Color azul = Color(0xFF2E86AB);
  static const Color azulEscuro = Color(0xFF1B5E87);

  // ========== CORES NEUTRAS BÁSICAS ==========

  // Branco puro para fundos e textos em elementos escuros
  static const Color branco = Color(0xFFFFFFFF);

  // Preto puro para textos principais e ícones
  static const Color preto = Color(0xFF000000);

  // Cinza médio para textos secundários e elementos menos importantes
  static const Color cinza = Color(0xFF6B7280);

  // Cinza claro para fundos de campos de texto e áreas sutis
  static const Color cinzaClaro = Color(0xFFF3F4F6);

  // Cinza escuro para textos que precisam de mais contraste
  static const Color cinzaEscuro = Color(0xFF374151);

  // Cor creme suave para fundos de telas principais
  static const Color creme = Color(0xFFF8F9FA);

  // ========== CORES DE STATUS E FEEDBACK ==========

  // Verde para indicar sucesso, confirmações e estados positivos
  static const Color sucesso = Color(0xFF10B981);

  // Vermelho para indicar erros, falhas e estados negativos
  static const Color erro = Color(0xFFEF4444);

  // Amarelo/laranja para avisos e alertas importantes
  static const Color aviso = Color(0xFFF59E0B);

  // Azul para informações gerais e elementos informativos
  static const Color info = Color(0xFF3B82F6);

  // ========== GRADIENTES PARA EFEITOS VISUAIS ==========

  // Gradiente principal que combina laranja e azul da marca
  // Usado em botões principais e elementos de destaque
  static const LinearGradient gradientePrincipal = LinearGradient(
    begin: Alignment.topLeft, // Inicia no canto superior esquerdo
    end: Alignment.bottomRight, // Termina no canto inferior direito
    colors: [laranja, azul], // Transição do laranja para o azul
  );

  // Gradiente secundário usando tons de azul
  // Usado em elementos secundários e fundos
  static const LinearGradient gradienteSecundario = LinearGradient(
    begin: Alignment.topCenter, // Inicia no centro superior
    end: Alignment.bottomCenter, // Termina no centro inferior
    colors: [azul, azulEscuro], // Transição do azul para azul escuro
  );

  // Gradiente em tons de laranja
  // Usado para criar variações da cor principal
  static const LinearGradient gradienteLaranja = LinearGradient(
    begin: Alignment.topLeft, // Inicia no canto superior esquerdo
    end: Alignment.bottomRight, // Termina no canto inferior direito
    colors: [Color(0xFFFF8A50), laranja], // Transição de laranja claro para laranja principal
  );

  // ========== CORES COM TRANSPARÊNCIA ==========

  // Laranja com 50% de transparência (0x80 = 128/255 = 50%)
  // Usado para sobreposições e efeitos sutis
  static const Color laranjaTransparente = Color(0x80FF6B35);

  // Azul com 50% de transparência
  // Usado para fundos semi-transparentes
  static const Color azulTransparente = Color(0x802E3A59);

  // Preto com 50% de transparência
  // Usado para sobreposições escuras e sombras
  static const Color pretoTransparente = Color(0x80000000);

  // Branco com 50% de transparência
  // Usado para sobreposições claras e efeitos de luz
  static const Color brancoTransparente = Color(0x80FFFFFF);
}

// Classe para compatibilidade com telas que usam AppColors
class AppColors {
  static const Color primary = Color(0xFFFF6B35);
  static const Color secondary = Color(0xFF2E86AB);
  static const Color accent = Color(0xFFFFB094);
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF3F4F6);
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF6B7280);
}