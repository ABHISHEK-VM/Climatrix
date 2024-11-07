class CurrentWeather {
  final String location;
  final double temperature;
  final String condition;
  final String icon;
  final double feelsLike;
  final double windSpeed;
  final int humidity;
  final int sunsetTime;
  final int sunriseTime;
  final double maxTemp;
  final double minTemp;
  final int cod; // HTTP status code

  CurrentWeather({
    required this.location,
    required this.temperature,
    required this.condition,
    required this.icon,
    required this.feelsLike,
    required this.windSpeed,
    required this.humidity,
    required this.sunsetTime,
    required this.sunriseTime,
    required this.maxTemp,
    required this.minTemp,
    required this.cod,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      location: json['name'] ?? "Unknown",
      temperature: json['main']['temp']?.toDouble() ?? 0.0,
      condition: (json['weather'] as List).isNotEmpty
          ? json['weather'][0]['description']
          : 'Unknown',
      icon: (json['weather'] as List).isNotEmpty
          ? json['weather'][0]['icon']
          : '01d',
      feelsLike: json['main']['feels_like']?.toDouble() ?? 0.0,
      windSpeed: json['wind']['speed']?.toDouble() ?? 0.0,
      humidity: json['main']['humidity'] ?? 0,
      sunsetTime: json['sys']['sunset'] ?? 0,
      sunriseTime: json['sys']['sunrise'] ?? 0,
      maxTemp: json['main']['temp_max']?.toDouble() ?? 0.0,
      minTemp: json['main']['temp_min']?.toDouble() ?? 0.0,
      cod: json['weather'][0]['id'] ?? 0,
    );
  }
}

class HourlyWeather {
  final double temperature;
  final String dateTime;

  HourlyWeather({
    required this.temperature,
    required this.dateTime,
  });

  factory HourlyWeather.fromJson(Map<String, dynamic> json) {
    return HourlyWeather(
      temperature: json['main']['temp']?.toDouble() ?? 0.0,
      dateTime: json['dt_txt'] ?? "Unknown",
    );
  }
}

class Forecast {
  final List<Weather> dailyForecast;
  final String cityName;

  Forecast({required this.dailyForecast, required this.cityName});

  factory Forecast.fromJson(Map<String, dynamic> json) {
    List<Weather> forecast = [];
    if (json['list'] != null) {
      forecast = (json['list'] as List)
          .map((day) => Weather.fromJson(day as Map<String, dynamic>))
          .toList();
    }

    String cityName = json['city']?['name'] ?? "Unknown City";
    return Forecast(dailyForecast: forecast, cityName: cityName);
  }
}

class Weather {
  final String location;
  final double temperature; // Average temperature for the day
  final String condition;
  final String icon;
  final String date;
  final List<HourlyWeather> hourlyForecast; // 3-hour intervals
  final double maxTemp;
  final double minTemp;
  final int code;
    final double feelsLike;
  final double windSpeed;
  final int humidity;
  final int sunsetTime;
  final int sunriseTime;

  Weather(
      {required this.location,
      required this.temperature,
      required this.condition,
      required this.icon,
      required this.date,
      required this.hourlyForecast, // Hourly data for the day
      required this.maxTemp,
      required this.minTemp,
      required this.code, 
      required this.feelsLike,
      required this.humidity,
      required this.sunriseTime,
      required this.sunsetTime,
      required this.windSpeed
      
      });

  factory Weather.fromJson(Map<String, dynamic> json) {
    List<HourlyWeather> hourlyForecast = [];
    if (json['list'] != null) {
      hourlyForecast = (json['list'] as List)
          .map((hour) => HourlyWeather.fromJson(hour as Map<String, dynamic>))
          .toList();
    }

    return Weather(
        location: json['name'] ?? "Unknown",
        temperature: json['main']['temp']?.toDouble() ?? 0.0,
        condition: (json['weather'] as List).isNotEmpty
            ? json['weather'][0]['description']
            : 'Unknown',
        icon: (json['weather'] as List).isNotEmpty
            ? json['weather'][0]['icon']
            : '01d',
        date: json['dt_txt'].toString() ?? "Unknown Date",
        hourlyForecast: hourlyForecast,
        maxTemp: json['main']['temp_max']?.toDouble() ?? 0.0,
        minTemp: json['main']['temp_min']?.toDouble() ?? 0.0,
        code: json['weather'][0]['id'],
        feelsLike: json['main']['feels_like']?.toDouble() ?? 0.0,
      windSpeed: json['wind']['speed']?.toDouble() ?? 0.0,
      humidity: json['main']['humidity'] ?? 0,
      sunsetTime: json['sys']['sunset'] ?? 0,
      sunriseTime: json['sys']['sunrise'] ?? 0,
        );
        
  }
}
