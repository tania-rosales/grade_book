// ============================================================================
// students_screen.dart - CRUD completo + logout real
// ============================================================================
//
// 📚 ¿Qué cambió?
// El botón de logout ahora llama a supabase.auth.signOut()
// que destruye la sesión en el servidor Y borra el token local.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/student.dart';
import 'add_student_screen.dart';
import 'edit_student_screen.dart';
import 'login_screen.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  final _supabase = Supabase.instance.client;
  List<Student> _estudiantes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarEstudiantes();
  }

  // ─── READ ───
  Future<void> _cargarEstudiantes() async {
    setState(() { _isLoading = true; });

    try {
      final data = await _supabase
          .from('estudiantes')
          .select()
          .order('created_at', ascending: false);

      setState(() {
        _estudiantes = (data as List)
            .map((json) => Student.fromJson(json))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() { _isLoading = false; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ─── CREATE ───
  Future<void> _navegarAAgregar() async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const AddStudentScreen()),
    );
    if (resultado == true) _cargarEstudiantes();
  }

  // ─── UPDATE ───
  Future<void> _navegarAEditar(Student estudiante) async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EditStudentScreen(estudiante: estudiante),
      ),
    );
    if (resultado == true) _cargarEstudiantes();
  }

  // ─── DELETE ───
  Future<void> _eliminarEstudiante(Student estudiante) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar estudiante'),
        content: Text(
          '¿Estás seguro de eliminar a ${estudiante.nombre}?\n\nEsta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      await _supabase
          .from('estudiantes')
          .delete()
          .eq('id', estudiante.id!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${estudiante.nombre} eliminado'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      _cargarEstudiantes();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // MÉTODO: _handleLogout() — Logout REAL
  // ═══════════════════════════════════════════════════════════════════
  //
  // 📚 ¿Qué hace?
  // 1. Llama a supabase.auth.signOut()
  //    → Supabase invalida el token en el servidor
  //    → Borra el token guardado en el dispositivo
  // 2. Navega al LoginScreen con pushReplacement
  //    → El usuario no puede volver con el botón "atrás"
  //
  // La próxima vez que abra la app, main.dart detectará
  // que no hay sesión y mostrará el login.

  Future<void> _handleLogout() async {
    await _supabase.auth.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  Color _getColorForNota(double nota) {
    if (nota >= 9.0) return Colors.green.shade700;
    if (nota >= 7.0) return Colors.blue.shade700;
    if (nota >= 6.0) return Colors.orange.shade700;
    return Colors.red.shade700;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GradeBook'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Recargar',
            onPressed: _cargarEstudiantes,
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Cerrar Sesión',
            // ─── CAMBIO: Ahora cierra sesión de verdad ───
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mis Estudiantes',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('${_estudiantes.length} estudiantes registrados',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _estudiantes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.school_outlined, size: 64,
                              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                            const SizedBox(height: 16),
                            Text('No hay estudiantes aún',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant)),
                            const SizedBox(height: 8),
                            Text('Presiona + para agregar el primero',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7))),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _estudiantes.length,
                        itemBuilder: (context, index) {
                          final est = _estudiantes[index];
                          final color = _getColorForNota(est.nota);

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              contentPadding: const EdgeInsets.only(
                                left: 16, top: 4, bottom: 4, right: 8),
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                child: Text(
                                  est.nombre[0].toUpperCase(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onPrimaryContainer),
                                ),
                              ),
                              title: Text(est.nombre,
                                style: const TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: Text(est.estadoNota,
                                style: TextStyle(color: color)),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(20)),
                                    child: Text(est.notaFormateada,
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined, size: 20),
                                    tooltip: 'Editar',
                                    color: Theme.of(context).colorScheme.primary,
                                    onPressed: () => _navegarAEditar(est),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, size: 20),
                                    tooltip: 'Eliminar',
                                    color: Colors.red,
                                    onPressed: () => _eliminarEstudiante(est),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navegarAAgregar,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Agregar'),
      ),
    );
  }
}
