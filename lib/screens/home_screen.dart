import 'package:flutter/material.dart';
import 'package:grade_book_tania/model/student.dart';
import 'package:grade_book_tania/screens/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Student> _estudiantes = [
    Student(id: '1', nombre: 'María López', nota: 9.2),
    Student(id: '2', nombre: 'Carlos Hernández', nota: 7.5),
    Student(id: '3', nombre: 'Ana Martínez', nota: 5.8),
    Student(id: '4', nombre: 'José Rivera', nota: 8.1),
    Student(id: '5', nombre: 'Cristian Portillo', nota: 6.1),
  ];

  void _handleLogout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }
  //Función helper o ayudadora para manejar los estados 
  Color _getColorForNota(double nota) {
    if (nota >= 9.0) return Colors.green.shade700;
    if (nota >= 7.0) return Colors.blue.shade700;
    if (nota >= 6.0) return Colors.orange.shade700;
    return Colors.red.shade700;
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: const Text('Grade Book Tania'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Cerrar Sesión',
            onPressed: _handleLogout,
          )
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.analytics_outlined,
                      color: Theme.of(context).colorScheme.primary,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Promedio General',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          
                          (_estudiantes.fold<double>(
                                    0.0,
                                    (suma, est) => suma + est.nota,
                                  ) /
                                  _estudiantes.length)
                              .toStringAsFixed(1),
                          style:
                              Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _estudiantes.length,
              itemBuilder: (context, index) {
                final estudiante = _estudiantes[index];
                return _StudentCard(
                  estudiante: estudiante,
                  colorNota: _getColorForNota(estudiante.nota),
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Próximamente: Agregar estudiante (Clase 3)'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Agregar'),
      ),
    );
  }
}


class _StudentCard extends StatelessWidget {
  final Student estudiante;
  final Color colorNota;

  const _StudentCard({
    required this.estudiante,
    required this.colorNota,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

        
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            estudiante.nombre[0], // Primera letra del nombre
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ),

        // ─── Nombre del estudiante ───
        title: Text(
          estudiante.nombre,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),

        // estado de la nota (usa el getter del modelo)
        subtitle: Text(
          estudiante.estadoNota,
          style: TextStyle(color: colorNota),
        ),

        // trailing es el widget al final (derecha) del ListTile.
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: colorNota.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            estudiante.notaFormateada,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorNota,
            ),
          ),
        ),
      ),
    );
  }
}
