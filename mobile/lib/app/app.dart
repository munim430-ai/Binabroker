import 'package:binabroker/app/router.dart';
import 'package:binabroker/app/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BinaBrokerApp extends StatelessWidget {
  const BinaBrokerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'BinaBroker',
        theme: AppTheme.dark,
        routerConfig: router,
      ),
    );
  }
}
