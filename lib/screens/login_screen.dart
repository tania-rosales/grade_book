// ============================================================================
// login_screen.dart - Login y Registro REAL con Supabase Auth
// ============================================================================
//
// 📚 ¿Qué cambió respecto al login simulado?
//
// ANTES: Future.delayed(2 segundos) → navegaba sin verificar nada.
// AHORA: supabase.auth.signInWithPassword() → verifica email + password
//        contra la base de datos de Supabase Auth.
//
// Si las credenciales son correctas, Supabase retorna un JWT token
// y Flutter guarda la sesión automáticamente.
// Si son incorrectas, Supabase lanza una excepción con el mensaje de error.
//
// También agregamos un modo REGISTRO (signUp) para que cada docente
// pueda crear su propia cuenta desde la app.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'students_screen_bk2.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _supabase = Supabase.instance.client;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  // ─── Modo: Login o Registro ───
  // Con esta variable alternamos entre los dos modos
  // sin necesidad de crear otra pantalla.
  bool _isRegistro = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════
  // MÉTODO: _handleAuth() — Login o Registro real
  // ═══════════════════════════════════════════════════════════════════
  //
  // 📚 ¿Qué hace?
  //
  // Si _isRegistro es false → signInWithPassword (LOGIN)
  //   Supabase busca el email en auth.users.
  //   Si existe y el password coincide → retorna sesión.
  //   Si no → lanza AuthException con mensaje descriptivo.
  //
  // Si _isRegistro es true → signUp (REGISTRO)
  //   Supabase crea un nuevo usuario en auth.users.
  //   Si el email ya existe → lanza error.
  //   Si no → crea el usuario y retorna sesión.

  Future<void> _handleAuth() async {
    // Validación básica
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa email y contraseña'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La contraseña debe tener al menos 6 caracteres'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() { _isLoading = true; });

    try {
      if (_isRegistro) {
        // ─── REGISTRO ───
        // signUp crea un nuevo usuario en Supabase Auth.
        await _supabase.auth.signUp(
          email: email,
          password: password,
        );
      } else {
        // ─── LOGIN ───
        // signInWithPassword verifica credenciales existentes.
        await _supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );
      }

      // Si llegó aquí sin error → éxito
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const StudentsScreen()),
        );
      }
    } on AuthException catch (e) {
      // ─── Error de Supabase Auth ───
      // AuthException tiene un .message descriptivo:
      // "Invalid login credentials", "User already registered", etc.
      setState(() { _isLoading = false; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // ─── Otro error (sin internet, etc.) ───
      setState(() { _isLoading = false; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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

                  // ─── Campo: Email ───
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Correo electrónico',
                      hintText: 'usuario@ejemplo.com',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ─── Campo: Contraseña ───
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _isLoading ? null : _handleAuth(),
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
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ─── Botón principal: Login o Registro ───
                  SizedBox(
                    width: double.infinity, height: 48,
                    child: FilledButton(
                      onPressed: _isLoading ? null : _handleAuth,
                      child: _isLoading
                        ? const SizedBox(height: 24, width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.white))
                        : Text(
                            _isRegistro ? 'Crear Cuenta' : 'Iniciar Sesión',
                            style: const TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ─── Alternar entre Login y Registro ───
                  TextButton(
                    onPressed: () {
                      setState(() { _isRegistro = !_isRegistro; });
                    },
                    child: Text(
                      _isRegistro
                        ? '¿Ya tienes cuenta? Inicia Sesión'
                        : '¿No tienes cuenta? Regístrate',
                    ),
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
