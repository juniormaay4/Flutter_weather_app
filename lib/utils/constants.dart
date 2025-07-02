class Constants {
  // 🔑 Clé API temporaire - remplace par la tienne !
  // Pour obtenir ta clé gratuite : https://openweathermap.org/api
  static const String apiKey = '2de46cc6e20c82168a6f37ba0e7716e6'; // Les données par défaut seront utilisées
  
  // Messages de chargement rotatifs
  static const List<String> loadingMessages = [
    'Nous téléchargeons les données...',
    'C\'est presque fini...',
    'Plus que quelques secondes avant d\'avoir le résultat...',
    'Récupération des informations météo...',
    'Traitement des données en cours...',
    'Finalisation du chargement...',
  ];
  
  // Durées d'animation
  static const Duration progressAnimationDuration = Duration(seconds: 8);
  static const Duration messageRotationDuration = Duration(seconds: 2);
}

// Extensions utiles
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}