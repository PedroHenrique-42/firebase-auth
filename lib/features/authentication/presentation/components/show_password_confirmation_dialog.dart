import 'package:flutter/material.dart';
import 'package:flutter_firebase_firestore_second/features/authentication/services/auth_service.dart';

void showPasswordConfirmationDialog({
  required BuildContext context,
  required String email,
}) {
  showDialog(
      context: context,
      builder: (context) {
        TextEditingController passwordConfirmationController =
            TextEditingController();

        return AlertDialog(
          title: Text("Deseja remover a conta com o e-mail $email?"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Para confirmar a remoção da conta, insira sua senha:",
              ),
              TextFormField(
                controller: passwordConfirmationController,
                obscureText: true,
                decoration: const InputDecoration(label: Text("Senha")),
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await AuthService()
                    .removeAccount(
                        password: passwordConfirmationController.text)
                    .then((value) {
                  if (value == null) {
                    Navigator.pop(context);
                  }
                });
              },
              child: const Text("EXCLUIR CONTA"),
            )
          ],
        );
      });
}
