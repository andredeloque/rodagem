import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RecoverPass extends StatefulWidget {
  @override
  _RecoverPassState createState() => _RecoverPassState();
}

class _RecoverPassState extends State<RecoverPass> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Esqueci a senha"),
        centerTitle: true,
      ),
      body: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          image: DecorationImage(
              fit: BoxFit.cover, image: AssetImage("imagens/imagem_fundo.jpg")),
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.fromLTRB(10, 200, 10, 5),
            children: <Widget>[
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                // ignore: missing_return
                validator: (text) {
                  if (text.isEmpty || !text.contains("@"))
                    return "E-mail inválido";
                },
                style: TextStyle(fontSize: 20),
                decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.email,
                      color: Theme.of(context).primaryColor,
                    ),
                    contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                    hintText: "e-mail",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    )),
              ),
              //ShapeBorder(),
              SizedBox(
                height: 20,
              ),

              SizedBox(
                height: 16.0,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: FlatButton(
                  onPressed: () {
                    if (_emailController.text.isEmpty)
                      _scaffoldKey.currentState.showSnackBar(
                        SnackBar(
                          content: Text("Insira seu email"),
                          backgroundColor: Colors.redAccent,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    else {
                      if (_formKey.currentState.validate()) {}
                      FirebaseAuth.instance
                          .sendPasswordResetEmail(email: _emailController.text);
                      _scaffoldKey.currentState.showSnackBar(
                        SnackBar(
                          content: Text(
                              "Confira o link de recuperação no seu e-mail"),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 3),
                        ),
                      );
                    }
                  },
                ),
              ),
              ButtonTheme(
                height: 45.0,
                child: RaisedButton(
                  onPressed: () {
                    if (_emailController.text.isEmpty)
                      _scaffoldKey.currentState.showSnackBar(
                        SnackBar(
                          content: Text("Insira seu email"),
                          backgroundColor: Colors.redAccent,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    else {
                      _scaffoldKey.currentState.showSnackBar(
                        SnackBar(
                          content: Text(
                              "Confira o link de recuperação no seu e-mail"),
                          backgroundColor: Theme.of(context).primaryColor,
                          duration: Duration(seconds: 3),
                        ),
                      );
                    }
                  },
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(30.0)),
                  child: Text(
                    "Recuperar senha",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ), //Text
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
