abstract class WeatherEvent {}

class FetchCurrentWeatherByCity extends WeatherEvent {
  final String cityName;
  FetchCurrentWeatherByCity(this.cityName);
}

class FetchWeatherForecastByCity extends WeatherEvent {
  final String cityName;
  FetchWeatherForecastByCity(this.cityName);
}

class FetchCurrentWeatherByLocation extends WeatherEvent {
  final double latitude;
  final double longitude;
  FetchCurrentWeatherByLocation(this.latitude, this.longitude);
}
