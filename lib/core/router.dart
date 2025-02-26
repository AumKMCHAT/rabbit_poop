import 'package:flutter/material.dart';
import 'package:rabbit_poop/features/rabbitDetails/view/add_rabbit_feces_day_screen.dart';
import 'package:rabbit_poop/features/rabbitDetails/view/add_rabbit_poop_entry_screen.dart';
import 'package:rabbit_poop/features/rabbitDetails/view/add_rabbit_screen.dart';
import 'package:rabbit_poop/features/rabbitDetails/view/health_status_screen.dart';
import 'package:rabbit_poop/features/rabbitDetails/view/rabbit_detail_screen.dart';
import 'package:rabbit_poop/features/welcome/view/welcome_screen.dart';
import 'package:rabbit_poop/utility/constants.dart';

import '../features/home/view/home_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Constants.welcomeScreen:
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());
      case Constants.homeScreen:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case Constants.addRabbitScreen:
        final args = settings.arguments as Map<String, dynamic>?; // Get arguments
        final int? id = args?["id"]; // Extract id from arguments
        return MaterialPageRoute(builder: (_) => AddRabbitScreen(id: id));
      case Constants.rabbitDetail:
        final args = settings.arguments as Map<String, dynamic>?; // Get arguments
        final int? rabbitId = args?["rabbitId"]; // Extract id from arguments
        if (rabbitId == null) {
          return MaterialPageRoute(
            builder: (_) => Scaffold(
              body: Center(child: Text('No route defined for ${settings.name}')),
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => RabbitDetailScreen(rabbitId: rabbitId),
        );
      case Constants.addRabbitPoopEntry:
        final args = settings.arguments as Map<String, dynamic>?; // Get arguments
        final int? id = args?["id"]; // Extract id from arguments
        if (id == null) {
          return MaterialPageRoute(
            builder: (_) => Scaffold(
              body: Center(child: Text('No route defined for ${settings.name}')),
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => AddRabbitPoopEntryScreen(rabbitId: id),
        );
      case Constants.healthStatusScreen:
        final args = settings.arguments as Map<String, dynamic>?; // Get arguments
        final int? healthId = args?["healthId"];
        final int? rabbitId = args?["rabbitId"];
        if (healthId == null || rabbitId == null) {
          return MaterialPageRoute(
            builder: (_) => Scaffold(
              body: Center(child: Text('No route defined for ${settings.name}')),
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => RabbitHealthStatusScreen(
            healthId: healthId,
            rabbitId: rabbitId,
          ),
        );

      case Constants.addRabbitFecesDay:
        final args = settings.arguments as Map<String, dynamic>?; // Get arguments
        final int? healthId = args?["healthId"];
        final int? rabbitId = args?["rabbitId"];
        final String? date = args?["date"];
        if (healthId == null || rabbitId == null || date == null) {
          return MaterialPageRoute(
            builder: (_) => Scaffold(
              body: Center(child: Text('No route defined for ${settings.name}')),
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => AddFecesDayScreen(
            healthId: healthId,
            rabbitId: rabbitId,
            date: date,
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
