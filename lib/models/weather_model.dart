class WeatherData {
  final String cityName;
  final double temperature;
  final String description;
  final String icon;
  final int humidity;
  final double windSpeed;
  final double latitude;
  final double longitude;
  final String country;

  WeatherData({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
    required this.latitude,
    required this.longitude,
    required this.country,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      cityName: json['name'],
      temperature: json['main']['temp'].toDouble(),
      description: json['weather'][0]['description'],
      icon: json['weather'][0]['icon'],
      humidity: json['main']['humidity'],
      windSpeed: json['wind']['speed'].toDouble(),
      latitude: json['coord']['lat'].toDouble(),
      longitude: json['coord']['lon'].toDouble(),
      country: json['sys']['country'],
    );
  }

  String get iconUrl => 'https://openweathermap.org/img/wn/$icon@2x.png';
  
  String get formattedTemperature => '${temperature.round()}°C';
  
  String get capitalizedDescription => 
      description.split(' ').map((word) => 
          word[0].toUpperCase() + word.substring(1)).join(' ');
}