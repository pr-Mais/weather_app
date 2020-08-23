import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_app/api.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: AppBarTheme(
          color: Colors.transparent,
          textTheme: TextTheme(
            headline6: TextStyle(color: Colors.black, fontSize: 18),
          ),
          iconTheme: IconThemeData(
            color: Colors.black,
          ),

        ),
      ),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
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
  String error = "";

  Future<void> getWeather() async {
    try{
      Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    final requestUri = API.uri(
      lon: position.longitude.toString(),
      lat: position.latitude.toString(),
      endpoint: API.currentWeather,
    );

    final _currentWeather = await API().getWeather(requestUri);

    setState(() {
      currentWeather = _currentWeather;
      error = "";
    });
    } catch(e) {
      error = "${e.message}, please allow the app to access your current location from the settings.";
    }
  }

  @override
  void initState() {
    getWeather();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Text("WEATHER TODAY"),
        actions: [IconButton(icon: Icon(Icons.menu), onPressed: () {})],
      ),
      body: RefreshIndicator(
        onRefresh: getWeather,
        child: Stack(
          children: [
            Align(
                alignment: Alignment.topCenter,
                child: Container(
                  decoration: BoxDecoration(color: Theme.of(context).highlightColor),
                  padding: EdgeInsets.all(20),
                  child: Text(
                    "The information is using OpenWeather Public API, and is displaying the weather for your current location.",
                    textAlign: TextAlign.center,
                  ),
                )),
            ListView(),
            if(error.isNotEmpty) Center(child: Text(error, textAlign: TextAlign.center,)),
            if (currentWeather == null && error.isEmpty) Center(child: Text("Loading...")),
            if (currentWeather != null)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_pin),
                        Text(
                          "${currentWeather.city}, ${currentWeather.country}",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Text(
                      "${currentWeather.temp.toString()}°",
                      style: TextStyle(
                        fontSize: 100,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network(
                          currentWeather.getIcon(),
                          width: 40,
                        ),
                        Text(
                          currentWeather.main,
                          style: TextStyle(fontSize: 20),
                        ),
                        SizedBox(width: 20),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
