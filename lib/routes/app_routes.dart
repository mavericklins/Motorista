
import 'package:flutter/material.dart';

// Screens
import '../screens/auth/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/main_navigation_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/perfil/perfil_screen.dart';
import '../screens/configuracoes/configuracoes_screen.dart';
import '../screens/historico/historico_screen.dart';
import '../screens/ganhos/meus_creditos_screen.dart';
import '../screens/analytics/analytics_dashboard_screen.dart';
import '../screens/insights/demand_prediction_screen.dart';
import '../screens/gamification/conquistas_screen.dart';
import '../screens/gamification/goals_screen.dart';
import '../screens/carteira/carteira_digital_screen.dart';
import '../screens/corridas_programadas/corridas_programadas_screen.dart';
import '../screens/security/sos_screen.dart';
import '../screens/support/support_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String mainNavigation = '/main';
  static const String home = '/home';
  static const String perfil = '/perfil';
  static const String configuracoes = '/configuracoes';
  static const String historico = '/historico';
  static const String ganhos = '/ganhos';
  static const String analytics = '/analytics';
  static const String insights = '/insights';
  static const String conquistas = '/conquistas';
  static const String goals = '/goals';
  static const String carteira = '/carteira';
  static const String corridasProgramadas = '/corridas-programadas';
  static const String sos = '/sos';
  static const String support = '/support';

  static Map<String, WidgetBuilder> get routes {
    return {
      splash: (context) => const SplashScreen(),
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      mainNavigation: (context) => const MainNavigationScreen(),
      home: (context) => const HomeScreen(),
      perfil: (context) => const PerfilScreen(),
      configuracoes: (context) => const ConfiguracoesScreen(),
      historico: (context) => const HistoricoScreen(),
      ganhos: (context) => const MeusCreditosScreen(),
      analytics: (context) => const AnalyticsDashboardScreen(),
      insights: (context) => const DemandPredictionScreen(),
      conquistas: (context) => const ConquistasScreen(),
      goals: (context) => const GoalsScreen(),
      carteira: (context) => const CarteiraDigitalScreen(),
      corridasProgramadas: (context) => const CorridasProgramadasScreen(),
      sos: (context) => const SOSScreen(),
      support: (context) => const SupportScreen(),
    };
  }

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final builder = routes[settings.name];
    if (builder != null) {
      return MaterialPageRoute(
        builder: builder,
        settings: settings,
      );
    }
    
    // Rota não encontrada - redirecionar para home
    return MaterialPageRoute(
      builder: (context) => const HomeScreen(),
      settings: settings,
    );
  }
}
