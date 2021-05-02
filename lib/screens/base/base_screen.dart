import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rodagem/common/custom_drawer/custom_drawer.dart';
import 'package:rodagem/models/page_manager.dart';
import 'package:rodagem/screens/profile/profile_screen.dart';
import 'package:rodagem/screens/register/register_screen.dart';
import 'package:rodagem/screens/viagens/all_viagens.dart';
import 'package:rodagem/screens/viagens/my_viagens.dart';

class BaseScreen extends StatelessWidget {
  final PageController pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) => PageManager(pageController),
      child: PageView(
        controller: pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: <Widget>[
          Scaffold(
            drawer: CustomDrawer(),
            appBar: AppBar(
              title: const Text('Home'),
            ),
            body: AllViagens(),
          ),
          Scaffold(
            drawer: CustomDrawer(),
            appBar: AppBar(
              title: const Text('Meu Perfil'),
            ),
            body: ProfileScreen(),
          ),
          Scaffold(
            drawer: CustomDrawer(),
            appBar: AppBar(
              title: const Text('Cadastrar viagem'),
            ),
            body: RegisterScreen(),
          ),
          Scaffold(
            drawer: CustomDrawer(),
            appBar: AppBar(
              title: const Text('Minhas viagens'),
            ),
            body: ViagemScreen(),
          ),
        ],
      ),
    );
  }
}
