import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weatherapp/bloc/weather_bloc.dart';
import 'package:weatherapp/screens/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WeatherBloc(),
      child: MaterialApp(
        
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: GoogleFonts.poppins().fontFamily),
        home: HomeScreen(),
      ),
    );
  }
}
