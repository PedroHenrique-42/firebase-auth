import 'package:flutter/material.dart';
import 'package:flutter_firebase_firestore_second/_core/my_colors.dart';
import 'package:flutter_firebase_firestore_second/features/authentication/presentation/components/show_snackbar.dart';
import 'package:flutter_firebase_firestore_second/features/authentication/services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _confirmaController = TextEditingController();
  final TextEditingController _nomeController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isEntrando = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 32,
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.all(32),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.network(
                      "https://github.com/ricarthlima/listin_assetws/raw/main/logo-icon.png",
                      height: 64,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        (_isEntrando)
                            ? "Bem vindo ao Listin!"
                            : "Vamos começar?",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      (_isEntrando)
                          ? "Faça login para criar sua lista de compras."
                          : "Faça seu cadastro para começar a criar sua lista de compras com Listin.",
                      textAlign: TextAlign.center,
                    ),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(label: Text("E-mail")),
                      validator: (value) {
                        if (value == null || value == "") {
                          return "O valor de e-mail deve ser preenchido";
                        }
                        if (!value.contains("@") ||
                            !value.contains(".") ||
                            value.length < 4) {
                          return "O valor do e-mail deve ser válido";
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _senhaController,
                      obscureText: true,
                      decoration: const InputDecoration(label: Text("Senha")),
                      validator: (value) {
                        if (value == null || value.length < 4) {
                          return "Insira uma senha válida.";
                        }
                        return null;
                      },
                    ),
                    Visibility(
                      visible: _isEntrando,
                      child: TextButton(
                        onPressed: () {
                          _whenForgotPassword();
                        },
                        child: const Text(
                          "Esqueci minha senha",
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Visibility(
                          visible: !_isEntrando,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _confirmaController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  label: Text("Confirme a senha"),
                                ),
                                validator: (value) {
                                  if (value == null || value.length < 4) {
                                    return "Insira uma confirmação de senha válida.";
                                  }
                                  if (value != _senhaController.text) {
                                    return "As senhas devem ser iguais.";
                                  }
                                  return null;
                                },
                              ),
                              TextFormField(
                                controller: _nomeController,
                                decoration: const InputDecoration(
                                  label: Text("Nome"),
                                ),
                                validator: (value) {
                                  if (value == null || value.length < 3) {
                                    return "Insira um nome maior.";
                                  }
                                  return null;
                                },
                              ),
                            ],
                          )),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        _verifyButtonClickAction();
                      },
                      child: Text(
                        (_isEntrando) ? "Entrar" : "Cadastrar",
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isEntrando = !_isEntrando;
                        });
                      },
                      child: Text(
                        (_isEntrando)
                            ? "Ainda não tem conta?\nClique aqui para cadastrar."
                            : "Já tem uma conta?\nClique aqui para entrar",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: MyColors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _verifyButtonClickAction() {
    String email = _emailController.text;
    String senha = _senhaController.text;
    String nome = _nomeController.text;

    if (_formKey.currentState!.validate()) {
      if (_isEntrando) {
        _whenLogin(email: email, senha: senha);
      } else {
        _whenRegister(email: email, senha: senha, nome: nome);
      }
    }
  }

  void _whenLogin({
    required String email,
    required String senha,
  }) {
    _authService.loginUser(email: email, password: senha).then(
      (String? error) {
        if (error != null) {
          showSnackBar(context, message: error);
          return;
        }


      },
    );
  }

  void _whenRegister({
    required String email,
    required String senha,
    required String nome,
  }) {
    _authService.registerUser(email: email, password: senha, name: nome).then(
      (String? error) {
        if (error != null) {
          showSnackBar(context, message: error);
        }
        
      },
    );
  }

  void _whenForgotPassword() {
    String email = _emailController.text;

    showDialog(
      context: context,
      builder: (context) {
        TextEditingController forgotPasswordController =
            TextEditingController(text: email);

        return AlertDialog(
          title: const Text("Confirme o e-mail para redefinição de senha."),
          content: TextFormField(
            controller: forgotPasswordController,
            decoration: const InputDecoration(label: Text("Confirme o e-mail")),
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(32)),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  _authService
                      .resetPassword(email: forgotPasswordController.text)
                      .then((String? error) {
                    if (error == null) {
                      Navigator.pop(context);
                      showSnackBar(
                        context,
                        isError: false,
                        message: "E-mail de redefinição enviado!",
                      );
                      return;
                    }

                    Navigator.pop(context);
                    showSnackBar(context, message: error);
                  });
                },
                child: const Text("Redefinir senha")),
          ],
        );
      },
    );
  }
}
