import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:weather_app/api.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      darkTheme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Weather currentWeather;
  Status status;
  String error = "";

  Future<void> getWeather() async {
    String _error = "";

    try {
      final _currentWeather = await API.instance.getCurrentWeather();

      setState(() {
        currentWeather = _currentWeather;
        status = Status.ACTIVE;
      });
    } on SocketException {
      _error = "You don't have connection, try again later.";
    } on PlatformException catch (e) {
      _error = "${e.message}, please allow the app to access your current location from the settings.";
    } catch (e) {
      _error = "Unknown error, try again.";
    }

    setState(() {
      error = _error;
      if (_error.isNotEmpty) {
        status = Status.ERROR;
      }
    });
  }

  @override
  void initState() {
    status = Status.PENDING;
    getWeather();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Text("WEATHER TODAY"),
      ),
      body: RefreshIndicator(
        onRefresh: getWeather,
        child: Stack(
          children: [
            if (status == Status.PENDING)
              Center(
                child: CircularProgressIndicator.adaptive(),
              ),
            if (status == Status.ACTIVE)
              Container(
                color: Theme.of(context).primaryColor.withOpacity(0.15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_pin,
                          color: Theme.of(context).primaryColor,
                        ),
                        Text(
                          "${currentWeather.city}, ${currentWeather.country}",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Text(
                      "${currentWeather.temp.toString()}",
                      style: TextStyle(
                        fontSize: 80,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network(currentWeather.getIcon(), height: 40),
                        Text(
                          "${currentWeather.main}: ${currentWeather.desc}",
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            Column(
              children: [
                HighlightedMsg(
                  msg: "The information is using OpenWeather Public API, "
                      "and is displaying the weather for your current location. "
                      "Tempreture is in celcius.",
                ),
                if (status == Status.ERROR)
                  HighlightedMsg(
                    msg: "$error",
                    color: Colors.red[100],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class HighlightedMsg extends StatelessWidget {
  const HighlightedMsg({
    Key key,
    @required this.msg,
    this.color,
  }) : super(key: key);
  final String msg;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(color: color ?? Theme.of(context).highlightColor),
        padding: EdgeInsets.all(20),
        child: Text(
          msg,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
