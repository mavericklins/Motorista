import 'package:flutter/material.dart';
import '../screens/auth/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/main_navigation_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/configuracoes/configuracoes_screen.dart';
import '../screens/perfil/perfil_screen.dart';
import '../screens/historico/historico_screen.dart';
import '../screens/ganhos/meus_creditos_screen.dart';
import '../screens/carteira/carteira_digital_screen.dart';
import '../screens/metas/metas_inteligentes_screen.dart';
import '../screens/corridas_programadas/corridas_programadas_screen.dart';
import '../screens/analytics/analytics_dashboard_screen.dart';
import '../screens/coaching/coaching_inteligente_screen.dart';
import '../screens/gamification/conquistas_screen.dart';
import '../screens/gamification/goals_screen.dart';
import '../screens/insights/demand_prediction_screen.dart';
import '../screens/security/sos_screen.dart';
import '../screens/suporte/suporte_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String mainNavigation = '/main';
  static const String home = '/home';
  static const String configuracoes = '/configuracoes';
  static const String perfil = '/perfil';
  static const String historico = '/historico';
  static const String ganhos = '/ganhos';
  static const String carteira = '/carteira';
  static const String metas = '/metas';
  static const String corridasProgramadas = '/corridas-programadas';
  static const String analytics = '/analytics';
  static const String coaching = '/coaching';
  static const String conquistas = '/conquistas';
  static const String goals = '/goals';
  static const String insights = '/insights';
  static const String sos = '/sos';
  static const String suporte = '/suporte';

  static Map<String, WidgetBuilder> get routes {
    return {
      splash: (context) => const SplashScreen(),
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      mainNavigation: (context) => const MainNavigationScreen(),
      home: (context) => const HomeScreen(),
      configuracoes: (context) => const ConfiguracoesScreen(),
      perfil: (context) => const PerfilScreen(),
      historico: (context) => const HistoricoScreen(),
      ganhos: (context) => const MeusCreditosScreen(),
      carteira: (context) => const CarteiraDigitalScreen(),
      metas: (context) => const MetasInteligentesScreen(),
      corridasProgramadas: (context) => const CorridasProgramadasScreen(),
      analytics: (context) => const AnalyticsDashboardScreen(),
      coaching: (context) => const CoachingInteligenteScreen(),
      conquistas: (context) => const ConquistasScreen(),
      goals: (context) => const GoalsScreen(),
      insights: (context) => const DemandPredictionScreen(),
      sos: (context) => const SosScreen(),
      suporte: (context) => const SuporteScreen(),
    };
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (context) => SplashScreen());
      case AppRoutes.login:
        return MaterialPageRoute(builder: (context) => LoginScreen());
      case AppRoutes.register:
        return MaterialPageRoute(builder: (context) => RegisterScreen());
      case AppRoutes.mainNavigation:
        return MaterialPageRoute(builder: (context) => MainNavigationScreen());
      case AppRoutes.home:
        return MaterialPageRoute(builder: (context) => HomeScreen());
      case AppRoutes.configuracoes:
        return MaterialPageRoute(builder: (context) => ConfiguracoesScreen());
      case AppRoutes.perfil:
        return MaterialPageRoute(builder: (context) => PerfilScreen());
      case AppRoutes.historico:
        return MaterialPageRoute(builder: (context) => HistoricoScreen());
      case AppRoutes.ganhos:
        return MaterialPageRoute(builder: (context) => MeusCreditosScreen());
      case AppRoutes.carteira:
        return MaterialPageRoute(builder: (context) => CarteiraDigitalScreen());
      case AppRoutes.metas:
        return MaterialPageRoute(builder: (context) => MetasInteligentesScreen());
      case AppRoutes.corridasProgramadas:
        return MaterialPageRoute(builder: (context) => CorridasProgramadasScreen());
      case AppRoutes.analytics:
        return MaterialPageRoute(builder: (context) => AnalyticsDashboardScreen());
      case AppRoutes.coaching:
        return MaterialPageRoute(builder: (context) => CoachingInteligenteScreen());
      case AppRoutes.conquistas:
        return MaterialPageRoute(builder: (context) => ConquistasScreen());
      case AppRoutes.goals:
        return MaterialPageRoute(builder: (context) => GoalsScreen());
      case AppRoutes.insights:
        return MaterialPageRoute(builder: (context) => DemandPredictionScreen());
      case AppRoutes.sos:
        return MaterialPageRoute(builder: (context) => SosScreen());
      case AppRoutes.suporte:
        return MaterialPageRoute(builder: (context) => SuporteScreen());
      default:
        // Fallback for unknown routes, could be SplashScreen or HomeScreen
        return MaterialPageRoute(builder: (context) => HomeScreen());
    }
  }
}