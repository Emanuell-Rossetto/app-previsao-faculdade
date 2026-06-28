class WeatherModel {
  final double temp;
  final double tempMin;
  final double tempMax;
  final double windSpeed;
  final int humidity;
  final String description;
  final String cityName;

  WeatherModel({
    required this.temp,
    required this.tempMin,
    required this.tempMax,
    required this.windSpeed,
    required this.humidity,
    required this.description,
    required this.cityName,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      temp: (json['main']['temp'] as num).toDouble(),
      tempMin: (json['main']['temp_min'] as num).toDouble(),
      tempMax: (json['main']['temp_max'] as num).toDouble(),
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      humidity: json['main']['humidity'] as int,
      description: json['weather'][0]['description'] as String,
      cityName: json['name'] as String,
    );
  }
}
