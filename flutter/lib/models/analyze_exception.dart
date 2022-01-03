class AnalyzeException implements Exception {
  final String cause;

  AnalyzeException(this.cause);

  static noCoinsFound() {
    return AnalyzeException("Aucune pièce n'a été trouvée.");
  }

  @override
  String toString() {
    return cause;
  }
}