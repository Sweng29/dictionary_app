import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dictionary App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String url = "https://owlbot.info/api/v4/dictionary/";
  String token = " 2b46c91e0400f5dfecfffa60c8d6760d0244493f";

  TextEditingController _controller = TextEditingController();
  Stream _stream;
  StreamController _streamController;
  Timer _debounce;

  // THIS METHOD will hit API and provide response.
  _search() async {
    if (_controller.text == null || _controller.text.length == 0) {
      _streamController.add(null);
      return;
    }
    _streamController.add("waiting");
    Response response = await get(url + _controller.text.trim(),
        headers: {"Authorization": "Token " + token});
    _streamController.add(json.decode(response.body));
  }

  @override
  void initState() {
    super.initState();
    _streamController = StreamController();
    _stream = _streamController.stream;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('English Dictionary'),
        bottom: PreferredSize(
          child: Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 10.0, bottom: 10.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24.0),
                    color: Colors.white,
                  ),
                  child: TextFormField(
                    onChanged: (String text) {
                      if (_debounce?.isActive ?? false) _debounce.cancel();
                      _debounce =
                          Timer(const Duration(milliseconds: 1000), _search);
                    },
                    controller: _controller,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search a word here..',
                      contentPadding: EdgeInsets.only(left: 10.0),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.search,
                  color: Colors.white,
                ),
                onPressed: () {
                  _search();
                },
              ),
            ],
          ),
          preferredSize: Size.fromHeight(48.0),
        ),
      ),
      body: Container(
        margin: EdgeInsets.all(8.0),
        child: StreamBuilder(
          builder: (BuildContext ctxt, AsyncSnapshot snapshot) {
            if (snapshot.data == null) {
              return Center(
                child: Text('Please enter a word to search.'),
              );
            }

            if (snapshot.data == "waiting") {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.data != null) {
              return ListView.builder(
                itemCount: snapshot.data["definitions"].length,
                itemBuilder: (BuildContext ctxt, int index) {
                  return ListBody(
                    children: <Widget>[
                      Container(
                        color: Colors.grey[300],
                        child: ListTile(
                          leading: snapshot.data["definitions"][index]
                                      ["image_url"] ==
                                  null
                              ? null
                              : CircleAvatar(
                                  backgroundImage: NetworkImage(snapshot
                                      .data["definitions"][index]["image_url"]),
                                ),
                          title: Text(_controller.text.trim() +
                              "(" +
                              snapshot.data["definitions"][index]["type"] +
                              ")"),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                            snapshot.data["definitions"][index]["definition"]),
                      )
                    ],
                  );
                },
              );
            }
          },
          stream: _stream,
        ),
      ),
    );
  }
}
