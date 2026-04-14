// ============================================================================
// edit_student_screen.dart - Formulario para editar estudiante (UPDATE)
// ============================================================================
//
// 📚 CONCEPTO CLAVE:
// Esta pantalla es casi idéntica a AddStudentScreen, con DOS diferencias:
// 1. Recibe un Student existente por constructor (para prellenar los campos)
// 2. En vez de .insert() usa .update().eq('id', ...) para modificar la fila
//
// Supabase traduce .update().eq() a:
//   UPDATE estudiantes SET nombre='...', nota=... WHERE id = 5
// ============================================================================

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/student.dart';

class EditStudentScreen extends StatefulWidget {
  // ─── Recibe el estudiante a editar ───
  // Lo necesitamos para prellenar los campos con los datos actuales.
  final Student estudiante;

  const EditStudentScreen({super.key, required this.estudiante});

  @override
  State<EditStudentScreen> createState() => _EditStudentScreenState();
}

class _EditStudentScreenState extends State<EditStudentScreen> {
  final _supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreController;
  late final TextEditingController _notaController;
  bool _isLoading = false;

  // ─── initState: Prellenar los campos ───
  // 'late' significa que se inicializa aquí, no en la declaración.
  // widget.estudiante accede al Student que nos pasaron por constructor.
  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.estudiante.nombre);
    _notaController = TextEditingController(text: widget.estudiante.notaFormateada);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _notaController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════
  // MÉTODO: _actualizarEstudiante() — UPDATE
  // ═══════════════════════════════════════════════════════════════════
  //
  // 📚 ¿Qué hace?
  // 1. Valida el formulario
  // 2. Envía los datos nuevos a Supabase con .update()
  // 3. .eq('id', ...) le dice a Supabase CUÁL fila actualizar
  //
  // Equivale a:
  //   UPDATE estudiantes
  //   SET nombre = 'María López', nota = 9.5
  //   WHERE id = 5

  Future<void> _actualizarEstudiante() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() { _isLoading = true; });

    try {
      await _supabase.from('estudiantes').update({
        'nombre': _nombreController.text.trim(),
        'nota': double.parse(_notaController.text.trim()),
      }).eq('id', widget.estudiante.id!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Estudiante actualizado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() { _isLoading = false; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Estudiante'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.edit_rounded,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _nombreController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nombre del estudiante',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El nombre es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _notaController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Nota (0.0 - 10.0)',
                  prefixIcon: Icon(Icons.grade_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La nota es obligatoria';
                  }
                  final nota = double.tryParse(value.trim());
                  if (nota == null) return 'Ingresa un número válido';
                  if (nota < 0.0 || nota > 10.0) {
                    return 'La nota debe estar entre 0.0 y 10.0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              SizedBox(
                height: 48,
                child: FilledButton.icon(
                  onPressed: _isLoading ? null : _actualizarEstudiante,
                  icon: _isLoading
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_rounded),
                  label: Text(
                    _isLoading ? 'Guardando...' : 'Guardar Cambios',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}