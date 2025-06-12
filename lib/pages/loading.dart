import 'package:flutter/material.dart';
import 'package:a_world_time_app/services/world_time.dart' as services;
import 'package:flutter_spinkit/flutter_spinkit.dart' as spinner;
import 'package:shared_preferences/shared_preferences.dart';

class Loading extends StatefulWidget {
  const Loading({super.key});

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {

  Future<void> setupWorldTime() async {
    services.WorldTime instance = services.WorldTime(
      location: 'Jakarta',
      flag: 'indonesia.png',
      url: 'Asia/Jakarta',
    );
    await instance.getTime();
    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      '/home',
      arguments: {
        'location': instance.location,
        'flag': instance.flag,
        'time': instance.time,
        'isDayTime': instance.isDayTime,
      },
    );
  }

  void debugPreference(SharedPreferences prefs){
    Set<String> keys = prefs.getKeys();
    for(var key in keys){
      final value = prefs.get(key);
      debugPrint('Key : $key, Value : $value');
    }
  }

  Future<void> loadPrefsAndNavigate() async {
    final prefs = await SharedPreferences.getInstance();
    String location = prefs.getString('location') ?? 'Jakarta';
    String flag = prefs.getString('flag') ?? 'indonesia.png';
    String url = prefs.getString('url') ?? 'Asia/Jakarta';

    services.WorldTime instance = services.WorldTime(
      location: location,
      flag: flag,
      url: url,
    );
    await instance.getTime();
    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      '/home',
      arguments: {
        'location': instance.location,
        'flag': instance.flag,
        'time': instance.time,
        'isDayTime': instance.isDayTime,
      },
    );
  }

  void runAsync() async {
    await Future.delayed(Duration(seconds: 2));
    if (await services.checkPrefs()) {
      debugPrint('Prefs available, load data and navigate!');
      await loadPrefsAndNavigate();
      return;
    } 
    debugPrint('No prefs available, create the data and navigate!');
    await setupWorldTime();
    return;
  }

  @override
  void initState() {
    super.initState();
    runAsync();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[900],
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Loading',
                  style: TextStyle(
                  fontSize: 28.0,
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10.0),
              spinner.SpinKitThreeBounce(
                color: Colors.white,
                size: 80.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}