import 'package:flutter/material.dart';
import 'package:grade_book_tania/screens/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/student.dart';
import 'add_student_screen.dart';


class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  // ═══════════════════════════════════════════════════════════════════
  // ESTADO
  // ═══════════════════════════════════════════════════════════════════

  // ─── Referencia al cliente de Supabase ───
  final _supabase = Supabase.instance.client;

  // ─── Lista de estudiantes (empieza vacía, se llena desde Supabase) ───
  List<Student> _estudiantes = [];

  // ─── Estado de carga ───
  bool _isLoading = true;

  // ═══════════════════════════════════════════════════════════════════
  // CICLO DE VIDA: initState()
  // ═══════════════════════════════════════════════════════════════════
  //
  // 📚 initState() se ejecuta UNA VEZ cuando la pantalla se crea.
  // Es el momento perfecto para cargar los datos iniciales.
  //
  // Analogía: Es como cuando abres una app y ves un spinner de carga
  // por un momento — eso es initState() llamando a _cargarEstudiantes().

  @override
  void initState() {
    super.initState();
    _cargarEstudiantes();
  }

  // ═══════════════════════════════════════════════════════════════════
  // MÉTODO: _cargarEstudiantes() — READ
  // ═══════════════════════════════════════════════════════════════════
  //
  // 📚 ¿Qué hace este método paso a paso?
  //
  // 1. Activa el spinner de carga
  // 2. Le pide a Supabase: "dame todas las filas de la tabla estudiantes"
  //    → Supabase traduce esto a: SELECT * FROM estudiantes ORDER BY created_at
  // 3. Supabase responde con una lista de Maps (JSON)
  // 4. Convertimos cada Map a un objeto Student con fromJson()
  // 5. Guardamos la lista y desactivamos el spinner
  //
  // .from('estudiantes') → indica la tabla
  // .select()            → trae todas las columnas (equivale a SELECT *)
  // .order(...)          → ordena los resultados

  Future<void> _cargarEstudiantes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // ─── Consultar Supabase ───
      // Esto es equivalente a:
      //   SELECT * FROM estudiantes ORDER BY created_at DESC
      final data = await _supabase
          .from('estudiantes')
          .select()
          .order('created_at', ascending: false);

      // ─── Convertir JSON → objetos Student ───
      // data es una List<Map<String, dynamic>>
      // .map() recorre cada Map y lo convierte con fromJson()
      // .toList() lo convierte de Iterable a List
      setState(() {
        _estudiantes = (data as List)
            .map((json) => Student.fromJson(json))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      // Si hay error (sin internet, tabla no existe, etc.)
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // MÉTODO: _navegarAAgregar() — Abre la pantalla de CREATE
  // ═══════════════════════════════════════════════════════════════════
  //
  // 📚 Usamos Navigator.push (no pushReplacement) porque QUEREMOS
  // volver a esta pantalla después de agregar un estudiante.
  //
  // .then((resultado) => ...) se ejecuta CUANDO el usuario regresa.
  // Si resultado es true, significa que sí agregó un estudiante,
  // entonces recargamos la lista para mostrar el nuevo dato.

  Future<void> _navegarAAgregar() async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const AddStudentScreen()),
    );

    // Si regresó con true → recargar la lista
    if (resultado == true) {
      _cargarEstudiantes();
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // HELPER: Color según la nota
  // ═══════════════════════════════════════════════════════════════════
  Color _getColorForNota(double nota) {
    if (nota >= 9.0) return Colors.green.shade700;
    if (nota >= 7.0) return Colors.blue.shade700;
    if (nota >= 6.0) return Colors.orange.shade700;
    return Colors.red.shade700;
  }

  // ═══════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════
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
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Encabezado ───
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mis Estudiantes',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_estudiantes.length} estudiantes registrados',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // ─── Contenido principal ───
          // Tres estados posibles:
          // 1. Cargando → mostrar spinner
          // 2. Lista vacía → mostrar mensaje
          // 3. Con datos → mostrar la lista
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _estudiantes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.school_outlined,
                              size: 64,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant
                                  .withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No hay estudiantes aún',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Presiona + para agregar el primero',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant
                                        .withValues(alpha: 0.7),
                                  ),
                            ),
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
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                child: Text(
                                  est.nombre[0].toUpperCase(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                  ),
                                ),
                              ),
                              title: Text(
                                est.nombre,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                est.estadoNota,
                                style: TextStyle(color: color),
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  est.notaFormateada,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: color,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),

      // ─── FAB: Agregar estudiante ───
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navegarAAgregar,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Agregar'),
      ),
    );
  }
}