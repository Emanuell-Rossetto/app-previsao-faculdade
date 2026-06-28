import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:previsao_faculdade/pages/home.dart';
import 'package:previsao_faculdade/services/location_service.dart';
import 'package:previsao_faculdade/services/weather_service.dart';
import 'package:previsao_faculdade/repository/database_helper.dart';
import 'package:previsao_faculdade/models/city_model.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    // Get current location
    Position? position = await LocationService.getCurrentPosition();
    if (position != null) {
      String? cityName;
      String? stateCode;

      // Try to get city name from coords via geocoding package
      final placemark = await LocationService.getPlacemarkFromCoords(
          position.latitude, position.longitude);
      
      if (placemark != null) {
        cityName = placemark.locality;
        stateCode = placemark.administrativeArea;
      }

      // If geocoding failed to get a city name, try to get it from Weather API directly
      if (cityName == null || cityName.isEmpty) {
        try {
          final weather = await WeatherService.fetchWeatherByCoords(
              position.latitude, position.longitude);
          cityName = weather.cityName;
        } catch (e) {
          cityName = "Minha Localização";
        }
      }

      // Save current location in DB
      final dbHelper = DatabaseHelper();
      await dbHelper.insertCity(
        CityModel(
          id: null,
          nome: cityName,
          microrregiao: Microrregiao(
            mesorregiao: Mesorregiao(
              uF: UF(sigla: stateCode ?? ""),
            ),
          ),
        ),
        isCurrentLocation: true,
        lat: position.latitude,
        lon: position.longitude,
      );
    }

    // Small delay to show splash
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Home()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Container(
          color: Colors.white,
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wb_sunny, size: 100, color: Colors.orange),
                SizedBox(height: 20),
                Text(
                  'Previsão do Tempo',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
