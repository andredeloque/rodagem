import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rodagem/common/custom_drawer/custom_drawer_header.dart';
import 'package:rodagem/common/custom_drawer/drawer_tile.dart';

class CustomDrawer extends StatelessWidget {

  String _idUsuarioLogado;

  String _typeUser;

  //CustomDrawer(this._typeUser);

  _recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();
    _idUsuarioLogado = usuarioLogado.uid;

    Firestore db = Firestore.instance;
    DocumentSnapshot snapshot = await db.collection("users")
        .document(_idUsuarioLogado)
        .get();

    Map<String, dynamic> dados = snapshot.data;

    _typeUser = dados["typeUser"];

    print(_typeUser);

  }

  @override
  Widget build(BuildContext context) {
    _recuperarDadosUsuario();
    return Drawer(
      child: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
              colors: [
                const Color.fromARGB(255, 203, 236, 241),
                Colors.white,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            )),
          ),
          ListView(
            children: <Widget>[
              CustomDrawerHeader(),
              const Divider(),
              DrawerTile(
                iconData: Icons.home,
                title: 'Início',
                page: 0,
              ),
              DrawerTile(
                iconData: Icons.admin_panel_settings,
                title: 'Meu Perfil',
                page: 1,
              ),
              //if(_typeUser == 'motorista')...[
              DrawerTile(
                iconData: Icons.playlist_add_check,
                title: 'Cadastrar viagem',
                page: 2,
              ),
              DrawerTile(
                iconData: Icons.car_rental,
                title: 'Minhas viagens',
                page: 3,
              ),
              //],
            ],
          ),
        ],
      ),
    );
  }
}
