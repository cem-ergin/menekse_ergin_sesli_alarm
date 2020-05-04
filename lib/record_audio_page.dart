import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'dart:async';
import 'dart:io' as io;
import 'dart:math' as math;

import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:path_provider/path_provider.dart';

class RecorderExample extends StatefulWidget {
  final LocalFileSystem localFileSystem;

  RecorderExample({localFileSystem})
      : this.localFileSystem = localFileSystem ?? LocalFileSystem();

  @override
  State<StatefulWidget> createState() => new RecorderExampleState();
}

class RecorderExampleState extends State<RecorderExample> {
  FlutterAudioRecorder _recorder;
  Recording _current;
  RecordingStatus _currentStatus = RecordingStatus.Unset;

  @override
  void initState() {
    super.initState();
    _init();
    _start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: new Center(
        child: new Padding(
          padding: new EdgeInsets.all(8.0),
          child: new Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Flexible(
                  child: Row(
                    //mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: FlatButton(
                          onPressed: () {
                            switch (_currentStatus) {
                              case RecordingStatus.Initialized:
                                {
                                  _start();
                                  break;
                                }
                              case RecordingStatus.Recording:
                                {
                                  _stop();
                                  break;
                                }
                              case RecordingStatus.Paused:
                                {
                                  _resume();
                                  break;
                                }
                              case RecordingStatus.Stopped:
                                {
                                  _init();
                                  break;
                                }
                              default:
                                break;
                            }
                          },
                          child: _buildText(_currentStatus),
                          color: Colors.lightBlue,
                        ),
                      ),
                      // Expanded(
                      //   child: FlatButton(
                      //     onPressed: _currentStatus != RecordingStatus.Unset
                      //         ? _stop
                      //         : null,
                      //     child: new AutoSizeText("Bitir",
                      //         minFontSize: 40,
                      //         style: TextStyle(color: Colors.white)),
                      //     color: Colors.blueAccent.withOpacity(0.5),
                      //   ),
                      // ),
                    ],
                  ),
                ),
                _currentStatus == RecordingStatus.Recording
                    ? AutoSizeText("Kayıt oluyor", minFontSize: 40)
                    : AutoSizeText("Bekliyor", minFontSize: 40),
                // new Text('Avg Power: ${_current?.metering?.averagePower}'),
                // new Text('Peak Power: ${_current?.metering?.peakPower}'),
                // new Text("File path of the record: ${_current?.path}"),
                // new Text("Format: ${_current?.audioFormat}"),
                // new Text(
                //     "isMeteringEnabled: ${_current?.metering?.isMeteringEnabled}"),
                // new Text("Extension : ${_current?.extension}"),
                _current != null
                    ? AutoSizeText(
                        "${_current?.duration.inSeconds} saniye",
                        minFontSize: 40,
                      )
                    : Container(
                        height: 1,
                        width: 1,
                      ),
              ]),
        ),
      ),
    );
  }

  _init() async {
    try {
      if (await FlutterAudioRecorder.hasPermissions) {
        String customPath = '/flutter_audio_recorder_';
        io.Directory appDocDirectory;
//        io.Directory appDocDirectory = await getApplicationDocumentsDirectory();
        if (io.Platform.isIOS) {
          appDocDirectory = await getApplicationDocumentsDirectory();
        } else {
          appDocDirectory = await getExternalStorageDirectory();
        }

        // can add extension like ".mp4" ".wav" ".m4a" ".aac"
        customPath = appDocDirectory.path +
            customPath +
            DateTime.now().millisecondsSinceEpoch.toString();

        // .wav <---> AudioFormat.WAV
        // .mp4 .m4a .aac <---> AudioFormat.AAC
        // AudioFormat is optional, if given value, will overwrite path extension when there is conflicts.
        _recorder =
            FlutterAudioRecorder(customPath, audioFormat: AudioFormat.AAC);

        await _recorder.initialized;
        // after initialization
        var current = await _recorder.current(channel: 0);
        print(current);
        // should be "Initialized", if all working fine
        setState(() {
          _current = current;
          _currentStatus = current.status;
          print(_currentStatus);
        });
      } else {
        Scaffold.of(context).showSnackBar(
            new SnackBar(content: new Text("You must accept permissions")));
      }
    } catch (e) {
      print(e);
    }
  }

  _start() async {
    try {
      await _recorder.start();
      var recording = await _recorder.current(channel: 0);
      setState(() {
        _current = recording;
      });

      const tick = const Duration(milliseconds: 50);
      new Timer.periodic(tick, (Timer t) async {
        if (_currentStatus == RecordingStatus.Stopped) {
          t.cancel();
        }

        var current = await _recorder.current(channel: 0);
        // print(current.status);
        setState(() {
          _current = current;
          _currentStatus = _current.status;
        });
      });
    } catch (e) {
      print(e);
    }
  }

  _resume() async {
    await _recorder.resume();
    setState(() {});
  }

  _pause() async {
    await _recorder.pause();
    setState(() {});
  }

  _stop() async {
    var result = await _recorder.stop();
    print("Stop recording: ${result.path}");
    Navigator.pop(context, result.path);
    print("Stop recording: ${result.duration}");
    File file = widget.localFileSystem.file(result.path);
    print("File length: ${await file.length()}");
    setState(() {
      _current = result;
      _currentStatus = _current.status;
    });
  }

  Widget _buildText(RecordingStatus status) {
    var text = "";
    switch (_currentStatus) {
      case RecordingStatus.Initialized:
        {
          text = 'Başlat';
          break;
        }
      case RecordingStatus.Recording:
        {
          text = 'Bitir';
          break;
        }
      case RecordingStatus.Paused:
        {
          text = 'Devam et';
          break;
        }
      case RecordingStatus.Stopped:
        {
          text = 'Hazir';
          break;
        }
      default:
        break;
    }
    return AutoSizeText(text,
        minFontSize: 80, style: TextStyle(color: Colors.white));
  }

  // void onPlayAudio() async {
  //   AudioPlayer audioPlayer = AudioPlayer();
  //   await audioPlayer.play(_current.path, isLocal: true);
  // }
}
