import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:previsao_faculdade/models/weather_model.dart';

class WeatherService {
  static const String _apiKey = '5a78e627d7062b2fad84f77b5e65633a';

  static const String _weatherBaseUrl = 'https://api.openweathermap.org/data/2.5/weather';
  static const String _geoBaseUrl = 'https://api.openweathermap.org/geo/1.0/direct';

  static Future<WeatherModel> fetchWeather(String cityName, String stateCode) async {
    // 1. Monta a busca protegendo contra acentos e espaços (Ex: "São Paulo")
    final String query = Uri.encodeComponent('$cityName,$stateCode,BR');
    final geoUrl = Uri.parse('$_geoBaseUrl?q=$query&limit=1&appid=$_apiKey');

    final geoResponse = await http.get(geoUrl);

    if (geoResponse.statusCode == 200) {
      final List<dynamic> geoList = jsonDecode(geoResponse.body);

      if (geoList.isEmpty) {
        throw Exception('Cidade "$cityName - $stateCode" não encontrada.');
      }

      // 2. Extrai lat e lon com cast seguro
      final double lat = (geoList[0]['lat'] as num).toDouble();
      final double lon = (geoList[0]['lon'] as num).toDouble();

      // 3. Reaproveita o método debaixo que já faz a requisição certa!
      return await fetchWeatherByCoords(lat, lon);
    } else {
      throw Exception('Falha na API de Geocodificação: ${geoResponse.body}');
    }
  }

  static Future<WeatherModel> fetchWeatherByCoords(double lat, double lon) async {
    final url = Uri.parse(
        '$_weatherBaseUrl?lat=$lat&lon=$lon&appid=$_apiKey&units=metric&lang=pt_br'
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return WeatherModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Falha ao carregar o clima: ${response.body}');
    }
  }
}