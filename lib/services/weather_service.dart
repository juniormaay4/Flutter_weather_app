import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';
import '../utils/constants.dart';

class WeatherService {
  static const String baseUrl = 'https://api.openweathermap.org/data/2.5/weather';
  
  // Liste élargie de villes africaines (Dakar/Sénégal en priorité)
  static const List<String> africanCities = [
    'Dakar', // Sénégal
    'Abidjan', // Côte d'Ivoire
    'Lagos', // Nigeria
    'Le Caire', // Égypte
    'Nairobi', // Kenya
    'Casablanca', // Maroc
    'Johannesburg', // Afrique du Sud
    'Tunis', // Tunisie
    'Bamako', // Mali
    'Accra', // Ghana
    'Alger', // Algérie
    'Kampala', // Ouganda
    'Addis Ababa', // Éthiopie
    'Kinshasa', // RDC
    'Luanda', // Angola
    'Tripoli', // Libye
    'Khartoum', // Soudan
    'Yaoundé', // Cameroun
    'Maputo', // Mozambique
    'Antananarivo', // Madagascar
  ];

  /// Récupère les données météo pour 5 villes africaines aléatoires (Dakar toujours incluse)
  static Future<List<WeatherData>> getAllWeatherData() async {
    List<WeatherData> weatherList = [];
    // Toujours inclure Dakar
    List<String> selectedCities = ['Dakar'];
    // Prendre 4 autres villes aléatoires (hors Dakar)
    final otherCities = List<String>.from(africanCities)..remove('Dakar');
    otherCities.shuffle();
    selectedCities.addAll(otherCities.take(4));

    for (String city in selectedCities) {
      try {
        final weatherData = await getWeatherForCity(city);
        weatherList.add(weatherData);
        await Future.delayed(Duration(milliseconds: 500 + Random().nextInt(1000)));
      } catch (e) {
        print('Erreur pour la ville $city: $e');
        weatherList.add(_createDefaultWeatherData(city));
      }
    }
    return weatherList;
  }

  /// Récupère les données météo pour une ville spécifique
  static Future<WeatherData> getWeatherForCity(String cityName) async {
    final url = '$baseUrl?q=$cityName&appid=${Constants.apiKey}&units=metric&lang=fr';
    
    final response = await http.get(Uri.parse(url));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return WeatherData.fromJson(data);
    } else {
      throw Exception('Impossible de récupérer les données météo pour $cityName');
    }
  }

  /// Créer des données par défaut en cas d'erreur API
  static WeatherData _createDefaultWeatherData(String cityName) {
    // Données par défaut avec des coordonnées connues
    late double lat, lon;
    late String country;
    
    switch (cityName) {
      case 'Paris':
        lat = 48.8566;
        lon = 2.3522;
        country = 'FR';
        break;
      case 'London':
        lat = 51.5074;
        lon = -0.1278;
        country = 'GB';
        break;
      case 'Tokyo':
        lat = 35.6762;
        lon = 139.6503;
        country = 'JP';
        break;
      case 'New York':
        lat = 40.7128;
        lon = -74.0060;
        country = 'US';
        break;
      case 'Sydney':
        lat = -33.8688;
        lon = 151.2093;
        country = 'AU';
        break;
      default:
        lat = 48.8566;
        lon = 2.3522;
        country = 'FR';
    }
    
    return WeatherData(
      cityName: cityName,
      temperature: 15.0 + Random().nextInt(20),
      description: 'données indisponibles',
      icon: '01d',
      humidity: 50 + Random().nextInt(40),
      windSpeed: 5.0 + Random().nextDouble() * 10,
      latitude: lat,
      longitude: lon,
      country: country,
    );
  }
}