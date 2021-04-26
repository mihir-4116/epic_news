import 'package:flutter/material.dart';
import 'package:news_app/helper/list_of_country.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:news_app/helper/article_news.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
toggleDrawer() async {
  if (_scaffoldKey.currentState.isDrawerOpen) {
    _scaffoldKey.currentState.openEndDrawer();
  } else {
    _scaffoldKey.currentState.openDrawer();
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User user;
  bool isloggedin = false;

  checkAuthentification() async {
    _auth.authStateChanges().listen((user) {
      if (user == null) {
        Navigator.of(context).pushReplacementNamed("start");
      }
    });
  }

  var newslist;
  var cName;
  var country;
  var catagory;
  var findNews;
  int pageNum = 1;
  bool isPageLoading = false;
  ScrollController controller;
  int pageSize = 10;
  bool isSwitched = false;
  List news = [];
  bool notFound = false;
  List<int> data = [];
  bool isLoading = false;
  String baseApi = "https://newsapi.org/v2/top-headlines?";
  @override
  void initState() {
    controller = new ScrollController()..addListener(_scrollListener);
    getNewsFromDrawer();
    super.initState();
  }

  _scrollListener() {
    if (controller.position.pixels == controller.position.maxScrollExtent) {
      setState(() {
        isLoading = true;
      });
      getNewsFromDrawer();
    }
  }

  getDataFromApi(url) async {
    http.Response res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) {
      if (jsonDecode(res.body)['totalResults'] == 0) {
        notFound = isLoading ? false : true;
        setState(() {
          isLoading = false;
        });
      } else {
        if (isLoading) {
          List newData = jsonDecode(res.body)['articles'];
          newData.forEach((e) {
            news.add(e);
          });
        } else {
          news = jsonDecode(res.body)['articles'];
        }
        setState(() {
          notFound = false;
          isLoading = false;
        });
      }
    } else {
      setState(() => notFound = true);
    }
  }

  getNewsFromDrawer({channel, searchKey, reload = false}) async {
    setState(() => notFound = false);

    if (!reload && !isLoading) {
      toggleDrawer();
    } else {
      country = null;
      catagory = null;
    }
    if (isLoading) {
      pageNum++;
    } else {
      setState(() {
        news = [];
      });
      pageNum = 1;
    }
    baseApi = "https://newsapi.org/v2/top-headlines?pageSize=10&page=$pageNum&";

    baseApi += country == null ? 'country=in&' : 'country=$country&';
    baseApi += catagory == null ? '' : 'category=$catagory&';
    baseApi += 'apiKey=a5d7261ca509488e8bbc009c3a8bb932';
    if (channel != null) {
      country = null;
      catagory = null;
      baseApi =
          "https://newsapi.org/v2/top-headlines?pageSize=10&page=$pageNum&sources=$channel&apiKey=a5d7261ca509488e8bbc009c3a8bb932";
    }
    if (searchKey != null) {
      country = null;
      catagory = null;
      baseApi =
          "https://newsapi.org/v2/top-headlines?pageSize=10&page=$pageNum&q=$searchKey&apiKey=a5d7261ca509488e8bbc009c3a8bb932";
    }
    print(baseApi);
    getDataFromApi(baseApi);
  }

  signOut() async {
    _auth.signOut();

    final googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'News',
      theme: isSwitched ? ThemeData.light() : ThemeData.dark(),
      home: Scaffold(
        key: _scaffoldKey,
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.symmetric(vertical: 60),
            children: <Widget>[
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    country != null ? Text("Country = $cName") : Container(),
                    SizedBox(height: 10),
                    catagory != null
                        ? Text("Catagory = $catagory")
                        : Container(),
                    SizedBox(height: 20),
                  ],
                ),
              ),
              Container(
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                          padding: EdgeInsets.only(left: 5),
                          child: Text(
                            'Welcome to epic_news',
                            style: TextStyle(
                              fontSize: 25,
                              color: Colors.deepOrange,
                            ),
                            textAlign: TextAlign.center,
                          )),
                    ),
                  ],
                ),
              ),
              ExpansionTile(
                title: Text("Country"),
                children: <Widget>[
                  for (int i = 0; i < listOfCountry.length; i++)
                    DropDownList(
                      call: () {
                        country = listOfCountry[i]['code'];
                        cName = listOfCountry[i]['name'].toUpperCase();
                        getNewsFromDrawer();
                      },
                      name: listOfCountry[i]['name'].toUpperCase(),
                    ),
                ],
              ),
              ExpansionTile(
                title: Text("Catagory"),
                children: [
                  for (int i = 0; i < listOfCatagory.length; i++)
                    DropDownList(
                        call: () {
                          catagory = listOfCatagory[i]['code'];
                          getNewsFromDrawer();
                        },
                        name: listOfCatagory[i]['name'].toUpperCase())
                ],
              ),
              ExpansionTile(
                title: Text("Channel"),
                children: [
                  for (int i = 0; i < listOfNewsChannel.length; i++)
                    DropDownList(
                      call: () {
                        getNewsFromDrawer(
                            channel: listOfNewsChannel[i]['code']);
                      },
                      name: listOfNewsChannel[i]['name'].toUpperCase(),
                    ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              RaisedButton(
                padding: EdgeInsets.fromLTRB(70, 10, 70, 10),
                onPressed: signOut,
                child: Text('Signout',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold)),
                color: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              ListTile(
                title: Text("Exit"),
                onTap: () => exit(0),
              ),
            ],
          ),
        ),
        appBar: AppBar(
          centerTitle: true,
          title: Text("epic_news"),
          // backgroundColor: Colors.lightBlue,
          actions: [
            IconButton(
                onPressed: () {
                  country = null;
                  catagory = null;
                  findNews = null;
                  cName = null;
                  getNewsFromDrawer(reload: true);
                },
                icon: Icon(
                  Icons.refresh_outlined,
                  size: 25,
                )),
            Switch(
              value: isSwitched,
              onChanged: (value) => setState(() => isSwitched = value),
              activeTrackColor: Colors.orangeAccent,
              activeColor: Colors.blueGrey,
            ),
          ],
        ),
        body: notFound
            ? Center(
                child: Text(
                  "Not Found",
                  style: TextStyle(fontSize: 30),
                ),
              )
            : news.length == 0
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: controller,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(7),
                            child: Card(
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25)),
                              child: GestureDetector(
                                onTap: () async {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ArticalNews(
                                          newsUrl: news[index]['url']),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 15),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30)),
                                  child: Column(
                                    children: [
                                      Stack(children: [
                                        news[index]['urlToImage'] == null
                                            ? Container()
                                            : ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(25),
                                                child: CachedNetworkImage(
                                                  placeholder: (context, url) =>
                                                      Container(
                                                          child:
                                                              CircularProgressIndicator()),
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          Icon(Icons.error),
                                                  imageUrl: news[index]
                                                      ['urlToImage'],
                                                ),
                                              ),
                                        Positioned(
                                          bottom: 10,
                                          right: 20,
                                          child: Text(
                                            "${news[index]['source']['name']}",
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ]),
                                      Divider(),
                                      Text(
                                        "${news[index]['title']}",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          index == news.length - 1 && isLoading
                              ? Center(child: CircularProgressIndicator())
                              : SizedBox(),
                        ],
                      );
                    },
                    itemCount: news.length,
                  ),
      ),
    );
  }
}

class DropDownList extends StatelessWidget {
  final String name;
  final Function call;

  const DropDownList({@required this.name, @required this.call});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: ListTile(title: Text(name)),
      onTap: () => call(),
    );
  }
}
