import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rpos/routers/app_router.dart%20Dart.dart';


import 'splash_screen/welcome_screen.dart';
// Keep the auth imports only if you still need them for routes

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    const ProviderScope(
      child: NourishApp(),
    ),
  );
}

class NourishApp extends StatelessWidget {
  const NourishApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(          // ← changed
          debugShowCheckedModeBanner: false,
          routerConfig: appRouter,         // ← use the router
        );
      },
    );
  }
}