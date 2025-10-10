import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/ui.dart';
import 'package:lottie/lottie.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Lottie.asset('assets/login_animation.json'),
                  gap(8),
                  const Text('TienditaMejorada',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                  const Text('Sistema de Inventario y Ventas',
                      textAlign: TextAlign.center),
                  gap(24),
                  const Text('Iniciar Sesión',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  gap(16),
                  TextField(
                    controller: _userCtrl,
                    decoration: appInput('Usuario', Icons.person),
                  ),
                  gap(12),
                  TextField(
                    controller: _passCtrl,
                    obscureText: true,
                    decoration: appInput('Contraseña', Icons.lock),
                  ),
                  gap(16),
                  FilledButton.icon(
                    onPressed: _busy ? null : () async {
                      setState(() => _busy = true);
                      final err = await context.read<AuthProvider>()
                          .login(_userCtrl.text.trim(), _passCtrl.text);
                      setState(() => _busy = false);
                      if (err != null) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text(err)));
                      } else {
                        if (context.mounted) {
                          Navigator.pushReplacementNamed(context, AppRoutes.home);
                        }
                      }
                    },
                    icon: const Icon(Icons.login),
                    label: const Text('Iniciar Sesión'),
                  ),
                  gap(12),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.register),
                    child: const Text('¿No tienes cuenta? Regístrate aquí'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
