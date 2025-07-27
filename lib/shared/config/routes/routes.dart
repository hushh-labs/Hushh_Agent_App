import 'package:flutter/material.dart';
import 'package:hushh_agent_app/app/features/splash/presentation/pages/splash_page_with_bloc.dart';


class AppRoutes {
   static const String splash = '/splash';
}

// navigation manager for  navigating the screens..

class NavigationManager {
    static final Map<String, WidgetBuilder> routes = {  
       // route for the splashscreen ...
          AppRoutes.splash: (context) => const SplashPageWithBloc(),


    };
}