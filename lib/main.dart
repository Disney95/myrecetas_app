import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/recetas_provider.dart';
import 'providers/almacen_provider.dart';
import 'providers/categorias_provider.dart';
import 'providers/tema_provider.dart';
import 'providers/moneda_provider.dart';
import 'screens/main_navigation.dart';

void main() {
  runApp(const RecetasApp());
}

class RecetasApp extends StatelessWidget {
  const RecetasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RecetasProvider()),
        ChangeNotifierProvider(create: (_) => AlmacenProvider()),
        ChangeNotifierProvider(create: (_) => CategoriasProvider()),
        ChangeNotifierProvider(create: (_) => TemaProvider()),
        ChangeNotifierProvider(create: (_) => MonedaProvider()),
      ],
      child: Consumer<TemaProvider>(
        builder: (context, temaProvider, _) {
          return MaterialApp(
            title: 'MyRecestas',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.theme,
            darkTheme: AppTheme.themeOscuro,
            themeMode: temaProvider.modo,
            home: const MainNavigation(),
          );
        },
      ),
    );
  }
}
