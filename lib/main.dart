import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'searchPage.dart';
import 'trends.dart';
import 'countries.dart';
import 'package:yodo1mas/testmasfluttersdktwo.dart';
import 'apiKey.dart';
import 'dart:developer';

void main() {
  runApp(Nav());
  yodoInit();
}

class Nav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(),
    );
  }
}

yodoInit() async {
  return Yodo1MAS.instance.init(appKey, true, (successful) {});
}

_launchURL(link) async {
  if (await canLaunch(link)) {
    await launch(link);
  } else {
    throw 'Could not launch $link';
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  late String _name;
  var _controller = TextEditingController();
  final passwordFocus = FocusNode();
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
  void initState() {
    super.initState();
    getAll();
  }

  void dispose() {
    passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.purple[200],
          appBar: AppBar(
            title: Text(
              'Home',
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                textStyle: TextStyle(
                  fontSize: 25,
                ),
              ),
            ),
            actions: <Widget>[
              (notList.contains(lower))
                  ? Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Countries()),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 30.0),
                          child: Text(
                            '$country',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                            ),
                          ),
                        ),
                      ),
                    )
                  : GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Countries()),
                        );
                      },
                      child: Container(
                          child: Image.network(
                              'https://flagcdn.com/w40/$lower.png')),
                    ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
            ),
            backgroundColor: Colors.blueAccent[100],
          ),
          body: Stack(
            children: [
              Container(
                alignment: Alignment.topCenter,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.blueAccent[100],
                  borderRadius: BorderRadius.circular(40),
                ),
                child: TextField(
                  controller: _controller,
                  autocorrect: false,
                  autofocus: false,
                  decoration: InputDecoration(
                    hintStyle: TextStyle(fontSize: 17, color: Colors.white),
                    hintText: 'Enter a movie/serie name',
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                    suffixIcon: IconButton(
                      color: Colors.white,
                      icon: Icon(Icons.clear),
                      onPressed: () => _controller.clear(),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(15),
                  ),
                  onSubmitted: (_item) {
                    passwordFocus.requestFocus();
                    setState(() {
                      _name = _item;
                    });
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Search(_name)),
                    );
                  },
                ),
              ),
              Container(
                child: Padding(
                  padding: const EdgeInsets.only(top: 55.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 60),
                          padding: const EdgeInsets.only(bottom: 60),
                          child: Trend(),
                        ),
                      ],
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
                      print('Main Banner Ad Load Failed : $message'),
                  onOpenFailed: (message) =>
                      print('Main Banner Ad Open Failed : $message'),
                ),
              ),
            ],
          ),
          drawer: Drawer(
            child: Container(
              // padding: EdgeInsets.only(top: 40),
              color: Colors.purple[200],
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  Container(
                    height: 75.0,
                    alignment: Alignment.topLeft,
                    //margin: EdgeInsets.all(5.0),
                    decoration: ShapeDecoration(
                      color: Colors.blueAccent[100],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(30),
                        ),
                      ),
                    ),
                    /*
                    child: Center(
                      child: Text(
                        'Menu',
                        textAlign: TextAlign.left,
                        style: GoogleFonts.roboto(
                          textStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            //fontWeight: FontWeight.w500,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                    ),
                    */
                  ),
                  Container(
                      margin: EdgeInsets.all(5.0),
                      padding: const EdgeInsets.all(5.0),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent[100],
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              "wheretowatchfeedback@gmail.com",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.roboto(
                                textStyle: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  //fontWeight: FontWeight.w500,
                                  letterSpacing: 0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )),
                  Container(
                    margin: EdgeInsets.all(5.0),
                    padding: const EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent[100],
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Linkedin',
                          textAlign: TextAlign.left,
                          style: GoogleFonts.roboto(
                            textStyle: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              //fontWeight: FontWeight.w500,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                        Flexible(
                          child: GestureDetector(
                            onTap: () {
                              _launchURL(
                                  'https://www.linkedin.com/in/berkeahlatci');
                            },
                            child: Image.asset(
                              'assets/images/linkedn.png',
                              height: 30,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Flex(
                    direction: Axis.horizontal,
                    children: [
                      Flexible(
                        child: Container(
                          margin: EdgeInsets.all(5.0),
                          padding: EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent[100],
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: Column(
                            children: [
                              Center(
                                child: Text(
                                  "Powered by ",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.roboto(
                                    textStyle: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      //fontWeight: FontWeight.w500,
                                      letterSpacing: 0,
                                    ),
                                  ),
                                ),
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5.0),
                                      child: GestureDetector(
                                        onTap: () {
                                          _launchURL(
                                              'https://www.themoviedb.org');
                                        },
                                        child: Image.asset(
                                          'assets/images/tmdb.png',
                                        ),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "&",
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  Flexible(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5.0),
                                      child: GestureDetector(
                                        onTap: () {
                                          _launchURL(
                                              'https://www.justwatch.com');
                                        },
                                        child: Image.asset(
                                          'assets/images/justwatch.png',
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
