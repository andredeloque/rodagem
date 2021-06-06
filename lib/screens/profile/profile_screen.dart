import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rodagem/screens/profile/edit_profile.dart';
import 'package:rodagem/screens/viagens/my_viagens.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _idUsuarioLogado;
  String _nomeUsuario;
  String _urlImagemRecuperada;
  String _emailUsuario;
  String _nomeCarreta;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  _recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();
    _idUsuarioLogado = usuarioLogado.uid;

    Firestore db = Firestore.instance;
    DocumentSnapshot snapshot =
        await db.collection("users").document(_idUsuarioLogado).get();

    Map<String, dynamic> dados = snapshot.data;

    setState(() {
      _emailUsuario = dados["email"];
      _nomeUsuario = dados["nick"];
      _nomeCarreta = dados["name"];
    });

    if (dados["urlImagem"] != null) {
      setState(() {
        _urlImagemRecuperada = dados["urlImagem"];
      });
    }
  }

  Future<Null> refreshProfile() async {
    _refreshIndicatorKey.currentState?.show(atTop: false);
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _recuperarDadosUsuario();
    });

    return null;
  }

  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: RefreshIndicator(
        key: _refreshIndicatorKey,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(8, 50, 10, 8),
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfile()));
                },
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  elevation: 5,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                    height: 100,
                    child: Row(
                      children: [
                        CircleAvatar(
                          maxRadius: 40,
                          backgroundColor: Colors.grey,
                          backgroundImage: _urlImagemRecuperada != null
                              ? NetworkImage(_urlImagemRecuperada)
                              : null,
                        ),
                        Container(
                          height: 100,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(10, 1, 0, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_nomeUsuario != null ? _nomeUsuario : '',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(0, 3, 0, 3),
                                  child: Container(
                                    child: Text(
                                        _emailUsuario != null
                                            ? _emailUsuario
                                            : '',
                                        style: TextStyle(fontSize: 14)),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(0, 3, 0, 3),
                                  child: Container(
                                    child: Text(
                                        _nomeCarreta != null
                                            ? _nomeCarreta
                                            : '',
                                        style: TextStyle(fontSize: 18)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              RaisedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfile()));
                },
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'PERFIL',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black54,
                        ),
                      ),
                      Icon(
                        Icons.my_location,
                        color: Colors.black,
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
        onRefresh: refreshProfile,
      ),
    );
  }
}
