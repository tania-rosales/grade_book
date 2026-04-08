class Student {
  // ─── Propiedades ───
  // id ahora es int (INT8 en Supabase) en vez de String
  // Lo hacemos nullable (int?) porque al CREAR un estudiante nuevo
  // todavía no tiene id — Supabase lo genera automáticamente.
  final int? id;
  final String nombre;
  final double nota;

  Student({
    this.id,
    required this.nombre,
    required this.nota,
  });

  // ─── fromJson: Convierte un Map (JSON) a un objeto Student ───
  // Se usa cuando LEEMOS datos de Supabase.
  //
  // Supabase nos devuelve algo como:
  //   { "id": 5, "nombre": "María López", "nota": 9.2, "created_at": "..." }
  //
  // factory: Es un constructor especial que puede retornar
  // una instancia existente o crear una nueva con lógica personalizada.
  //
  // json['nota'] viene como num (puede ser int o double).
  // .toDouble() asegura que siempre sea double en Dart.

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] as int?,
      nombre: json['nombre'] as String,
      nota: (json['nota'] as num).toDouble(),
    );
  }

  // ─── toJson: Convierte un objeto Student a Map (JSON) ───
  // Se usa cuando ESCRIBIMOS datos a Supabase.
  //
  // Nota: NO incluimos 'id' ni 'created_at' porque Supabase
  // los genera automáticamente. Solo enviamos lo que el usuario escribe.

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'nota': nota,
    };
  }

  // ─── Getters ───
  String get notaFormateada => nota.toStringAsFixed(1);

  String get estadoNota {
    if (nota >= 9.0) return 'Excelente';
    if (nota >= 7.0) return 'Bueno';
    if (nota >= 6.0) return 'Aprobado';
    return 'Reprobado';
  }
}
