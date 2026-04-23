import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';
import 'screens/login_screen_bk2.dart';

Future<void> main() async {
  // ─── Paso 1: Inicializar el binding de Flutter ───
  // Obligatorio cuando main() es async.
  // Le dice a Flutter: "prepárate, voy a hacer cosas async
  // antes de mostrarte la primera pantalla."
  WidgetsFlutterBinding.ensureInitialized();

  // ─── Paso 2: Conectar con Supabase ───
  // Usa las credenciales del archivo de configuración.
  // await = esperamos a que la conexión se establezca.
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  // ─── Paso 3: Arrancar la app  ───
  runApp(const GradeBookApp());
}

class GradeBookApp extends StatelessWidget {
  const GradeBookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GradeBook',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}