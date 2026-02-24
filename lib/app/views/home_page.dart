import 'package:flutter/material.dart';
import 'package:payer_payment/app/core/app_colors.dart';
import 'payment_page.dart';
import 'history_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0; // Controla qual ícone está pintado
  late PageController _pageController; // Controla o deslize da tela

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar limpa, fixa no topo
      appBar: AppBar(
        title: const Text(
          'Payer Payment',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.grey),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey[200], height: 1.0),
        ),
      ),

      body: PageView(
        controller: _pageController,
        // Quando o usuário desliza com o dedo, atualizamos o ícone de baixo
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: const [
          PaymentPage(), // Tela 0
          HistoryPage(), // Tela 1
        ],
      ),

      // Barra de Navegação embaixo
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.ease,
          );
        },
        selectedItemColor: AppColors.orange,
        unselectedItemColor: AppColors.grey,
        showUnselectedLabels: true,

        elevation: 10,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.point_of_sale),
            label: 'Cobrar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Histórico',
          ),
        ],
      ),
    );
  }
}
