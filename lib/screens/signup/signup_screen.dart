import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rodagem/helpers/validators.dart';
import 'package:rodagem/models/user.dart';
import 'package:rodagem/models/user_manager.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final User user = User();

  bool _typeUser = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text('Cadastro'),
        centerTitle: true,
      ),
      body: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage("imagens/imagem_fundo.jpg")
          ),
        ),
        child: Center(
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Form(
              key: formKey,
              child: Consumer<UserManager>(
                builder: (_, userManager, __) {
                  return ListView(
                    padding: const EdgeInsets.all(16),
                    shrinkWrap: true,
                    children: <Widget>[
                      TextFormField(
                        decoration:
                        const InputDecoration(hintText: 'Nome Completo'),
                        enabled: !userManager.loading,
                        validator: (name) {
                          if (name.isEmpty)
                            return 'Campo obrigatório';
                          else if (name.trim().split(' ').length <= 1)
                            return 'Preencha seu Nome completo';
                          return null;
                        },
                        onSaved: (name) => user.name = name,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(hintText: 'E-mail'),
                        keyboardType: TextInputType.emailAddress,
                        enabled: !userManager.loading,
                        validator: (email) {
                          if (email.isEmpty)
                            return 'Campo obrigatório';
                          else if (!emailValid(email)) return 'E-mail inválido';
                          return null;
                        },
                        onSaved: (email) => user.email = email,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(hintText: 'Senha'),
                        obscureText: true,
                        enabled: !userManager.loading,
                        validator: (pass) {
                          if (pass.isEmpty)
                            return 'Campo obrigatório';
                          else if (pass.length < 6) return 'Senha muito curta';
                          return null;
                        },
                        onSaved: (pass) => user.password = pass,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      TextFormField(
                        decoration:
                        const InputDecoration(hintText: 'Repita a Senha'),
                        obscureText: true,
                        enabled: !userManager.loading,
                        validator: (pass) {
                          if (pass.isEmpty)
                            return 'Campo obrigatório';
                          else if (pass.length < 6) return 'Senha muito curta';
                          return null;
                        },
                        onSaved: (pass) => user.confirmPassword = pass,
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Text("Transportadora"),
                            Switch(
                                value: _typeUser,
                                onChanged: (bool value) {
                                  setState(() {
                                    _typeUser = value;
                                  });
                                }
                            ),
                            Text("Motorista"),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      SizedBox(
                        height: 44,
                        child: RaisedButton(
                          color: Theme.of(context).primaryColor,
                          disabledColor:
                          Theme.of(context).primaryColor.withAlpha(100),
                          textColor: Colors.white,
                          onPressed: userManager.loading
                              ? null
                              : () {
                            if (formKey.currentState.validate()) {
                              formKey.currentState.save();

                              if (user.password != user.confirmPassword) {
                                scaffoldKey.currentState
                                    .showSnackBar(SnackBar(
                                      content: const Text('Senhas não coincidem!'),
                                      backgroundColor: Colors.red,
                                      ));
                                return;
                              }

                              user.typeUser = user.checkTypeUser(_typeUser);

                              userManager.signUp(
                                  user: user,
                                  onSuccess: () {
                                    Navigator.of(context).pushReplacementNamed('/base');
                                  },
                                  onFail: (e) {
                                    scaffoldKey.currentState
                                        .showSnackBar(
                                        SnackBar(
                                          content: Text('Falha ao cadastrar: $e'),
                                      backgroundColor: Colors.red,
                                    ));
                                  });
                            }
                          },
                          child: userManager.loading
                              ? CircularProgressIndicator(
                            valueColor:
                            AlwaysStoppedAnimation(Colors.white),
                          )
                              : const Text(
                            'Cadastrar',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
