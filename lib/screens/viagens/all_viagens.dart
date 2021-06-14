import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rodagem/models/register_viagem.dart';
import 'package:rodagem/screens/viagens/detail_viagem.dart';
import 'package:rodagem/widget/item_viagem.dart';

class AllViagens extends StatefulWidget {
  @override
  _AllViagensState createState() => _AllViagensState();
}

class _AllViagensState extends State<AllViagens> {
  String _idUsuarioLogado;
  String _typeUser;

  final _controller = StreamController<QuerySnapshot>.broadcast();

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _adicionarListenerViagens();
  }

  _recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();
    _idUsuarioLogado = usuarioLogado.uid;

    Firestore db = Firestore.instance;
    DocumentSnapshot snapshot =
        await db.collection("users").document(_idUsuarioLogado).get();

    Map<String, dynamic> dados = snapshot.data;

    return dados["typeUser"];
  }

  Future<Stream<QuerySnapshot>> _adicionarListenerViagens() async {
    _typeUser = await _recuperarDadosUsuario();

    if (_typeUser == "motorista") {
      Firestore db = Firestore.instance;
      Stream<QuerySnapshot> stream = db
          .collection("minhas_viagens")
          .document(_idUsuarioLogado)
          .collection("viagens")
          .snapshots();

      stream.listen((dados) {
        _controller.add(dados);
      });
    } else if (_typeUser == "transportadora") {
      Firestore db = Firestore.instance;
      Stream<QuerySnapshot> stream = db.collection("viagens").snapshots();

      stream.listen((dados) {
        _controller.add(dados);
      });
    }
  }

  Future<Null> refreshViagem() async {
    _refreshIndicatorKey.currentState?.show(atTop: false);
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _adicionarListenerViagens();
    });

    return null;
  }

  @override
  Widget build(BuildContext context) {
    var carregandoDados = Center(
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 20,
          ),
          Text("Carregando Viagens"),
          CircularProgressIndicator(),
        ],
      ),
    );

    return Container(
      padding: EdgeInsets.all(16),
      child: RefreshIndicator(
        key: _refreshIndicatorKey,
        child: Column(
          children: [
            StreamBuilder(
              stream: _controller.stream,
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return carregandoDados;
                    break;
                  case ConnectionState.active:
                  case ConnectionState.done:
                    QuerySnapshot querySnapshot = snapshot.data;

                    if (querySnapshot.documents.length == 0) {
                      return Container(
                        padding: EdgeInsets.all(25),
                        child: Text(
                          "Nenhuma viagem",
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      );
                    }

                    return Expanded(
                      child: ListView.builder(
                          itemCount: querySnapshot.documents.length,
                          itemBuilder: (_, indice) {
                            List<DocumentSnapshot> viagens =
                                querySnapshot.documents.toList();
                            DocumentSnapshot documentSnapshot = viagens[indice];
                            RegisterViagem registerViagem =
                                RegisterViagem.fromDocumentSnapshot(
                                    documentSnapshot);
                            return ItemViagens(
                              viagens: registerViagem,
                              onTapItem: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => DetailScreen(
                                            registerViagem, _typeUser)));
                              },
                            );
                          }),
                    );
                }
                return Container();
              },
            ),
          ],
        ),
        onRefresh: refreshViagem,
      ),
    );
  }
}
