import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pwsi/provider/auth_provider.dart';
import 'package:pwsi/service/auth_service.dart';
import 'package:pwsi/widgets/auth/auth_screen.dart';

import '../main.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Okno główne'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              final success = await AuthService.logout(context);
              if (success) {
                GoRouter.of(context).go('/auth');
                sendSnackBar(context, 'Pomyślnie wylogowano!');
              } else {
                sendSnackBar(context, 'Nie udało się wylogować!');
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Access token:\n${authProvider.accessToken ?? "Brak"}'),
            const SizedBox(height: 16),
            Text('Refresh token:\n${authProvider.refreshToken ?? "Brak"}'),
          ],
        ),
      ),
    );
  }
}
