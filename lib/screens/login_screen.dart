import 'package:flutter/material.dart';
import 'package:grade_book_tania/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //Variables para manejar el ingreso de usuario y clave
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  //La función dispose nos permite "destruir" las pantallas y liberar la memoria que están ocupando mis variables declaradas
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // Activar el estado de carga
    //setState()
    setState(() {
      _isLoading = true;
    });

    //Simular la conexion al servidor
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    //desactivar el estado de carga o spinner de carga
    setState(() {
      _isLoading = false;
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
              Theme.of(context).colorScheme.surface
            ]),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.school_rounded,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16,),

                  Text(
                    'Grade Book',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16,),

                  Text(
                    'Gestión de Estudiantes y Notas',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 48),
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

                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _isLoading ? null : _handleLogin(),//Permite iniciar sesión pulsando la tecla enter
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          // Evaluamos el estado de la variable _obscurePassword mediante un operador ternario
                          //// para decidir qué ícono mostrar en pantalla.
                          _obscurePassword
                            // El símbolo '?' actúa como la condición 'if'. 
                            // Si la contraseña está oculta (true), mostramos el ícono de ojo abierto.
                              ? Icons.visibility_outlined 
                              // Los dos puntos ':' representan el 'else'. 
                              // Si la contraseña ya es visible (false), cambiamos al ícono de ojo tachado.
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            // Actualizamos la interfaz invirtiendo el valor lógico de nuestra variable.
                            // Esto crea el efecto de "interruptor" para mostrar u ocultar el texto.
                            _obscurePassword = !_obscurePassword; 
                          });
                        },
                      ),
                  ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          )
          ),
      ),
    );
  }
}
