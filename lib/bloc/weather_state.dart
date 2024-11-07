import '../models/weather_model.dart';

abstract class WeatherState {}

class WeatherInitial extends WeatherState {}

class WeatherLoading extends WeatherState {}

class WeatherLoaded extends WeatherState {
  final Weather weather;
  WeatherLoaded(this.weather);
}

class ForecastLoaded extends WeatherState {
  final Forecast forecast;
  ForecastLoaded(this.forecast);
}

class WeatherError extends WeatherState {
  final String message;
  WeatherError(this.message);
}
