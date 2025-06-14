import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pwsi/service/auth_service.dart';
import 'package:pwsi/main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<StatefulWidget> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _enteredEmail = "";
  String _enteredPassword = "";
  final _key = GlobalKey<FormState>();
  
  void _submitForm(BuildContext context) async {
    if(!_key.currentState!.validate()) {
      return;
    }
    _key.currentState!.save();
    if (await AuthService.login(context, _enteredEmail, _enteredPassword)) {
      sendSnackBar(context, 'Pomyślnie zalogowano!');
      GoRouter.of(context).go('/book_list');
    }
    else {
      sendSnackBar(context, 'Logowanie nie powiodło się!');
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
                  return null;
                },
                onSaved: (value) {
                  _enteredPassword = value!;
                },
              ),
              SizedBox(height: 14,),
              ElevatedButton.icon(
                  onPressed: () => _submitForm(context),
                  label: Text('Zaloguj się!'),
                  icon: Icon(Icons.login),
              )
            ],
          ),
        ),
      ),
    );
  }
}
