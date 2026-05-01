/// Enums compartidos (sin dependencias de Isar)
enum DiaperType {
  wet,
  dirty,
  both,
}

/// Índices persistidos en Firestore (`type`); no reordenar valores existentes.
enum FeedingType {
  leftBreast,
  rightBreast,
  bottle,
  solidFood,
}

enum LactationSide {
  left,
  right,
}

/// Unidad de cantidad para alimento sólido (persistido en Firestore como índice).
enum SolidQuantityUnit {
  grams,
  units,
}
