import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:menekse_ergin/record_audio_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Menekse Ergin'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool hasPermission;
  @override
  void initState() {
    super.initState();
    getPermission().then((onValue) {
      hasPermission = onValue;
    });
  }

  static const platform = const MethodChannel('samples.flutter.dev/battery');

  Future<bool> getPermission() async {
    return await FlutterAudioRecorder.hasPermissions;
  }

  Future<void> _getBatteryLevel() async {
    TimeOfDay _timeOfDay = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (_timeOfDay != null) {
      String audioPath = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RecorderExample(),
        ),
      );
      print("gelen path: " + audioPath.toString());
      await platform.invokeMethod('getBatteryLevel', <String, dynamic>{
        "hour": _timeOfDay.hour,
        "minute": _timeOfDay.minute,
        "audioPath": audioPath
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(),
      floatingActionButton: FloatingActionButton(
        onPressed: _getBatteryLevel,
        tooltip: 'Alarm kur',
        child: Icon(Icons.add),
      ),
    );
  }
}
