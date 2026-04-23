// ============================================================================
// main.dart - Con detección de sesión activa
// ============================================================================
//
// 📚 ¿Qué cambió?
//
// Ahora verificamos si el usuario YA tiene una sesión activa.
// Si sí → va directo a StudentsScreen (no tiene que loguearse otra vez).
// Si no → va a LoginScreen.
//
// Analogía: Es como cuando abres WhatsApp — no te pide login cada vez
// porque recuerda que ya te logueaste antes. Supabase hace lo mismo:
// guarda el token en el dispositivo y lo restaura al abrir la app.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';
import 'screens/login_screen_bk2.dart';
import 'screens/students_screen_bk2.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  runApp(const GradeBookApp());
}

class GradeBookApp extends StatelessWidget {
  const GradeBookApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ─── Verificar si hay sesión activa ───
    // currentSession retorna la sesión guardada, o null si no hay.
    final session = Supabase.instance.client.auth.currentSession;

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
      // Si hay sesión → StudentsScreen, si no → LoginScreen
      home: session != null ? const StudentsScreen() : const LoginScreen(),
    );
  }
}
