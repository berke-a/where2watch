import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'movieModel.dart';
import 'apiKey.dart';
import 'moviePage.dart';
import 'package:yodo1mas/testmasfluttersdktwo.dart';

class Trend extends StatefulWidget {
  @override
  _TrendState createState() => _TrendState();
}

class _TrendState extends State<Trend> {
  getTrending() async {
    Uri url = Uri.parse(
        'https://api.themoviedb.org/3/trending/all/week?api_key=$apiKey');
    var respond = await http.get(url);
    var result = jsonDecode(respond.body);
    var TrendList = <Movie>[];
    for (var singleMovie in result['results']) {
      if (singleMovie['vote_average'].runtimeType != double) {
        singleMovie['vote_average'] = singleMovie['vote_average'].toDouble();
      }
      if (singleMovie['media_type'] == 'tv') {
        Movie movie = Movie(
          singleMovie['original_name'],
          singleMovie['first_air_date'],
          singleMovie['overview'],
          singleMovie['poster_path'],
          singleMovie['vote_average'],
          singleMovie['media_type'],
          singleMovie['id'],
        );
        TrendList.add(movie);
        continue;
      } else {
        Movie movie = Movie(
          singleMovie['original_title'],
          singleMovie['release_date'],
          singleMovie['overview'],
          singleMovie['poster_path'],
          singleMovie['vote_average'],
          singleMovie['media_type'],
          singleMovie['id'],
        );
        TrendList.add(movie);
        continue;
      }
    }
    return (TrendList);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 20),
      child: Column(
        children: [
          Text(
            'Trends',
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(
              textStyle: TextStyle(
                color: Colors.blueAccent[500],
                fontSize: 40,
              ),
            ),
          ),
          FutureBuilder(
            future: getTrending(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (!snapshot.hasData || snapshot.data.length == 0) {
                return Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.blueAccent[100],
                    valueColor:
                        new AlwaysStoppedAnimation<Color>(Colors.purple[200]!),
                  ),
                );
              }
              return ListView.separated(
                separatorBuilder: (BuildContext context, int index) {
                  if ((index + 1) % 4 == 0) {
                    return Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.symmetric(vertical: 15.0),
                      child: Yodo1MASBannerAd(
                        size: BannerSize.Banner,
                        onLoad: () => print('Banner loaded:'),
                        onOpen: () => print('Banner clicked:'),
                        onClosed: () => print('Banner clicked:'),
                        onLoadFailed: (message) =>
                            print('Trend Banner Ad Load Failed : $message'),
                        onOpenFailed: (message) =>
                            print('Trend Banner Ad Open Failed : $message'),
                      ),
                    );
                  } else {
                    return SizedBox(
                      height: 35,
                    );
                  }
                },
                shrinkWrap: true,
                physics: BouncingScrollPhysics(),
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                MoviePage(snapshot.data[index])),
                      );
                    },
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child: Image(
                            height: 350,
                            image: NetworkImage(
                                'https://image.tmdb.org/t/p/w500${snapshot.data[index].poster}'),
                          ),
                        ),
                        Text(
                          '${snapshot.data[index].title}',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lato(
                            textStyle: TextStyle(
                              color: Colors.blueAccent[500],
                              fontSize: 25,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
