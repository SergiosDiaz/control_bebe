/// Edad del bebé por **meses de calendario** (mismo día del mes cuando existe;
/// si no, último día del mes, p. ej. 31 ene → 28/29 feb).
class BabyAgeCalendar {
  BabyAgeCalendar._();

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static int _lastDayOfMonth(int year, int month) =>
      DateTime(year, month + 1, 0).day;

  static int _dayClampedToMonth(DateTime birth, int year, int month) {
    final last = _lastDayOfMonth(year, month);
    final want = birth.day;
    return want > last ? last : want;
  }

  /// Último aniversario mensual de [birth] que cae en [onOrBefore] o antes (fechas sin hora).
  static DateTime lastMonthAnniversaryOnOrBefore(
    DateTime birth,
    DateTime onOrBefore,
  ) {
    final b = _dateOnly(birth);
    final r = _dateOnly(onOrBefore);
    if (!r.isAfter(b)) return b;

    var y = r.year;
    var m = r.month;
    var d = _dayClampedToMonth(b, y, m);
    var ann = DateTime(y, m, d);
    if (ann.isAfter(r)) {
      if (m == 1) {
        y--;
        m = 12;
      } else {
        m--;
      }
      d = _dayClampedToMonth(b, y, m);
      ann = DateTime(y, m, d);
    }
    return ann;
  }

  /// Meses completos de calendario y días desde el último aniversario.
  static ({int months, int days}) monthsAndDaysAt(
    DateTime birthDate,
    DateTime at,
  ) {
    final b = _dateOnly(birthDate);
    final r = _dateOnly(at);
    if (!r.isAfter(b)) return (months: 0, days: 0);

    final ann = lastMonthAnniversaryOnOrBefore(b, r);
    final months = (ann.year - b.year) * 12 + (ann.month - b.month);
    final days = r.difference(ann).inDays;
    return (months: months, days: days);
  }

  /// Meses decimales (calendario) para curvas / interpolación.
  static double fractionalMonthsAt(DateTime birthDate, DateTime at) {
    final r = _dateOnly(at);
    final m = monthsAndDaysAt(birthDate, at);
    if (m.months == 0 && m.days == 0) return 0;
    final dim = _lastDayOfMonth(r.year, r.month);
    return m.months + m.days / dim;
  }
}
