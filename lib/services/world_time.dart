import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' as intl;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class WorldTime {
  String location;
  String flag;
  String url;
  late String time;
  late bool isDayTime;

  WorldTime({ 
    required this.location, 
    required this.flag, 
    required this.url,
  });
  
  Future<bool> getTime() async {
    List<String> urlList = url.split('/');

    Future<Map<String, dynamic>> fetchUTC() async {
      http.Response responseUTC = await http.get(
        Uri.parse('https://timeapi.io/api/timezone/zone?timeZone=UTC'),
        headers: {
          'Content-Type': 'application/json',
        }
      );
      return jsonDecode(responseUTC.body);
    }

    try {
      http.Response responseLocation;
      if (urlList.length == 1) {
        responseLocation = await http.get(
          Uri.parse('https://timeapi.io/api/timezone/zone?timeZone=${urlList[0]}'), 
          headers: {
            'Content-Type': 'application/json',
          },
        );
      } else if (urlList.length == 2) {
        responseLocation = await http.get(
          Uri.parse('https://timeapi.io/api/timezone/zone?timeZone=${urlList[0]}%2F${urlList[1]}'), 
          headers: {
            'Content-Type': 'application/json',
          },
        );
      } else {
        responseLocation = await http.get(
          Uri.parse('https://timeapi.io/api/timezone/zone?timeZone=${urlList[0]}%2F${urlList[1]}%2F${urlList[2]}'), 
          headers: {
            'Content-Type': 'application/json',
          },
        );
      }

      Map dataLocation = jsonDecode(responseLocation.body);
      double offset = dataLocation['currentUtcOffset']['seconds'] / 3600;

      Map dataUTC = await fetchUTC();
      String datetime = dataUTC['currentLocalTime'];

      DateTime now = DateTime.parse(datetime);
      now = now.add(Duration(hours: offset.toInt()));

      isDayTime = now.hour > 6 && now.hour < 18 ? true : false;
      time = intl.DateFormat('hh:mm:ss a').format(now);

      return true;
    } catch (e) {
      
      // Map dataUTC = await fetchUTC();
      // String datetime = dataUTC['currentLocalTime'];

      // DateTime now = DateTime.parse(datetime);

      // time = intl.DateFormat('hh:mm:ss a').format(now);
      Fluttertoast.showToast(
        msg: 'There is error',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Color.fromRGBO(255, 0, 0, 1.0),
        textColor: Color.fromRGBO(255, 255, 255, 1.0),
        fontSize: 20.0,
      );

        return false;
    }

  }

}

Future<bool> checkPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey('location') 
      && prefs.containsKey('flag')
      && prefs.containsKey('url')) {
    return true;
  }
  return false;
}

class ListTimeZone {
  late List<dynamic> timeZones;

  Future<List<dynamic>> getTimeZones() async {
    try {
      http.Response responseZones = await http.get(
        Uri.parse('https://timeapi.io/api/timezone/availabletimezones'),
        headers: {
          'Content-Type': 'application/json',
        }
      );
      List<dynamic> dataZones = jsonDecode(responseZones.body);
      return dataZones;
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'There is error : $e',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Color.fromRGBO(255, 0, 0, 1.0),
        textColor: Color.fromRGBO(255, 255, 255, 1.0),
        fontSize: 20.0,
      );
      return timeZones = [];
    }
  }
}
