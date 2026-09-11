import 'package:flutter/material.dart';
import 'inicio_screen.dart';
import 'mis_recetas_screen.dart';
import 'crear_editar_receta_screen.dart';
import 'finanzas_screen.dart';
import 'almacen_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _indice = 0;
  final PageController _pageController = PageController();

  final List<Widget> _pantallas = const [
    InicioScreen(),
    MisRecetasScreen(),
    CrearEditarRecetaScreen(),
    AlmacenScreen(),
    FinanzasScreen(),
  ];

  void _irA(int i) {
    setState(() => _indice = i);
    _pageController.animateToPage(
      i,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (i) => setState(() => _indice = i),
        children: _pantallas,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indice,
        onTap: _irA,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book_outlined), activeIcon: Icon(Icons.menu_book), label: 'Mis Recet...'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), activeIcon: Icon(Icons.add_circle), label: 'Crear'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), activeIcon: Icon(Icons.inventory_2), label: 'Almacén'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), activeIcon: Icon(Icons.bar_chart), label: 'Finanzas'),
        ],
      ),
    );
  }
}
