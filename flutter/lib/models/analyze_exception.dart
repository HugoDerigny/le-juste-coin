/// exception lancé auquel cas une erreur survient durant l'analyse
class AnalyzeException implements Exception {
  final String cause;

  AnalyzeException(this.cause);

  /// erreur si aucune pièce n'a été trouvé
  static noCoinsFound() {
    return AnalyzeException("Aucune pièce n'a été trouvée.");
  }

  @override
  String toString() {
    return cause;
  }
}