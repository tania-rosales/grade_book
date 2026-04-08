class Student {
  final String id;
  final String nombre;
  final double nota;

  Student({required this.id, required this.nombre, required this.nota});

  String get notaFormateada => nota.toStringAsFixed(1);
  String get estadoNota {
    if (nota >= 9.0) return 'Excelente';
    if (nota >= 7.0) return 'Bueno';
    if (nota >= 6.0) return 'Aprobado';
    return 'Reprobado';
  }

  @override
  String toString() => 'Student(id: $id, nombre: $nombre, nota: $nota)';
}
