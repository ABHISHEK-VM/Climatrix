import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:weatherapp/bloc/weather_event.dart';
import 'package:weatherapp/bloc/weather_state.dart';
import '../core/constants.dart';
import '../models/weather_model.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {


  WeatherBloc() : super(WeatherInitial()) {
    on<FetchCurrentWeatherByCity>(_onFetchCurrentWeatherByCity);
    on<FetchWeatherForecastByCity>(_onFetchWeatherForecastByCity);
    on<FetchCurrentWeatherByLocation>(_onFetchCurrentWeatherByLocation);
  }

  Future<void> _onFetchCurrentWeatherByCity(
      FetchCurrentWeatherByCity event, Emitter<WeatherState> emit) async {
    emit(WeatherLoading());
    try {
      final url =
          'https://api.openweathermap.org/data/2.5/weather?q=${event.cityName}&appid=$apiKey&units=metric';
      print('Fetching current weather for city: ${event.cityName}');
      print('URL: $url');

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        emit(WeatherLoaded(Weather.fromJson(data)));
        print('Current weather data loaded successfully.');
      } else {
        final errorData = jsonDecode(response.body);
        emit(WeatherError(
            'Failed to fetch weather data: ${errorData['message']}'));
      }
    } catch (e) {
      emit(WeatherError('An error occurred: $e'));
      print('Error fetching current weather: $e');
    }
  }

  Future<void> _onFetchWeatherForecastByCity(
      FetchWeatherForecastByCity event, Emitter<WeatherState> emit) async {
    emit(WeatherLoading());
    try {
      final url =
          'https://api.openweathermap.org/data/2.5/forecast?q=${event.cityName}&appid=$apiKey&units=metric';
      print('Fetching forecast for city: ${event.cityName}');
      print('URL: $url');

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        emit(ForecastLoaded(Forecast.fromJson(data)));
        print('Forecast data loaded successfully.');
      } else {
        final errorData = jsonDecode(response.body);
        emit(WeatherError(
            'Failed to fetch forecast data: ${errorData['message']}'));
      }
    } catch (e) {
      emit(WeatherError('An error occurred: $e'));
      print('Error fetching forecast: $e');
    }
  }

  Future<void> _onFetchCurrentWeatherByLocation(
      FetchCurrentWeatherByLocation event, Emitter<WeatherState> emit) async {
    emit(WeatherLoading());
    try {
      final url =
          'https://api.openweathermap.org/data/2.5/weather?lat=${event.latitude}&lon=${event.longitude}&appid=$apiKey&units=metric';
      print(
          'Fetching current weather for location: (${event.latitude}, ${event.longitude})');
      print('URL: $url');

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        emit(WeatherLoaded(Weather.fromJson(data)));
        print('Current weather data loaded successfully for location.');
      } else {
        final errorData = jsonDecode(response.body);
        emit(WeatherError(
            'Failed to fetch weather data: ${errorData['message']}'));
      }
    } catch (e) {
      emit(WeatherError('An error occurred: $e'));
      print('Error fetching weather for location: $e');
    }
  }
}
