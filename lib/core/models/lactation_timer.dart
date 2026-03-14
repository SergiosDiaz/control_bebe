import 'enums.dart';

/// Modelo de datos puro - sin dependencias de Isar
/// Registro activo del cronómetro de lactancia
class LactationTimer {
  final int? id;
  final LactationSide side;
  final DateTime startedAt;

  LactationTimer({
    this.id,
    required this.side,
    required this.startedAt,
  });

  Duration get elapsed => DateTime.now().difference(startedAt);
}
