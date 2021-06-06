import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rodagem/models/detail_viagens.dart';

class DetailScreen extends StatefulWidget {
  DetailViagens viagem;

  DetailScreen(this.viagem);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  DetailViagens _viagem;

  String _idUsuarioLogado;
  String _typeUser;

  List<Widget> _getListaImagens() {

    List<String> listaUrlImagens = _viagem.fotos;

    return listaUrlImagens.map((url) {
      return Container(
        height: 250,
        decoration: BoxDecoration(
          image: DecorationImage(
              image: NetworkImage(url),
              fit: BoxFit.fitWidth
          ),
        ),
      );
    }).toList();

  }

  _receberViagem() {

    String statusPagamento = "Viagem Paga";
    Firestore db = Firestore.instance;

    Map<String, dynamic> dadosAtualizar = {"statusPagamento": statusPagamento};

    db
        .collection("minhas_viagens")
        .document(_idUsuarioLogado)
        .collection("viagens")
        .document(_viagem.id)
        .updateData(dadosAtualizar)
        .then((_) {

      Navigator.pop(context);
    });
  }

  _recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();
    _idUsuarioLogado = usuarioLogado.uid;

    Firestore db = Firestore.instance;
    DocumentSnapshot snapshot = await db.collection("users")
        .document(_idUsuarioLogado)
        .get();

    Map<String, dynamic> dados = snapshot.data;

    return dados["typeUser"];

  }

  _initialize() async {
    _viagem = widget.viagem;
    print(_viagem.statusPagamento);
    _typeUser = await _recuperarDadosUsuario();
    print(_typeUser);
  }

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Viagem"),
      ),
      body: Stack(
        children: [
          ListView(
            children: [
              SizedBox(
                height: 250,
                child: Carousel(
                  images: _getListaImagens(),
                  dotSize: 8,
                  dotBgColor: Colors.transparent,
                  dotColor: Colors.white,
                  autoplay: false,
                  dotIncreasedColor: Colors.greenAccent,
                ),
              ),
              Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("R\$ ${_viagem.valor}",
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.green
                      ),
                    ),
                    Text("${_viagem.statusPagamento}",
                      style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: _viagem.statusPagamento == "Sem Pagamento" ? Colors.red : Colors.green
                      ),
                    ),
                    Text("${_viagem.empresa}",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text("${_viagem.cidade} - ${_viagem.estado}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(),
                    ),
                    Text("Data Partida",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text("${_viagem.dataPartida}",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(),
                    ),
                    Text("Data Chegada",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text("${_viagem.dataChegada}",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(),
                    ),
                    Text("Produto",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text("${_viagem.produto}",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(),
                    ),
                    Text("Peso",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text("${_viagem.peso}",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              if(_typeUser == "transportadora" && _viagem.statusPagamento == "Sem Pagamento")...[
                Container(
                  alignment: Alignment.center,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 0, 100, 0),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.all(12),
                          child: Center(
                            child: AutoSizeText(
                              "Receber Viagem",
                              maxLines: 2,
                              minFontSize: 10,
                              maxFontSize: 32,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22
                              ),
                            ),
                          ),
                        ),
                        onTap: () {
                          _receberViagem();
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10,)
              ]
            ],
          ),
        ],
      ),
    );
  }
}
