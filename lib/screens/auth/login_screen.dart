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
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

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
              child: Form(
                key: _formKey,
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
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: appInput('Correo Electrónico', Icons.email),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El correo electrónico es obligatorio.';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Por favor, introduce un formato de correo electrónico válido (ej. nombre@dominio.com).';
                        }
                        return null;
                      },
                    ),
                    gap(12),
                    TextFormField(
                      controller: _passCtrl,
                      obscureText: true,
                      decoration: appInput('Contraseña', Icons.lock),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'La contraseña no puede estar vacía.';
                        }
                        if (value.length < 6) {
                          return 'La contraseña debe tener al menos 6 caracteres.';
                        }
                        return null;
                      },
                    ),
                    gap(16),
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        return Column(
                          children: [
                            // Mostrar mensaje de error si existe
                            if (authProvider.loginStatus == LoginStatus.failure && 
                                authProvider.errorMessage != null)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  border: Border.all(color: Colors.red.shade300),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.error_outline, color: Colors.red.shade700),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        authProvider.errorMessage!,
                                        style: TextStyle(color: Colors.red.shade700),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.close, color: Colors.red.shade700, size: 20),
                                      onPressed: () => authProvider.clearError(),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                              ),
                            FilledButton.icon(
                              onPressed: authProvider.loginStatus == LoginStatus.loading 
                                  ? null 
                                  : () async {
                                      if (_formKey.currentState!.validate()) {
                                        await authProvider.login(
                                          _emailCtrl.text.trim(), 
                                          _passCtrl.text
                                        );
                                        
                                        if (authProvider.loginStatus == LoginStatus.success) {
                                          if (context.mounted) {
                                            Navigator.pushReplacementNamed(context, AppRoutes.home);
                                          }
                                        } else if (authProvider.loginStatus == LoginStatus.failure) {
                                          // Mostrar SnackBar adicional para errores del sistema
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(authProvider.errorMessage ?? 'Error desconocido'),
                                                backgroundColor: Colors.red.shade600,
                                                duration: const Duration(seconds: 4),
                                                action: SnackBarAction(
                                                  label: 'Cerrar',
                                                  textColor: Colors.white,
                                                  onPressed: () => authProvider.clearError(),
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      }
                                    },
                              icon: authProvider.loginStatus == LoginStatus.loading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Icon(Icons.login),
                              label: Text(
                                authProvider.loginStatus == LoginStatus.loading 
                                    ? 'Iniciando sesión...' 
                                    : 'Iniciar Sesión'
                              ),
                            ),
                          ],
                        );
                      },
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
      ),
    );
  }
}
