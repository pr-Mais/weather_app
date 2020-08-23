import 'dart:convert';

import "package:http/http.dart" as http;

class API {
  static const String apiKey = "a4151c00c3318ce9d634d69b1be29514";
  static const String host = "api.openweathermap.org";
  static const String currentWeather = "weather";

  static Uri uri({String lat, String lon, String endpoint}) => Uri(
        scheme: "https",
        host: host,
        pathSegments: {"data", "2.5", endpoint},
        queryParameters: {
          "lat": lat,
          "lon": lon,
          "units": "metric",
          "appid": apiKey
        },
      );

  Future<Weather> getWeather(Uri uri) async {
    String _uri = uri.toString();
    final response = await http.get(_uri);

    final decodedJson = json.decode(response.body);
    print(decodedJson);
    return Weather.fromMap(decodedJson);
  }
}

class Weather {
  final int temp;
  final String city;
  final String country;
  final String main;
  final String icon;
  final int max;
  final int min;

  String getIcon() => Uri(
        scheme: "https",
        host: "openweathermap.org",
        pathSegments: {"img", "wn", "$icon@2x.png"},
      ).toString();

  Weather.fromMap(Map<String, dynamic> json)
      : temp = json['main']['temp'] as int,
        city = json['name'],
        country = json['sys']['country'],
        main = json['weather'][0]['main'],
        icon = json['weather'][0]['icon'],
        max = json['main']['temp_max'] as int,
        min = json['main']['temp_min'] as int;
}
