// ============================================================================
// login_screen.dart - Login simulado (igual que Clase 1)
// ============================================================================
//
// 📚 Este archivo es CASI IDÉNTICO al de Clase 1.
// El único cambio: ahora navega a StudentsScreen (datos reales de Supabase)
// en vez de HomeScreen (datos hardcodeados).
//
// El login sigue siendo simulado con Future.delayed.
// En una clase futura se reemplazará por supabase.auth.signInWithPassword().
// ============================================================================

import 'package:flutter/material.dart';
import 'students_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() { _isLoading = true; });
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() { _isLoading = false; });

    // ─── CAMBIO: Ahora navega a StudentsScreen ───
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const StudentsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.school_rounded, size: 80,
                    color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 16),
                  Text('GradeBook',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary)),
                  const SizedBox(height: 8),
                  Text('Gestión de Estudiantes y Notas',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 48),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Correo electrónico',
                      hintText: 'usuario@ejemplo.com',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder())),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _isLoading ? null : _handleLogin(),
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                        onPressed: () {
                          setState(() { _obscurePassword = !_obscurePassword; });
                        }))),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity, height: 48,
                    child: FilledButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      child: _isLoading
                        ? const SizedBox(height: 24, width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.white))
                        : const Text('Iniciar Sesión',
                            style: TextStyle(fontSize: 16)))),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}