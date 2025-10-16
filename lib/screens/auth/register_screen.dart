import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/ui.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _user = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    const Icon(Icons.store_mall_directory, size: 56, color: Colors.blue),
                    gap(8),
                    const Text('Registro de Administrador',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    gap(16),
                    TextFormField(
                      decoration: appInput('Nombre de la Tienda', Icons.storefront),
                      controller: _name,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese el nombre de la tienda';
                        }
                        return null;
                      },
                    ),
                    gap(12),
                    TextFormField(
                      decoration: appInput('Usuario', Icons.person),
                      controller: _user,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese un usuario';
                        }
                        return null;
                      },
                    ),
                    gap(12),
                    TextFormField(
                      decoration: appInput('Email', Icons.email),
                      controller: _email,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese un email';
                        }
                        return null;
                      },
                    ),
                    gap(12),
                    TextFormField(
                      decoration: appInput('Contraseña', Icons.lock),
                      controller: _pass,
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese una contraseña';
                        }
                        return null;
                      },
                    ),
                    gap(16),
                    FilledButton.icon(
                      onPressed: _busy
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() => _busy = true);
                                final err = await context.read<AuthProvider>().register(
                                  fullName: _name.text.trim(),
                                  username: _user.text.trim(),
                                  email: _email.text.trim(),
                                  password: _pass.text,
                                );
                                setState(() => _busy = false);
                                if (err != null) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(content: Text(err)));
                                } else {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Registro exitoso')));
                                    Navigator.pushReplacementNamed(context, AppRoutes.login);
                                  }
                                }
                              }
                            },
                      icon: const Icon(Icons.person_add),
                      label: const Text('Registrarse'),
                    ),
                    gap(8),
                    TextButton(
                      onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
                      child: const Text('¿Ya tienes cuenta? Inicia sesión'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}