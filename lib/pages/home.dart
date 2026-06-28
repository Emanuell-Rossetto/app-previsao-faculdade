import 'package:flutter/material.dart';
import 'package:previsao_faculdade/models/city_model.dart';
import 'package:previsao_faculdade/models/weather_model.dart';
import 'package:previsao_faculdade/services/city_service.dart';
import 'package:previsao_faculdade/services/weather_service.dart';
import 'package:previsao_faculdade/repository/database_helper.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _savedCities = [];
  WeatherModel? _currentWeather;
  bool _isLoadingWeather = false;
  String? _selectedCityName;
  String? _selectedCityUF;

  @override
  void initState() {
    super.initState();
    _loadCitiesAndWeather();
  }

  Future<void> _loadCitiesAndWeather({CityModel? selectedCity}) async {
    final cities = await _dbHelper.getSavedCities();
    setState(() {
      _savedCities = cities;
    });

    if (selectedCity != null) {
      _fetchWeather(
        selectedCity.nome ?? '',
        selectedCity.microrregiao?.mesorregiao?.uF?.sigla ?? '',
      );
    } else if (cities.isNotEmpty) {
      // Default to the first one (which should be current location if it exists)
      final firstCity = cities[0];
      _fetchWeather(
        firstCity['nome'],
        firstCity['uf'],
        lat: firstCity['lat'],
        lon: firstCity['lon'],
      );
    }
  }

  Future<void> _fetchWeather(String cityName, String uf, {double? lat, double? lon}) async {
    setState(() {
      _isLoadingWeather = true;
      _selectedCityName = cityName;
      _selectedCityUF = uf;
    });

    try {
      WeatherModel weather;
      if (lat != null && lon != null) {
        // Se temos coordenadas (localização atual), usamos diretamente
        weather = await WeatherService.fetchWeatherByCoords(lat, lon);
      } else {
        // Se é uma cidade manual sem coordenadas salvas, usamos o nome
        weather = await WeatherService.fetchWeather(cityName, uf);
      }

      setState(() {
        _currentWeather = weather;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao buscar clima: $e')),
      );
    } finally {
      setState(() => _isLoadingWeather = false);
    }
  }

  void _showAddCityDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddCityDialog(),
    ).then((newCity) {
      if (newCity != null && newCity is CityModel) {
        _loadCitiesAndWeather(selectedCity: newCity);
      } else {
        _loadCitiesAndWeather();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Previsão do Tempo'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Center(
                child: Text(
                  'Cidades Salvas',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _savedCities.length,
                itemBuilder: (context, index) {
                  final city = _savedCities[index];
                  final bool isCurrent = city['is_current_location'] == 1;
                  return ListTile(
                    leading: Icon(isCurrent ? Icons.my_location : Icons.location_city),
                    title: Text('${city['nome']} - ${city['uf']}'),
                    subtitle: isCurrent ? const Text('Localização Atual') : null,
                    onTap: () {
                      _fetchWeather(
                        city['nome'],
                        city['uf'],
                        lat: city['lat'],
                        lon: city['lon'],
                      );
                      Navigator.pop(context);
                    },
                    trailing: !isCurrent ? IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await _dbHelper.deleteCity(city['id']);
                        _loadCitiesAndWeather();
                      },
                    ) : null,
                  );
                },
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Adicionar Cidade'),
              onTap: () {
                Navigator.pop(context);
                _showAddCityDialog();
              },
            ),
          ],
        ),
      ),
      body: _isLoadingWeather
          ? const Center(child: CircularProgressIndicator())
          : _currentWeather == null
              ? const Center(child: Text('Nenhuma cidade selecionada'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '${_selectedCityName ?? ''}, ${_selectedCityUF ?? ''}',
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _currentWeather!.description.toUpperCase(),
                        style: const TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '${_currentWeather!.temp.toStringAsFixed(1)}°C',
                        style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildWeatherDetail(Icons.arrow_downward, 'Mín', '${_currentWeather!.tempMin.toStringAsFixed(1)}°C'),
                          _buildWeatherDetail(Icons.arrow_upward, 'Máx', '${_currentWeather!.tempMax.toStringAsFixed(1)}°C'),
                        ],
                      ),
                      const Divider(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildWeatherDetail(Icons.water_drop, 'Humidade', '${_currentWeather!.humidity}%'),
                          _buildWeatherDetail(Icons.air, 'Vento', '${_currentWeather!.windSpeed} km/h'),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildWeatherDetail(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class AddCityDialog extends StatefulWidget {
  const AddCityDialog({super.key});

  @override
  State<AddCityDialog> createState() => _AddCityDialogState();
}

class _AddCityDialogState extends State<AddCityDialog> {
  final _formKey = GlobalKey<FormState>();
  List<CityModel> _cities = [];
  CityModel? _selectedCity;
  String _uf = "";
  bool _isLoading = false;

  final List<String> estados = [
    'AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA', 'MT', 'MS', 'MG',
    'PA', 'PB', 'PR', 'PE', 'PI', 'RJ', 'RN', 'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO',
  ];

  Future<void> _fetchCities(String uf) async {
    setState(() {
      _isLoading = true;
      _cities = [];
      _selectedCity = null;
    });

    try {
      final cities = await CityService.fetchCityByState(uf);
      setState(() {
        _cities = cities;
      });
    } catch (e) {
      debugPrint('Erro ao buscar cidades: \$e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Adicionar Cidade'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Estado (UF)"),
                items: estados.map((uf) => DropdownMenuItem(value: uf, child: Text(uf))).toList(),
                onChanged: (uf) {
                  if (uf == null) return;
                  setState(() => _uf = uf);
                  _fetchCities(uf);
                },
              ),
              const SizedBox(height: 12),
              Autocomplete<CityModel>(
                displayStringForOption: (city) => city.nome ?? '',
                optionsBuilder: (textEditingValue) {
                  if (textEditingValue.text.isEmpty) return _cities;
                  return _cities.where((city) => (city.nome ?? '').toLowerCase().contains(textEditingValue.text.toLowerCase()));
                },
                onSelected: (city) => setState(() => _selectedCity = city),
                fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
                  return TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      labelText: "Cidade",
                      hintText: _uf.isEmpty ? "Selecione um estado" : "Digite o nome da cidade",
                    ),
                    enabled: _cities.isNotEmpty,
                  );
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: _isLoading || _selectedCity == null
              ? null
              : () async {
                  final dbHelper = DatabaseHelper();
                  // Ensure UF is set in the model
                  if (_selectedCity!.microrregiao == null) {
                    _selectedCity!.microrregiao = Microrregiao(mesorregiao: Mesorregiao(uF: UF(sigla: _uf)));
                  } else if (_selectedCity!.microrregiao!.mesorregiao == null) {
                     _selectedCity!.microrregiao!.mesorregiao = Mesorregiao(uF: UF(sigla: _uf));
                  } else if (_selectedCity!.microrregiao!.mesorregiao!.uF == null) {
                    _selectedCity!.microrregiao!.mesorregiao!.uF = UF(sigla: _uf);
                  } else {
                    _selectedCity!.microrregiao!.mesorregiao!.uF!.sigla = _uf;
                  }
                  
                  await dbHelper.insertCity(_selectedCity!);
                  if (context.mounted) Navigator.pop(context, _selectedCity);
                },
          child: const Text('Adicionar'),
        ),
      ],
    );
  }
}
