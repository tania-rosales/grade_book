import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  // ═══════════════════════════════════════════════════════════════════
  // ESTADO
  // ═══════════════════════════════════════════════════════════════════

  final _supabase = Supabase.instance.client;

  // ─── Key del formulario ───
  // GlobalKey<FormState> permite validar TODOS los campos del formulario
  // con una sola llamada: _formKey.currentState!.validate()
  // Es como presionar "Revisar todo" antes de enviar.
  final _formKey = GlobalKey<FormState>();

  // ─── Controllers ───
  final _nombreController = TextEditingController();
  final _notaController = TextEditingController();

  // ─── Estado de carga ───
  bool _isLoading = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _notaController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════
  // MÉTODO: _guardarEstudiante() — CREATE
  // ═══════════════════════════════════════════════════════════════════
  //
  // 📚 ¿Qué hace paso a paso?
  //
  // 1. Valida el formulario (¿nombre vacío? ¿nota fuera de rango?)
  // 2. Activa el spinner
  // 3. Crea un Map con los datos del formulario
  // 4. Envía el Map a Supabase con .insert()
  //    → Supabase traduce esto a:
  //      INSERT INTO estudiantes (nombre, nota) VALUES ('María', 9.2)
  // 5. Si sale bien, regresa a la pantalla anterior con Navigator.pop(true)
  //    Ese true le dice a StudentsScreen: "sí se agregó, recarga la lista"

  Future<void> _guardarEstudiante() async {
    // ─── Paso 1: Validar formulario ───
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // ─── Paso 2: Insertar en Supabase ───
      // .from('estudiantes') → tabla destino
      // .insert({...})       → datos a insertar
      //
      // No enviamos 'id' ni 'created_at' porque
      // Supabase los genera automáticamente.
      await _supabase.from('estudiantes').insert({
        'nombre': _nombreController.text.trim(),
        'nota': double.parse(_notaController.text.trim()),
      });

      // ─── Paso 3: Volver a la pantalla anterior ───
      if (mounted) {
        // Mostramos confirmación
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Estudiante agregado correctamente'),
            backgroundColor: Colors.green,
          ),
        );

        // pop(true) → regresa Y le dice a la pantalla anterior
        // que sí se creó un registro nuevo.
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Estudiante'),
      ),
      // ─── Form ───
      // Form es un widget contenedor que agrupa campos con validación.
      // Al llamar _formKey.currentState!.validate(), Flutter ejecuta
      // la función validator de CADA TextFormField dentro del Form.
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── Ícono decorativo ───
              Icon(
                Icons.person_add_alt_1_rounded,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),

              // ─── Campo: Nombre ───
              // TextFormField es como TextField pero con validación integrada.
              // validator: función que recibe el texto y retorna:
              //   - null si es válido (no hay error)
              //   - un String con el mensaje de error si es inválido
              TextFormField(
                controller: _nombreController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nombre del estudiante',
                  hintText: 'Ej: María López',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El nombre es obligatorio';
                  }
                  return null; // válido
                },
              ),
              const SizedBox(height: 20),

              // ─── Campo: Nota ───
              TextFormField(
                controller: _notaController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Nota (0.0 - 10.0)',
                  hintText: 'Ej: 8.5',
                  prefixIcon: Icon(Icons.grade_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La nota es obligatoria';
                  }
                  final nota = double.tryParse(value.trim());
                  if (nota == null) {
                    return 'Ingresa un número válido';
                  }
                  if (nota < 0.0 || nota > 10.0) {
                    return 'La nota debe estar entre 0.0 y 10.0';
                  }
                  return null; // válido
                },
              ),
              const SizedBox(height: 32),

              // ─── Botón Guardar ───
              SizedBox(
                height: 48,
                child: FilledButton.icon(
                  onPressed: _isLoading ? null : _guardarEstudiante,
                  icon: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_rounded),
                  label: Text(
                    _isLoading ? 'Guardando...' : 'Guardar Estudiante',
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