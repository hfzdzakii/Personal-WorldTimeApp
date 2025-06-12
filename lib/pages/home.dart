import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  Map<String, dynamic> data = {};
  late Timer _timer;
  late String loc;
  DateTime? _now;
  String? bgImage;
  String formattedTime = '-';
  Color? bgColor;
  DateFormat format = DateFormat('hh:mm:ss a');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      dynamic args = ModalRoute.of(context)?.settings.arguments;
      if (args != null) {
        data = args;
        _now = format.parse(data['time']);
        _timer = Timer.periodic(
          Duration(seconds: 1), 
          (Timer t) {
            setState(() {
              _now = _now?.add(Duration(seconds: 1));
            });
          }
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bgImage = (data.containsKey('isDayTime') && data['isDayTime'] == true) ? 'day.png' : 'night.png';
    bgColor = (data.containsKey('isDayTime') && data['isDayTime'] == true) ? Colors.blue[600] : Colors.indigo[900];
    if (_now!=null) {
      formattedTime = format.format(_now!);
    }
    loc = data['location'] ?? '-';

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/$bgImage'),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 120.0, 0.0, 0.0),
            child: Column(
              children: [
                TextButton.icon(
                  onPressed: () async {
                    dynamic result = await Navigator.pushNamed(context, '/location');
                    if (result != null){
                      setState(() {
                        data = {
                          'location': result['location'],
                          'flag': result['flag'],
                          'time': result['time'],
                          'isDayTime': result['isDayTime'],
                        };
                        _now = format.parse(result['time']);
                      });
                    }
                  }, 
                  label: Text(
                    'Edit Location',
                    style: TextStyle(
                      color: Colors.grey[50],
                    ),
                  ),
                  icon: Icon(
                    Icons.edit_location,
                    color: Colors.grey[50],
                  ),
                ),
                SizedBox(height: 20.0,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      loc,
                      style: TextStyle(
                        fontSize: 28.0,
                        letterSpacing: 2.0,
                        color: Colors.grey[50],
                      ),
                    )
                  ],
                ),
                SizedBox(height: 20.0),
                Text(
                  formattedTime,
                  style: TextStyle(
                    fontSize: 50.0,
                    color: Colors.grey[50],
                  ),
                )
              ],
            ),
          ),
        )
      ),
    );
  }
}