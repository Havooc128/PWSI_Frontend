import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pwsi/service/auth_service.dart';
import 'package:pwsi/main.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<StatefulWidget> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String _enteredEmail = "";
  String _enteredPassword = "";
  String _enteredPasswordConfirmation = "";
  String _enteredUsername = "";
  final _key = GlobalKey<FormState>();

  void _submitForm(BuildContext context) async {
    if(!_key.currentState!.validate()) {
      return;
    }
    _key.currentState!.save();
    if (await AuthService.register(context, _enteredEmail, _enteredUsername, _enteredPassword, _enteredPasswordConfirmation)) {
      sendSnackBar(context, 'Pomyślnie zarejestrowano!');
      GoRouter.of(context).go('/main');
    }
    else {
      sendSnackBar(context, 'Rejestracja nie powiodła się!');
    }

  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 50),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Form(
          key: _key,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Nazwa użytkownika'),
                autocorrect: false,
                validator: (value) {
                  if (value == null || value.isEmpty || value.length < 5) {
                    return 'Nazwa użytkownika jest za krótka';
                  }
                  return null;
                },
                onSaved: (value) {
                  _enteredUsername = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Adres email'),
                autocorrect: false,
                validator: (value) {
                  if (value == null || value.isEmpty || value.length < 5 || !value.contains('@') || !value.contains('.')) {
                    return 'Nieprawidłowy adres email';
                  }
                  return null;
                },
                onSaved: (value) {
                  _enteredEmail = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Hasło'),
                obscureText: true,
                autocorrect: false,
                validator: (value) {
                  if (value == null || value.isEmpty || value.length < 8) {
                    return 'Hasło musi mieć co najmniej 8 znaków';
                  }
                  _enteredPassword = value;
                  return null;
                },
                onSaved: (value) {
                  _enteredPassword = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Powtórz hasło'),
                obscureText: true,
                autocorrect: false,
                validator: (value) {
                  if (value == null || value != _enteredPassword) {
                    return 'Wprowadzone hasła różnią się';
                  }
                  return null;
                },
                onSaved: (value) {
                  _enteredPasswordConfirmation = value!;
                },
              ),
              SizedBox(height: 14,),
              ElevatedButton.icon(
                onPressed: () => _submitForm(context),
                label: Text('Zarejestruj się!'),
                icon: Icon(Icons.login),
              )
            ],
          ),
        ),
      ),
    );
  }
}
