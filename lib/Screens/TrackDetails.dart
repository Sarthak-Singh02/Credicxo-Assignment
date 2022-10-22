import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import '../blocs/internet_bloc/internet_bloc.dart';
import '../blocs/internet_bloc/internet_state.dart';

class TrackDetails extends StatefulWidget {
  final String track_id;
  const TrackDetails({super.key, required this.track_id});

  @override
  State<TrackDetails> createState() => _TrackDetailsState();
}

class _TrackDetailsState extends State<TrackDetails> {
  String track_name = "";
  String album_name = "";
  String artist_name = "";
  String track_rating = "";
  loadTrackDetails() async {
    final url =
        "https://api.musixmatch.com/ws/1.1/track.get?track_id=${widget.track_id}&apikey=3bc90673975fc6a5f504d96349f377f0";
    try {
      final response = await http.get(Uri.parse(url));
      final decodedData = jsonDecode(response.body);
      final parsedJson = decodedData["message"]["body"]["track"];

      track_name = parsedJson["track_name"].toString();
      album_name = parsedJson["album_name"].toString();
      artist_name = parsedJson["artist_name"].toString();
      track_rating = parsedJson["track_rating"].toString();
    } catch (e) {
      print("ERROR: " + e.toString());
      final snackBar = SnackBar(
        duration: Duration(seconds: 180),
        content: const Text('Turn on internet and try again'),
        action: SnackBarAction(
          label: 'Try Again',
          onPressed: () {
            loadTrackDetails();
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    if (mounted) setState(() {});
  }

  Widget listTile(String heading, String data) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        tileColor: CupertinoColors.systemGrey5,
        title: Text(heading),
        subtitle: Text(data),
      ),
    );
  }

  @override
  void initState() {
    loadTrackDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Track  Details"),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          BlocBuilder<InternetBloc, InternetState>(
            builder: (context, state) {
              if (state is InternetGainedState) {
                return (track_name.isNotEmpty)?Column(
                  children: [
                    listTile("Track Name", track_name),
                    listTile("Album Name", album_name),
                    listTile("Artist Name", artist_name),
                    listTile("Track Rating", track_rating),
                  ],
                ):Container(
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
