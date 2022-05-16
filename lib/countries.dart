import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'apiKey.dart';
import 'main.dart';

var country = "", countryName = "", lower = "";

final List<String> notList = ['an', 'cs', 'su', 'xg', 'yu', 'xc'];

class Countries extends StatefulWidget {
  @override
  _CountryState createState() => _CountryState();
}

class _CountryState extends State<Countries> {
  getCountries() async {
    Uri url =
        "https://api.themoviedb.org/3/configuration/countries?api_key=$apiKey"
            as Uri;
    var response = await http.get(url);
    var result = jsonDecode(response.body);
    for (var country in notList) {
      result.removeWhere((item) => item['iso_3166_1'].toLowerCase() == country);
    }
    return result;
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.purple[200],
        appBar: AppBar(
          title: Text(
            'Countries',
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Home()),
              );
            },
            child: Icon(
              Icons.arrow_back_ios,
            ),
          ),
        ),
        body: Container(
          padding: const EdgeInsets.all(15.0),
          child: Center(
            child: FutureBuilder(
              future: getCountries(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (!snapshot.hasData || snapshot.data!.length == 0) {
                  return Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.blueAccent[100],
                      valueColor: new AlwaysStoppedAnimation<Color>(
                          Colors.purple[200]!),
                    ),
                  );
                }
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3),
                  shrinkWrap: true,
                  physics: BouncingScrollPhysics(),
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () {
                        addStringToSF(
                            snapshot.data[index]['iso_3166_1'],
                            snapshot.data[index]['english_name'],
                            snapshot.data[index]['iso_3166_1'].toLowerCase());
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Home()),
                        );
                      },
                      child: Column(
                        children: [
                          Container(
                            padding:
                                const EdgeInsets.symmetric(vertical: 10.00),
                            child: Column(
                              children: [
                                Image.network(
                                  ('https://flagcdn.com/w80/${snapshot.data[index]['iso_3166_1'].toLowerCase()}.png'),
                                ),
                                Text("${snapshot.data[index]['english_name']}"),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
