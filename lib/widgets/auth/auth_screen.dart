import 'package:flutter/material.dart';
import 'package:pwsi/widgets/auth/login.dart';

import 'register.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<StatefulWidget> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          if (_isLogin) LoginScreen(),
          if (!_isLogin) RegisterScreen(),
          SizedBox(height: 20),
          TextButton(
            onPressed: () {
              setState(() {
                _isLogin = !_isLogin;
              });
            },
            child: Text(
              _isLogin ? 'Chcę utworzyć nowe konto' : 'Mam już konto',
            ),
          ),
        ],
      ),
    );
  }
}
