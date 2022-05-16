import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'movieModel.dart';
import 'apiKey.dart';
import 'package:yodo1mas/testmasfluttersdktwo.dart';

var country = "", countryName = "", lower = "";

String providerLink(String provider) {
  if (provider == 'Hulu') {
    return 'https://www.hulu.com';
  } else if (provider == 'Freeform') {
    return 'https://www.freeform.com';
  } else if (provider == 'USA Network') {
    return 'https://www.usanetwork.com';
  } else if (provider == 'Apple iTunes') {
    return 'https://www.apple.com/itunes/';
  } else if (provider == 'Netflix') {
    return 'https://www.netflix.com';
  } else if (provider == 'Google Play Movies') {
    return 'https://play.google.com/store/movies';
  } else if (provider == 'Youtube') {
    return 'https://www.youtube.com';
  } else if (provider == 'Vudu') {
    return 'https://www.vudu.com';
  } else if (provider == 'Redbox') {
    return 'https://www.redbox.com';
  } else if (provider == 'AMC on Demand') {
    return 'https://www.amctheatres.com/on-demand';
  } else if (provider == 'Microsoft Store') {
    return 'https://www.microsoft.com/en-us/store/apps/windows';
  } else if (provider == 'DIRECTV') {
    return 'https://www.directv.com';
  } else if (provider == 'FandangoNOW') {
    return 'https://www.fandangonow.com';
  } else if (provider == 'Amazon Video') {
    return 'https://www.amazon.com/rent-or-buy-amazon-video/b?ie=UTF8&node=7589478011';
  } else if (provider == 'Spectrum On Demand') {
    return 'https://ondemand.spectrum.net';
  } else if (provider == 'HBO Max') {
    return 'https://www.hbomax.com';
  } else if (provider == 'Sling TV') {
    return 'https://www.sling.com';
  } else if (provider == 'TNT') {
    return 'https://www.tntdrama.com';
  } else if (provider == 'Disney Plus') {
    return 'https://www.disneyplus.com';
  } else if (provider == 'Amazon Prime Video') {
    return 'https://www.primevideo.com';
  }
  return 'https://www.linkedin.com/in/berkeahlatci/';
}

_launchURL(link) async {
  if (await canLaunch(link)) {
    await launch(link);
  } else {
    throw 'Could not launch $link';
  }
}

String minuteConvert(int time) {
  int hour = 0;
  while (time >= 60) {
    hour++;
    time -= 60;
  }
  if (hour == 0) {
    return '$time minutes';
  } else if (hour == 1 && time != 0) {
    return '$hour hour and $time minutes';
  } else if (hour != 0 && hour <= 24 && time != 0) {
    return '$hour hours and $time minutes';
  } else if (hour != 0 && hour <= 24 && time == 1) {
    return '$hour hours and $time minute';
  } else if (hour != 0 && hour <= 24 && time == 0) {
    return '$hour hours';
  } else {
    return 'More than a day';
  }
}

class MoviePage extends StatefulWidget {
  final Movie movie;
  MoviePage(this.movie);
  @override
  _MovieState createState() => _MovieState();
}

class _MovieState extends State<MoviePage> {
  searchProviders() async {
    Uri url;
    var result;
    var response;
    if (widget.movie.type == 'movie') {
      url = Uri.parse(
          'https://api.themoviedb.org/3/movie/${widget.movie.id}/watch/providers?api_key=$apiKey');
      response = await http.get(url);
      result = jsonDecode(response.body);
      Uri url2 = Uri.parse(
          'https://api.themoviedb.org/3/movie/${widget.movie.id}?api_key=$apiKey&language=en-US');
      var response2 = await http.get(url2);
      var result2 = jsonDecode(response2.body);
      result['results']['run_time'] = result2['runtime'];
    } else {
      url = Uri.parse(
          'https://api.themoviedb.org/3/tv/${widget.movie.id}/watch/providers?api_key=$apiKey');
      Uri url2 = Uri.parse(
          'https://api.themoviedb.org/3/tv/${widget.movie.id}?api_key=$apiKey&language=en-US');
      var response2 = await http.get(url2);
      var result2 = jsonDecode(response2.body);
      response = await http.get(url);
      result = jsonDecode(response.body);
      if (result2['episode_run_time'][0] != null &&
          result2['number_of_episodes'] != null) {
        result['results']['binge'] =
            result2['episode_run_time'][0] * result2['number_of_episodes'];
      } else {
        result['results']['binge'] = null;
      }
    }
    if (result['results'][country]['flatrate'] != null) {
      for (var item in result['results'][country]['flatrate']) {
        if (item['provider_name'] == 'YouTube') {
          result['results'][country]['flatrate'].remove(item);
          break;
        }
      }
    }
    if (result['results'][country]['rent'] != null) {
      for (var item in result['results'][country]['rent']) {
        if (item['provider_name'] == 'YouTube') {
          result['results'][country]['rent'].remove(item);
          break;
        }
      }
    }
    if (result['results'][country]['buy'] != null) {
      for (var item in result['results'][country]['buy']) {
        if (item['provider_name'] == 'YouTube') {
          result['results'][country]['buy'].remove(item);
          break;
        }
      }
    }
    /*
    result['results'][country]['flatrate']
        .removeWhere((item) => item['provider_name'] == 'YouTube');
    result['results'][country]['rent']
        .removeWhere((item) => item['provider_name'] == 'YouTube');
    result['results'][country]['buy']
        .removeWhere((item) => item['provider_name'] == 'YouTube');
    */
    return result['results'];
  }

  addStringToSF(String c1, String c2, String c3) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('countryKey', c1);
    prefs.setString('countryNameKey', c2);
    prefs.setString('lowerKey', c3);
    getAll();
  }

  getCountry() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String
    String stringValue = await prefs.getString('countryKey') ?? "US";
    setState(() {
      country = stringValue;
    });
  }

  getName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String stringValue =
        await prefs.getString('countryNameKey') ?? "United States";
    setState(() {
      countryName = stringValue;
    });
  }

  getLower() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String stringValue = await prefs.getString('lowerKey') ?? "us";
    setState(() {
      lower = stringValue;
    });
  }

  getAll() async {
    getCountry();
    getName();
    getLower();
  }

  void initState() {
    super.initState();
    getAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.purple[200],
      appBar: AppBar(
        title: Text(
          "${widget.movie.title}",
          textAlign: TextAlign.center,
          style: GoogleFonts.roboto(
            textStyle: TextStyle(
              fontSize: 25,
            ),
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
        backgroundColor: Colors.blueAccent[100],
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back_ios,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.only(top: 5.0),
              margin: const EdgeInsets.only(bottom: 50),
              child: Center(
                child: ListView.separated(
                  separatorBuilder: (BuildContext context, int index) {
                    return SizedBox(
                      height: 35,
                    );
                  },
                  shrinkWrap: true,
                  physics: BouncingScrollPhysics(),
                  itemCount: 1,
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child: Image(
                            height: 350,
                            image: NetworkImage(
                                'https://image.tmdb.org/t/p/w500/${widget.movie.poster}'),
                          ),
                        ),
                        Container(
                            margin: const EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: Colors.blueAccent[100],
                            ),
                            child: FutureBuilder(
                                future: searchProviders(),
                                builder: (BuildContext context,
                                    AsyncSnapshot snapshot) {
                                  if (!snapshot.hasData ||
                                      snapshot.data.length == 0) {
                                    return new Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: Container(
                                            alignment: Alignment.center,
                                            child: Center(
                                              child: Text(
                                                "There isn't any provider information for ${widget.movie.title} in $countryName.",
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.roboto(
                                                  textStyle: TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Flexible(
                                          flex: 2,
                                          child: Column(
                                            children: [
                                              Container(
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 5.0),
                                                child: Column(
                                                  children: [
                                                    Text(
                                                      "Date",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: GoogleFonts.roboto(
                                                        textStyle: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 20,
                                                        ),
                                                      ),
                                                    ),
                                                    (widget.movie.year != null)
                                                        ? Text(
                                                            "${widget.movie.year}",
                                                            //textScaleFactor: 2,
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: GoogleFonts
                                                                .roboto(
                                                              textStyle:
                                                                  TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 15,
                                                              ),
                                                            ),
                                                          )
                                                        : Text(
                                                            "Unknown",
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: GoogleFonts
                                                                .roboto(
                                                              textStyle:
                                                                  TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 15,
                                                              ),
                                                            ),
                                                          ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 5.0),
                                                child: Column(
                                                  children: [
                                                    Text(
                                                      "imdbRating",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: GoogleFonts.roboto(
                                                        textStyle: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 20,
                                                        ),
                                                      ),
                                                    ),
                                                    (widget.movie.imdbRating !=
                                                            null)
                                                        ? Text(
                                                            "${widget.movie.imdbRating}",
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: GoogleFonts
                                                                .roboto(
                                                              textStyle:
                                                                  TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 15,
                                                              ),
                                                            ),
                                                          )
                                                        : Text(
                                                            "Unknown",
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: GoogleFonts
                                                                .roboto(
                                                              textStyle:
                                                                  TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 15,
                                                              ),
                                                            ),
                                                          ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 5.0),
                                                child: Column(
                                                  children: [
                                                    Text(
                                                      "Type",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: GoogleFonts.roboto(
                                                        textStyle: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 20,
                                                        ),
                                                      ),
                                                    ),
                                                    (widget.movie.type != null)
                                                        ? Text(
                                                            "${widget.movie.type}",
                                                            //textScaleFactor: 2,
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: GoogleFonts
                                                                .roboto(
                                                              textStyle:
                                                                  TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 15,
                                                              ),
                                                            ),
                                                          )
                                                        : Text(
                                                            "Unknown",
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: GoogleFonts
                                                                .roboto(
                                                              textStyle:
                                                                  TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 15,
                                                              ),
                                                            ),
                                                          ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                  return new Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      new Flexible(
                                        flex: 3,
                                        child:
                                            (snapshot.hasData &&
                                                    snapshot.data[country] !=
                                                        null)
                                                ? Column(
                                                    children: [
                                                      Container(
                                                        margin: const EdgeInsets
                                                            .all(10.0),
                                                        child: Column(
                                                          children: [
                                                            Text(
                                                              "Flatrate",
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: GoogleFonts
                                                                  .roboto(
                                                                textStyle:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 20,
                                                                ),
                                                              ),
                                                            ),
                                                            snapshot.data[country]
                                                                        [
                                                                        'flatrate'] !=
                                                                    null
                                                                ? Container(
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              30),
                                                                      color: Colors
                                                                              .blueAccent[
                                                                          100],
                                                                    ),
                                                                    child:
                                                                        Column(
                                                                      children: [
                                                                        for (var provider
                                                                            in snapshot.data[country]['flatrate'])
                                                                          new Row(
                                                                            children: [
                                                                              Flexible(
                                                                                flex: 2,
                                                                                child: Text(
                                                                                  "${provider['provider_name']}",
                                                                                  //textScaleFactor: 2,
                                                                                  textAlign: TextAlign.center,
                                                                                  style: GoogleFonts.roboto(
                                                                                    textStyle: TextStyle(
                                                                                      color: Colors.white,
                                                                                      fontSize: 15,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              GestureDetector(
                                                                                onTap: () {
                                                                                  _launchURL(providerLink(provider['provider_name']));
                                                                                },
                                                                                child: ClipRRect(
                                                                                  borderRadius: BorderRadius.circular(40),
                                                                                  child: Image(
                                                                                    height: 30,
                                                                                    alignment: Alignment.centerRight,
                                                                                    image: NetworkImage('https://image.tmdb.org/t/p/w500/${provider['logo_path']}'),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          )
                                                                      ],
                                                                    ),
                                                                  )
                                                                : Container(
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              30),
                                                                      color: Colors
                                                                              .blueAccent[
                                                                          100],
                                                                    ),
                                                                    child: Text(
                                                                      "There isn't any known provider with flatrate in $countryName.",
                                                                      //textScaleFactor: 2,
                                                                      textAlign:
                                                                          TextAlign
                                                                              .left,
                                                                      style: GoogleFonts
                                                                          .roboto(
                                                                        textStyle:
                                                                            TextStyle(
                                                                          color:
                                                                              Colors.white,
                                                                          fontSize:
                                                                              15,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                          ],
                                                        ),
                                                      ),
                                                      Container(
                                                        margin: const EdgeInsets
                                                            .all(10.0),
                                                        child: Column(
                                                          children: [
                                                            Text(
                                                              "Rent",
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: GoogleFonts
                                                                  .roboto(
                                                                textStyle:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 20,
                                                                ),
                                                              ),
                                                            ),
                                                            snapshot.data[country]
                                                                        [
                                                                        'rent'] !=
                                                                    null
                                                                ? Container(
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              30),
                                                                      color: Colors
                                                                              .blueAccent[
                                                                          100],
                                                                    ),
                                                                    child:
                                                                        Column(
                                                                      children: [
                                                                        for (var provider
                                                                            in snapshot.data[country]['rent'])
                                                                          new Row(
                                                                            children: [
                                                                              Flexible(
                                                                                flex: 2,
                                                                                child: Text(
                                                                                  "${provider['provider_name']}",
                                                                                  //textScaleFactor: 2,
                                                                                  textAlign: TextAlign.center,
                                                                                  style: GoogleFonts.roboto(
                                                                                    textStyle: TextStyle(
                                                                                      color: Colors.white,
                                                                                      fontSize: 15,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              GestureDetector(
                                                                                onTap: () {
                                                                                  _launchURL(providerLink(provider['provider_name']));
                                                                                },
                                                                                child: ClipRRect(
                                                                                  borderRadius: BorderRadius.circular(40),
                                                                                  child: Image(
                                                                                    height: 30,
                                                                                    alignment: Alignment.centerRight,
                                                                                    image: NetworkImage('https://image.tmdb.org/t/p/w500/${provider['logo_path']}'),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                      ],
                                                                    ),
                                                                  )
                                                                : Container(
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              30),
                                                                      color: Colors
                                                                              .blueAccent[
                                                                          100],
                                                                    ),
                                                                    child: Text(
                                                                      "There isn't any known provider to rent in $countryName.",
                                                                      //textScaleFactor: 2,
                                                                      textAlign:
                                                                          TextAlign
                                                                              .left,
                                                                      style: GoogleFonts
                                                                          .roboto(
                                                                        textStyle:
                                                                            TextStyle(
                                                                          color:
                                                                              Colors.white,
                                                                          fontSize:
                                                                              15,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                          ],
                                                        ),
                                                      ),
                                                      Container(
                                                        margin: const EdgeInsets
                                                            .all(10.0),
                                                        child: Column(
                                                          children: [
                                                            Text(
                                                              "Buy",
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: GoogleFonts
                                                                  .roboto(
                                                                textStyle:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 20,
                                                                ),
                                                              ),
                                                            ),
                                                            snapshot.data[country]
                                                                        [
                                                                        'buy'] !=
                                                                    null
                                                                ? Container(
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              30),
                                                                      color: Colors
                                                                              .blueAccent[
                                                                          100],
                                                                    ),
                                                                    child:
                                                                        Column(
                                                                      children: [
                                                                        for (var provider
                                                                            in snapshot.data[country]['buy'])
                                                                          new Row(
                                                                            children: [
                                                                              Flexible(
                                                                                flex: 2,
                                                                                child: Text(
                                                                                  "${provider['provider_name']}",
                                                                                  //textScaleFactor: 2,
                                                                                  textAlign: TextAlign.center,
                                                                                  style: GoogleFonts.roboto(
                                                                                    textStyle: TextStyle(
                                                                                      color: Colors.white,
                                                                                      fontSize: 15,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              GestureDetector(
                                                                                onTap: () {
                                                                                  _launchURL(providerLink(provider['provider_name']));
                                                                                },
                                                                                child: ClipRRect(
                                                                                  borderRadius: BorderRadius.circular(40),
                                                                                  child: Image(
                                                                                    height: 30,
                                                                                    alignment: Alignment.centerRight,
                                                                                    image: NetworkImage('https://image.tmdb.org/t/p/w500/${provider['logo_path']}'),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                      ],
                                                                    ),
                                                                  )
                                                                : Container(
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              30),
                                                                      color: Colors
                                                                              .blueAccent[
                                                                          100],
                                                                    ),
                                                                    child: Text(
                                                                      "There isn't any known provider to buy in $countryName.",
                                                                      //textScaleFactor: 2,
                                                                      textAlign:
                                                                          TextAlign
                                                                              .left,
                                                                      style: GoogleFonts
                                                                          .roboto(
                                                                        textStyle:
                                                                            TextStyle(
                                                                          color:
                                                                              Colors.white,
                                                                          fontSize:
                                                                              15,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  )
                                                : Container(
                                                    margin:
                                                        const EdgeInsets.all(
                                                            15.0),
                                                    child: Text(
                                                      "There isn't any known provider in $countryName.",
                                                      style: GoogleFonts.roboto(
                                                        textStyle: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                      ),
                                      Flexible(
                                        flex: 2,
                                        child: Column(
                                          children: [
                                            Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5.0),
                                              child: Column(
                                                children: [
                                                  Text(
                                                    "Date",
                                                    textAlign: TextAlign.center,
                                                    style: GoogleFonts.roboto(
                                                      textStyle: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 20,
                                                      ),
                                                    ),
                                                  ),
                                                  (widget.movie.year != null)
                                                      ? Text(
                                                          "${widget.movie.year}",
                                                          //textScaleFactor: 2,
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: GoogleFonts
                                                              .roboto(
                                                            textStyle:
                                                                TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 15,
                                                            ),
                                                          ),
                                                        )
                                                      : Text(
                                                          "Unknown",
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: GoogleFonts
                                                              .roboto(
                                                            textStyle:
                                                                TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 15,
                                                            ),
                                                          ),
                                                        ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5.0),
                                              child: Column(
                                                children: [
                                                  Text(
                                                    "imdbRating",
                                                    textAlign: TextAlign.center,
                                                    style: GoogleFonts.roboto(
                                                      textStyle: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 20,
                                                      ),
                                                    ),
                                                  ),
                                                  (widget.movie.imdbRating !=
                                                          null)
                                                      ? Text(
                                                          "${widget.movie.imdbRating}",
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: GoogleFonts
                                                              .roboto(
                                                            textStyle:
                                                                TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 15,
                                                            ),
                                                          ),
                                                        )
                                                      : Text(
                                                          "Unknown",
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: GoogleFonts
                                                              .roboto(
                                                            textStyle:
                                                                TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 15,
                                                            ),
                                                          ),
                                                        ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5.0),
                                              child: Column(
                                                children: [
                                                  Text(
                                                    "Type",
                                                    textAlign: TextAlign.center,
                                                    style: GoogleFonts.roboto(
                                                      textStyle: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 20,
                                                      ),
                                                    ),
                                                  ),
                                                  (widget.movie.type != null)
                                                      ? Text(
                                                          "${widget.movie.type}",
                                                          //textScaleFactor: 2,
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: GoogleFonts
                                                              .roboto(
                                                            textStyle:
                                                                TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 15,
                                                            ),
                                                          ),
                                                        )
                                                      : Text(
                                                          "Unknown",
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: GoogleFonts
                                                              .roboto(
                                                            textStyle:
                                                                TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 15,
                                                            ),
                                                          ),
                                                        ),
                                                ],
                                              ),
                                            ),
                                            (widget.movie.type == 'tv')
                                                ? Container(
                                                    margin: const EdgeInsets
                                                            .symmetric(
                                                        vertical: 5.0),
                                                    child: Column(
                                                      children: [
                                                        Text(
                                                          "Binge",
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: GoogleFonts
                                                              .roboto(
                                                            textStyle:
                                                                TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 20,
                                                            ),
                                                          ),
                                                        ),
                                                        (snapshot.data[
                                                                    'binge'] !=
                                                                null)
                                                            ? Text(
                                                                "${minuteConvert(snapshot.data['binge'])}",
                                                                //textScaleFactor: 2,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style:
                                                                    GoogleFonts
                                                                        .roboto(
                                                                  textStyle:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        15,
                                                                  ),
                                                                ),
                                                              )
                                                            : Text(
                                                                "Unknown",
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style:
                                                                    GoogleFonts
                                                                        .roboto(
                                                                  textStyle:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        15,
                                                                  ),
                                                                ),
                                                              ),
                                                      ],
                                                    ),
                                                  )
                                                : Container(
                                                    margin: const EdgeInsets
                                                            .symmetric(
                                                        vertical: 5.0),
                                                    child: Column(
                                                      children: [
                                                        Text(
                                                          "Duration",
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: GoogleFonts
                                                              .roboto(
                                                            textStyle:
                                                                TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 20,
                                                            ),
                                                          ),
                                                        ),
                                                        (snapshot.data[
                                                                    'run_time'] !=
                                                                null)
                                                            ? Text(
                                                                "${minuteConvert(snapshot.data['run_time'])}",
                                                                //textScaleFactor: 2,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style:
                                                                    GoogleFonts
                                                                        .roboto(
                                                                  textStyle:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        15,
                                                                  ),
                                                                ),
                                                              )
                                                            : Text(
                                                                "Unknown",
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style:
                                                                    GoogleFonts
                                                                        .roboto(
                                                                  textStyle:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        15,
                                                                  ),
                                                                ),
                                                              ),
                                                      ],
                                                    ),
                                                  )
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                })),
                        new Container(
                          margin: const EdgeInsets.all(10.0),
                          padding: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.blueAccent[100],
                          ),
                          child: Column(
                            children: [
                              Text(
                                "Plot",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.roboto(
                                  textStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              Text(
                                "${widget.movie.plot}",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.roboto(
                                  textStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          Container(
            alignment: Alignment.bottomCenter,
            child: Yodo1MASBannerAd(
              size: BannerSize.Banner,
              onLoad: () => print('Banner loaded:'),
              onOpen: () => print('Banner clicked:'),
              onClosed: () => print('Banner clicked:'),
              onLoadFailed: (message) =>
                  print('Movie Banner Ad Load Failed : $message'),
              onOpenFailed: (message) =>
                  print('Movie Banner Ad Load Failed : $message'),
            ),
          ),
        ],
      ),
    );
  }
}
