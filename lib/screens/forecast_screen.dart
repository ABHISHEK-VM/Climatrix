import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weatherapp/bloc/weather_event.dart';
import 'package:weatherapp/models/weather_model.dart';
import '../bloc/weather_bloc.dart';
import '../bloc/weather_state.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart'; // Import the fl_chart package

class ForecastScreen extends StatelessWidget {
  final String cityName;

  const ForecastScreen({Key? key, required this.cityName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Fetch forecast for the selected city
    context.read<WeatherBloc>().add(FetchWeatherForecastByCity(cityName));

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(top: 60, left: 2, right: 2, bottom: 15),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xff6D5BD8),
              Color(0xff6D5BD8),
              Color(0xff6D5BD8),
              Color(0xff7560F5),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(
                      Icons.chevron_left_rounded,
                      color: Colors.white,
                      size: 37,
                    )),
                Text(
                  cityName,
                  style: const TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(
                  width: 40,
                )
              ],
            ),
            const SizedBox(
              height: 3,
            ),
            const Text(
              "5 Day Forecast",
              style: TextStyle(
                fontSize: 13,
                color: Colors.white,
              ),
            ),
            const SizedBox(
              height: 10,
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
                          'Fetching Forecast Data...',
                          style: TextStyle(color: Colors.white),
                        ),
                        const SizedBox(
                          height: 200,
                        )
                      ],
                    ));
                  } else if (state is ForecastLoaded) {
                    List<Map<String, dynamic>> groupedData =
                        _groupByDate(state.forecast);

                    return ListView.builder(
                      padding: const EdgeInsets.all(3),
                      itemCount: groupedData.length,
                      itemBuilder: (context, index) {
                        final dayData = groupedData[index];
                        final date = dayData['date'];
                        final tempData = dayData['temp_data'];

                        return Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                                color:
                                    const Color.fromARGB(255, 144, 126, 248)),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 7.5),
                          padding: const EdgeInsets.all(3),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                title: Text(
                                  date,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Container(
                                height: 150, // Height for the line chart
                                padding: const EdgeInsets.all(15.0),
                                margin: const EdgeInsets.all(10),
                                child: LineChartWidget(
                                  tempData: tempData,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  } else if (state is WeatherError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }
                  return const Center(child: Text("Fetching forecast data..."));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to group data by date and time
  List<Map<String, dynamic>> _groupByDate(Forecast forecast) {
    Map<String, List<Map<String, dynamic>>> groupedData = {};

    // Format for parsing the date from `dt_txt`
    DateFormat dateFormat = DateFormat("dd MMM  •  EEEE");

    for (var weather in forecast.dailyForecast) {
      // Extract the date from `dt_txt`
      String date = dateFormat.format(DateTime.parse(weather.date));

      // Add the time and temperature to the group for that date
      if (!groupedData.containsKey(date)) {
        groupedData[date] = [];
      }

      // Format the time to display in "12 AM", "3 AM", etc.
      DateTime weatherDateTime = DateTime.parse(weather.date);
      String formattedTime = DateFormat("hh a")
          .format(weatherDateTime); // "hh" for 12-hour format, "a" for AM/PM

      groupedData[date]?.add({
        'time':
            formattedTime, // Display the formatted time as "12 AM", "3 AM", etc.
        'temp': weather.temperature,
      });
    }

    // Convert the grouped data into a list of maps
    return groupedData.entries.map((entry) {
      return {
        'date': entry.key,
        'temp_data': entry.value,
      };
    }).toList();
  }
}

class LineChartWidget extends StatefulWidget {
  final List<Map<String, dynamic>> tempData;
  final Color gradientColor1;
  final Color gradientColor2;
  final Color gradientColor3;
  final Color indicatorStrokeColor;

  const LineChartWidget({
    super.key,
    required this.tempData,
    this.gradientColor1 = const Color.fromARGB(255, 205, 196, 255),
    this.gradientColor2 = const Color.fromARGB(255, 185, 175, 255),
    this.gradientColor3 = const Color.fromARGB(255, 149, 130, 255),
    this.indicatorStrokeColor = const Color.fromARGB(255, 0, 0, 0),
  });

  @override
  _LineChartWidgetState createState() => _LineChartWidgetState();
}

class _LineChartWidgetState extends State<LineChartWidget> {
  List<int> showingTooltipOnSpots = [];

  late double minY;
  late double maxY;

  @override
  void initState() {
    super.initState();

    // Calculate minY and maxY based on temperature data
    minY = widget.tempData
        .map((e) => e['temp'])
        .reduce((a, b) => a < b ? a : b)
        .toDouble();
    maxY = widget.tempData
        .map((e) => e['temp'])
        .reduce((a, b) => a > b ? a : b)
        .toDouble();

    double padding = 2.0;
    minY -= padding;
    maxY += padding;
  }

  List<FlSpot> get spots {
    List<FlSpot> spotsList = [];

    for (int i = 0; i < widget.tempData.length; i++) {
      final data = widget.tempData[i];
      final time = i.toDouble(); // Use index as x-axis
      final temp = data['temp'].toDouble();
      spotsList.add(FlSpot(time, temp));
    }

    return spotsList;
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    final style = TextStyle(
      fontWeight: FontWeight.bold,
      color: widget.gradientColor2,
      fontSize: 10,
    );
    int index = value.toInt();
    if (index >= 0 && index < widget.tempData.length) {
      return SideTitleWidget(
        axisSide: meta.axisSide,
        child: Text(widget.tempData[index]['time'], style: style),
      );
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: LineChart(
        LineChartData(
          minY: minY,
          maxY: maxY,
          showingTooltipIndicators: showingTooltipOnSpots.map((index) {
            return ShowingTooltipIndicators([
              LineBarSpot(
                LineChartBarData(spots: spots),
                0,
                spots[index],
              ),
            ]);
          }).toList(),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              barWidth: 2.5,
              gradient: LinearGradient(colors: [
                widget.gradientColor3,
                widget.gradientColor2,
                widget.gradientColor2,
                widget.gradientColor1,
                widget.gradientColor2,
                widget.gradientColor2,
                widget.gradientColor3,
              ]),
              belowBarData: BarAreaData(
                show: false,
                gradient: LinearGradient(colors: [
                  widget.gradientColor1.withOpacity(0.4),
                  widget.gradientColor2.withOpacity(0.3),
                  widget.gradientColor3.withOpacity(0.1),
                ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
              ),
              dotData: FlDotData(
                show: false,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 5,
                    color: const Color.fromARGB(255, 215, 208, 255),
                    // strokeWidth: 1,
                    strokeColor: widget.indicatorStrokeColor,
                  );
                },
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (touchedSpot) => const Color(0xff6D5BD8),
              tooltipRoundedRadius: 8,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  return LineTooltipItem(
                    "${spot.y.toInt()}°C",
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList();
              },
            ),
            getTouchedSpotIndicator: (barData, spotIndexes) {
              return spotIndexes.map((index) {
                return TouchedSpotIndicatorData(
                  const FlLine(color: Colors.transparent),
                  FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 5,
                        color: lerpGradient(
                          barData.gradient?.colors ?? [Colors.blue],
                          barData.gradient?.stops ?? [0.5],
                          percent / 100,
                        ),
                        strokeWidth: 1,
                        strokeColor: widget.indicatorStrokeColor,
                      );
                    },
                  ),
                );
              }).toList();
            },
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: bottomTitleWidgets,
                reservedSize: 30,
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}

Color lerpGradient(List<Color> colors, List<double> stops, double t) {
  if (colors.isEmpty) throw ArgumentError('"colors" is empty.');
  if (colors.length == 1) return colors[0];
  if (stops.length != colors.length) {
    stops =
        List.generate(colors.length, (index) => index / (colors.length - 1));
  }

  for (var s = 0; s < stops.length - 1; s++) {
    if (t <= stops[s]) return colors[s];
    if (t < stops[s + 1]) {
      final sectionT = (t - stops[s]) / (stops[s + 1] - stops[s]);
      return Color.lerp(colors[s], colors[s + 1], sectionT)!;
    }
  }
  return colors.last;
}
