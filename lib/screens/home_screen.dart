import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../bloc/weather_bloc.dart';
import '../bloc/weather_event.dart';
import '../bloc/weather_state.dart';
import 'forecast_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkAndFetchWeather();
  }

  void _checkAndFetchWeather() {
    final weatherState = context.read<WeatherBloc>().state;
    if (weatherState is! WeatherLoaded) {
      _getCurrentLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        padding: const EdgeInsets.only(top: 60, left: 2, right: 2, bottom: 15),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xffA090FF),
              Color(0xff9E8EFF),
              Color(0xff6D5BD8),
              Color(0xff7560F5),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onSubmitted: (value) {
                        final cityName = cityController.text;
                        if (cityName.isNotEmpty) {
                          context
                              .read<WeatherBloc>()
                              .add(FetchCurrentWeatherByCity(cityName));
                          cityController.clear();
                        }
                      },
                      style: const TextStyle(color: Colors.white),
                      controller: cityController,
                      decoration: InputDecoration(
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        labelText: "Enter City Name",
                        labelStyle: const TextStyle(
                            color: Color.fromARGB(255, 232, 227, 255)),
                        filled: true,
                        fillColor: Colors.transparent,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(
                              color: Color.fromARGB(255, 187, 175, 255),
                              width: 0.9),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(
                              color: Color.fromARGB(255, 217, 210, 255),
                              width: 1),
                        ),
                        suffixIcon: IconButton(
                          padding: const EdgeInsets.only(right: 10),
                          icon: const Icon(Icons.search,
                              color: Color.fromARGB(255, 216, 209, 255)),
                          onPressed: () {
                            final cityName = cityController.text;
                            if (cityName.isNotEmpty) {
                              context
                                  .read<WeatherBloc>()
                                  .add(FetchCurrentWeatherByCity(cityName));
                              cityController.clear();
                            }
                          },
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 15),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                        color: const Color.fromARGB(70, 213, 206, 255),
                        borderRadius: BorderRadius.circular(17)),
                    child: IconButton(
                      icon: const Icon(
                        Icons.location_on_rounded,
                        size: 26,
                        color: Color.fromARGB(255, 248, 247, 255),
                      ),
                      onPressed: _getCurrentLocation,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<WeatherBloc, WeatherState>(
                builder: (context, state) {
                  if (state is WeatherLoading) {
                    return Center(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/loading.gif',
                          width: 500,
                        ),
                        const Text(
                          'Loading...',
                          style: TextStyle(color: Colors.white),
                        ),
                        const SizedBox(
                          height: 200,
                        )
                      ],
                    ));
                  } else if (state is WeatherLoaded) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          state.weather.location,
                          style: const TextStyle(
                              fontSize: 30,
                              color: Colors.white,
                              fontWeight: FontWeight.w600),
                        ),
                        Text(
                          state.weather.condition.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 40),
                        Container(
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width - 210,
                          height: MediaQuery.of(context).size.height * .4,
                          child: Stack(
                            fit: StackFit.expand,
                            alignment: Alignment.center,
                            children: [
                              ShaderMask(
                                shaderCallback: (Rect bounds) {
                                  return const LinearGradient(
                                    colors: [
                                      Color(0xffF9F8FF),
                                      Color.fromARGB(255, 170, 155, 255),
                                      Color.fromARGB(255, 96, 77, 202),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ).createShader(bounds);
                                },
                                child: Text(
                                  state.weather.temperature.round().toString(),
                                  style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width * 0.4,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                top: -10,
                                child: Text(
                                  "°",
                                  style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width * 0.2,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 100,
                                child: Container(
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color.fromARGB(
                                            40, 170, 155, 255), // Glow color
                                        blurRadius: 16.0, // The amount of blur
                                        spreadRadius:
                                            4.0, // How far the shadow spreads
                                        offset: Offset(0,
                                            0), // No offset, uniform shadow around the image
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        20), // Optional: rounded corners
                                    child: Image.asset(
                                      getWeatherIcon(
                                          state.weather.code,
                                          state.weather.sunriseTime,
                                          state.weather.sunsetTime),
                                      scale: 2.6,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    Image.asset(
                                      'assets/images/fog_day.png',
                                      scale: 6,
                                    ),
                                    const SizedBox(
                                      height: 12,
                                    ),
                                    const Text(
                                      "Wind",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 11),
                                    ),
                                    const SizedBox(
                                      height: 7,
                                    ),
                                    Text(
                                      "${state.weather.windSpeed} km/hr",
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(
                                width: 30,
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    Image.asset(
                                                                          'assets/images/default_day.png',
                                                                          scale: 6,
                                                                        ),
                                    const SizedBox(
                                      height: 12,
                                    ),
                                    const Text(
                                      "Humidity",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 11),
                                    ),
                                    const SizedBox(
                                      height: 7,
                                    ),
                                    Text(
                                      "${state.weather.humidity} %",
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(
                                width: 30,
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    Image.asset(
                                                                          getWeatherIcon(
                                      state.weather.code,
                                      state.weather.sunriseTime,
                                      state.weather.sunsetTime),
                                                                          scale: 6,
                                                                        ),
                                    const SizedBox(
                                      height: 12,
                                    ),
                                    const Text(
                                      "Feels Like",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 11),
                                    ),
                                    const SizedBox(
                                      height: 7,
                                    ),
                                    Text(
                                      "${state.weather.feelsLike} °C",
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 50),
                        ElevatedButton(
                          onPressed: () {
                            final cityName = state.weather.location;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ForecastScreen(cityName: cityName),
                              ),
                            );
                          },
                          child: const Text("View 5-Day Forecast"),
                        ),
                      ],
                    );
                  } else if (state is WeatherError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  } else {
                    return const Center(
                      child: Text(
                        "Enter a city name or fetch current location weather",
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    PermissionStatus status = await Permission.location.request();
    if (status.isGranted) {
      Position position = await Geolocator.getCurrentPosition(
          locationSettings:
              const LocationSettings(accuracy: LocationAccuracy.high));
      context.read<WeatherBloc>().add(
          FetchCurrentWeatherByLocation(position.latitude, position.longitude));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Location permission denied. Please enable it in settings.'),
        ),
      );
    }
  }

  String getWeatherIcon(
      int conditionCode, int sunriseTimestamp, int sunsetTimestamp) {
    // Get the current time as a DateTime object
    DateTime now = DateTime.now();

    // Convert the sunrise and sunset timestamps to DateTime objects
    DateTime sunrise =
        DateTime.fromMillisecondsSinceEpoch(sunriseTimestamp * 1000);
    DateTime sunset =
        DateTime.fromMillisecondsSinceEpoch(sunsetTimestamp * 1000);

    
    bool isDay = now.isAfter(sunrise) && now.isBefore(sunset);


    if (isDay) {
      
      if (conditionCode >= 200 && conditionCode <= 232) {
        
        return 'assets/images/thunderstorm_day.png';
      } else if (conditionCode >= 300 && conditionCode <= 321) {
        
        return 'assets/images/drizzle_day.png';
      } else if (conditionCode >= 500 && conditionCode <= 531) {
        
        return 'assets/images/rain_day.png';
      } else if (conditionCode >= 600 && conditionCode <= 622) {
       
        return 'assets/images/snow_day.png';
      } else if (conditionCode >= 701 && conditionCode <= 781) {
        
        return 'assets/images/fog_day.png';
      } else if (conditionCode == 800) {
       
        return 'assets/images/clear_day.png';
      } else if (conditionCode >= 801 && conditionCode <= 804) {
        
        return 'assets/images/cloudy_day.png';
      } else {
       
        return 'assets/images/default_day.png';
      }
    } else {
      
      if (conditionCode >= 200 && conditionCode <= 232) {
        // Thunderstorm
        return 'assets/images/thunderstorm_night.png';
      } else if (conditionCode >= 300 && conditionCode <= 321) {
        // Drizzle
        return 'assets/images/drizzle_night.png';
      } else if (conditionCode >= 500 && conditionCode <= 531) {
        // Rain
        return 'assets/images/rain_night.png';
      } else if (conditionCode >= 600 && conditionCode <= 622) {
        // Snow
        return 'assets/images/snow_night.png';
      } else if (conditionCode >= 701 && conditionCode <= 781) {
        // Atmosphere (Mist, Smoke, Haze, Fog, etc.)
        return 'assets/images/fog_night.png';
      } else if (conditionCode == 800) {
        // Clear sky
        return 'assets/images/clear_night.png';
      } else if (conditionCode >= 801 && conditionCode <= 804) {
        // Clouds (Few clouds, Scattered clouds, Broken clouds, Overcast clouds)
        return 'assets/images/cloudy_night.png';
      } else {
        // Default image for unknown codes
        return 'assets/images/default_night.png';
      }
    }
  }
}
