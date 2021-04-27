import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rodagem/models/register_viagens.dart';
import 'package:rodagem/screens/register/edit_register_screen.dart';
import 'package:rodagem/screens/register/register_screen.dart';
import 'package:rodagem/widget/item_viagem.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ViagemScreen extends StatefulWidget {
  @override
  _ViagemScreenState createState() => _ViagemScreenState();
}

class _ViagemScreenState extends State<ViagemScreen> {
  final _controller = StreamController<QuerySnapshot>.broadcast();

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  String _idUsuarioLogado;

  _recuperarDadosUsuarioLogado() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();
    _idUsuarioLogado = usuarioLogado.uid;
  }

  Future<Stream<QuerySnapshot>> _adicionarListenerViagem() async {
    await _recuperarDadosUsuarioLogado();

    Firestore db = Firestore.instance;
    Stream<QuerySnapshot> stream = db
        .collection("minhas_viagens")
        .document(_idUsuarioLogado)
        .collection("viagens")
        .snapshots();

    stream.listen((dados) {
      _controller.add(dados);
    });
  }

  _removerAnuncio(String idViagem) {
    Firestore db = Firestore.instance;
    db
        .collection("minhas_viagens")
        .document(_idUsuarioLogado)
        .collection("viagens")
        .document(idViagem)
        .delete()
        .then((_) {
      db.collection("viagens").document(idViagem).delete();
    });
  }

  Future<Null> refreshViagens() async {
    _refreshIndicatorKey.currentState?.show(atTop: false);
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _adicionarListenerViagem();
    });

    return null;
  }

  @override
  void initState() {
    super.initState();
    _adicionarListenerViagem();
  }

  @override
  Widget build(BuildContext context) {
    var carregandoDados = Center(
      child: Column(
        children: <Widget>[
          Text("Carregando viagens"),
          CircularProgressIndicator(),
        ],
      ),
    );

    return Scaffold(
        appBar: AppBar(
          title: Text("Minhas viagens"),
        ),
        floatingActionButton: FloatingActionButton(
          foregroundColor: Colors.green,
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => RegisterScreen()));
          },
        ),
        body: StreamBuilder(
          stream: _controller.stream,
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return carregandoDados;
                break;
              case ConnectionState.active:
              case ConnectionState.done:
                if (snapshot.hasError) return Text("Erro ao carregar dados");

                QuerySnapshot querySnapshot = snapshot.data;

                return Container(
                  child: RefreshIndicator(
                    key: _refreshIndicatorKey,
                    child: ListView.builder(
                        itemCount: querySnapshot.documents.length,
                        itemBuilder: (_, indice) {
                          List<DocumentSnapshot> viagens =
                              querySnapshot.documents.toList();
                          DocumentSnapshot documentSnapshot = viagens[indice];
                          RegisterViagens registerViagens =
                              RegisterViagens.fromDocumentSnapshot(
                                  documentSnapshot);
                          return ItemViagens(
                            viagens: registerViagens,
                            onPreddedRemover: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text("Confirmar"),
                                      content: Text(
                                          "Deseja realmente excluir o viagem?"),
                                      actions: <Widget>[
                                        FlatButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text(
                                              "Cancelar",
                                              style:
                                                  TextStyle(color: Colors.grey),
                                            )),
                                        FlatButton(
                                            color: Colors.red,
                                            onPressed: () {
                                              _removerAnuncio(
                                                  registerViagens.id);
                                              Navigator.of(context).pop();
                                            },
                                            child: Text(
                                              "Remover",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            )),
                                      ],
                                    );
                                  });
                            },
                            onTapItem: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          EditRegisterScreen(registerViagens)));
                            },
                          );
                        }),
                    onRefresh: refreshViagens,
                  ),
                );
            }
            return Container();
          },
        ));
  }
}
