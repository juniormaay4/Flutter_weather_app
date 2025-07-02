import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../widgets/animated_progress_bar.dart';
import '../widgets/loading_messages.dart';
import '../widgets/weather_card.dart';
import '../utils/theme.dart';
import 'city_detail_screen.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  bool _isCompleted = false;
  bool _hasError = false;
  List<WeatherData> _weatherData = [];
  String _errorMessage = '';
  
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String? _searchError;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _loadWeatherData();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadWeatherData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _isCompleted = false;
    });

    try {
      final data = await WeatherService.getAllWeatherData();
      setState(() {
        _weatherData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
        _errorMessage = 'Erreur lors du chargement des données météo: $e';
      });
    }
  }

  void _onProgressComplete() {
    setState(() {
      _isCompleted = true;
    });
    _fadeController.forward();
    _slideController.forward();
  }

  void _restartExperience() {
    _fadeController.reverse().then((_) {
      _slideController.reverse().then((_) {
        _loadWeatherData();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: themeProvider.isDarkMode
                ? [const Color(0xFF1A1A2E), const Color(0xFF16213E), const Color(0xFF0F3460)]
                : [const Color(0xFF74b9ff), const Color(0xFF0984e3), const Color(0xFF6c5ce7)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(themeProvider),
              // Barre de recherche
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        enabled: !_isSearching,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Rechercher une ville...',
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.15),
                          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.search, color: Colors.white),
                        ),
                        onSubmitted: (value) => _onSearchCity(),
                      ),
                    ),
                    if (_isSearching)
                      const Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ),
              if (_searchError != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Text(
                    _searchError!,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 14),
                  ),
                ),
              // Contenu principal
              Expanded(
                child: _hasError 
                    ? _buildErrorWidget()
                    : _isCompleted 
                        ? _buildWeatherList()
                        : _buildLoadingWidget(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          ),
          
          const Expanded(
            child: Text(
              'Données Météo Mondiales',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          IconButton(
            onPressed: themeProvider.toggleTheme,
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        
        // Messages de chargement rotatifs
        LoadingMessages(),
        
        const SizedBox(height: 60),
        
        // Jauge de progression animée
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: AnimatedProgressBar(
            duration: const Duration(seconds: 8),
            onComplete: _onProgressComplete,
            isCompleted: _isCompleted,
          ),
        ),
        
        const SizedBox(height: 40),
        
        Text(
          'Récupération des données pour 5 villes...',
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildWeatherList() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            // Titre avec explosion d'émojis
            Container(
              margin: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    'Chargement efferctif',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Données récupérées avec succès !',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            
            // Liste des cartes météo
            Expanded(
              child: ListView.builder(
                itemCount: _weatherData.length,
                itemBuilder: (context, index) {
                  return WeatherCard(
                    weather: _weatherData[index],
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, _) {
                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(1.0, 0.0),
                                end: Offset.zero,
                              ).animate(animation),
                              child: CityDetailScreen(weather: _weatherData[index]),
                            );
                          },
                          transitionDuration: const Duration(milliseconds: 500),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            
            // Bouton recommencer
            Container(
              margin: const EdgeInsets.all(20),
              child: ElevatedButton.icon(
                onPressed: _restartExperience,
                icon: const Icon(Icons.refresh, size: 24),
                label: const Text(
                  'Recommencer l\'expérience',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  backgroundColor: Colors.white,
                  foregroundColor: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error_outline,
          size: 80,
          color: Colors.white.withOpacity(0.8),
        ),
        
        const SizedBox(height: 20),
        
        const Text(
          'Oops ! Une erreur s\'est produite',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 10),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            _errorMessage,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        
        const SizedBox(height: 40),
        
        ElevatedButton.icon(
          onPressed: _loadWeatherData,
          icon: const Icon(Icons.refresh, size: 24),
          label: const Text(
            'Réessayer',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            backgroundColor: Colors.white,
            foregroundColor: Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }

  Future<void> _onSearchCity() async {
    final city = _searchController.text.trim();
    if (city.isEmpty) return;
    setState(() {
      _isSearching = true;
      _searchError = null;
    });
    try {
      final weather = await WeatherService.getWeatherForCity(city);
      setState(() {
        _weatherData.removeWhere((w) => w.cityName.toLowerCase() == city.toLowerCase());
        _weatherData.insert(0, weather);
        _isSearching = false;
        _searchController.clear();
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
        _searchError = "Ville non trouvée ou erreur réseau.";
      });
    }
  }
}