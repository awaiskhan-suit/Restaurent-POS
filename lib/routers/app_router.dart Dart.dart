// lib/router/app_router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../auth/Sign_In.dart';
import '../auth/Sign_Up.dart';
import '../screens/cart_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/main_screen_shell.dart';
import '../screens/menu_screen.dart';
import '../screens/orders_screen.dart';
import '../screens/table_screen.dart';
import '../splash_screen/welcome_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey =
GlobalKey<NavigatorState>(debugLabel: 'root');

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/welcome',
  routes: [
    // ---------- Auth / Welcome ----------
    GoRoute(
      path: '/welcome',
      name: 'welcome',
      builder: (context, state) => WelcomeScreen(
        onLogin: () => context.go('/login'),
        onSignUp: () => context.go('/signup'),
      ),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      name: 'signup',
      builder: (context, state) => const SignUpScreen(),
    ),

    // ---------- Main app with bottom navigation ----------
    StatefulShellRoute.indexedStack(
      builder: (
          BuildContext context,
          GoRouterState state,
          StatefulNavigationShell navigationShell,
          ) {
        return MainShell(navigationShell: navigationShell);
      },
      branches: [
        // Index 0 – Dashboard
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard',
              name: 'dashboard',
              builder: (context, state) => const DashboardScreen(),
            ),
          ],
        ),

        // Index 1 – Menu
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/menu',
              name: 'menu',
              builder: (context, state) => const MenuScreen(),
            ),
          ],
        ),

        // Index 2 – Orders
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/orders',
              name: 'orders',
              builder: (context, state) => const OrdersScreen(),
            ),
          ],
        ),

        // Index 3 – Cart
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/cart',
              name: 'cart',
              builder: (context, state) => const CartScreen(),
            ),
          ],
        ),


      ],
    ),
  ],
);