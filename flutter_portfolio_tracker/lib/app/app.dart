import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class HyperApp extends ConsumerWidget {
  const HyperApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light,
    ));

    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Hyperliquid Tracker',
      theme: AppTheme.dark,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
