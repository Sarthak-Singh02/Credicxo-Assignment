import 'dart:convert';

import 'package:credicxo/Screens/TrackDetails.dart';
import 'package:credicxo/TrackModel.dart';
import 'package:credicxo/blocs/internet_bloc/internet_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import '../blocs/internet_bloc/internet_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: new Row(
        children: [
          CircularProgressIndicator(),
          Container(
              margin: EdgeInsets.only(left: 7), child: Text("Loading...")),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  List<TrackModel> _trackModel = [];
  loadTrack() async {
    final url =
        "https://api.musixmatch.com/ws/1.1/chart.tracks.get?apikey=3bc90673975fc6a5f504d96349f377f0";
    try {
      final response = await http.get(Uri.parse(url));
      final decodedData = jsonDecode(response.body);
      final parsedJson = decodedData["message"]["body"]["track_list"] as List;

      for (int i = 0; i < parsedJson.length; i++) {
        TrackModel model = TrackModel();
        model.track_id = parsedJson[i]["track"]["track_id"].toString();
        model.track_name = parsedJson[i]["track"]["track_name"];
        _trackModel.add(model);
      }
    } catch (e) {
      print("ERROR: " + e.toString());
      final snackBar = SnackBar(
        duration: Duration(seconds: 180),
        content: const Text('Turn on internet and try again'),
        action: SnackBarAction(
          label: 'Try Again',
          onPressed: () {
            _trackModel.clear();
            loadTrack();
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    if (mounted) setState(() {});
  }

  Future<void> loadLyrics(String track_name, String track_id) async {
    showLoaderDialog(context);
    final url =
        "https://api.musixmatch.com/ws/1.1/track.lyrics.get?track_id=${track_id}&apikey=3bc90673975fc6a5f504d96349f377f0";

    final response = await http.get(Uri.parse(url));
    final decodedData = jsonDecode(response.body);
    final parsedJson = decodedData["message"]["body"]["lyrics"]["lyrics_body"];
    Navigator.pop(context);
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(track_name),
          content: Container(
              child: FittedBox(
            fit: BoxFit.contain,
            child: Text(parsedJson.toString()),
          )),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadTrack();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Homepage"),
      ),
      body: ListView(
        children: [
          BlocBuilder<InternetBloc, InternetState>(
            builder: (context, state) {
              if (state is InternetGainedState) {
                return (_trackModel.length != 0 || _trackModel.isNotEmpty)
                    ? ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _trackModel.length,
                        itemBuilder: ((context, index) {
                          final item = _trackModel[index];
                          return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListTile(
                                trailing: IconButton(
                                    onPressed: () {
                                      Navigator.push<void>(
                                        context,
                                        MaterialPageRoute<void>(
                                          builder: (BuildContext context) =>
                                              TrackDetails(
                                            track_id: item.track_id,
                                          ),
                                        ),
                                      );
                                    },
                                    icon: Icon(
                                      Icons.info_outline,
                                      color: Colors.blueAccent,
                                    )),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                tileColor: CupertinoColors.systemGrey5,
                                onTap: () {
                                  loadLyrics(item.track_name, item.track_id);
                                },
                                title: Text(item.track_name),
                              ));
                        }))
                    : Container(
                        alignment: Alignment.bottomCenter,
                        height: MediaQuery.of(context).size.height / 2,
                        width: MediaQuery.of(context).size.width,
                        child: CircularProgressIndicator());
              }

              return Container(
                  alignment: Alignment.bottomCenter,
                  height: MediaQuery.of(context).size.height / 2,
                  width: MediaQuery.of(context).size.width,
                  child: Text("No internet Connection"));
            },
          )
        ],
      ),
    );
  }
}
