import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  //FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Track the clickable state of each button
  List<bool> _isButtonClickableList = [];
  //create an instance to acces firestore
  var db = FirebaseFirestore.instance;
  bool _isdataLoaded = false;
  static List<Map<String, dynamic>> confirmedProducts = [];
  bool _isStarted = false;
  bool isdataFromFirebase = false;
  List<Map<String, dynamic>> packagesList = [
    {
      'Label': 'Product1',
      'initialQuantity': 10,
      'deliveredQuantity': 0,
      "sended": false
    },
    {
      'Label': 'Product2',
      'initialQuantity': 10,
      'deliveredQuantity': 0,
      "sended": false
    },
    {
      'Label': 'Product3',
      'initialQuantity': 10,
      'deliveredQuantity': 0,
      "sended": false
    },
    {
      'Label': 'Product4',
      'initialQuantity': 10,
      'deliveredQuantity': 0,
      "sended": false
    },
    {
      'Label': 'Product5',
      'initialQuantity': 10,
      'deliveredQuantity': 0,
      "sended": false
    }
  ];
  // Delete a collection
  Future<void> deleteCollection(String collectionName) async {
    var collectionRef = FirebaseFirestore.instance.collection(collectionName);

    var querySnapshot = await collectionRef.get();
    for (var documentSnapshot in querySnapshot.docs) {
      await documentSnapshot.reference.delete();
    }

    print('Collection deleted: $collectionName');
  }

  int incrementDelivered(deliveredCount) {
    setState(() {
      if (deliveredCount < 10) {
        deliveredCount++;
      }
    });
    return deliveredCount;
  }

  int decrementDelivered(deliveredCount) {
    setState(() {
      if (deliveredCount > 0) {
        deliveredCount--;
      }
    });
    return deliveredCount;
  }

  //get data within a collection from firestore
  Future<void> getdataFromFirestore1() async {
    await db.collection("products").get().then((event) {
      if (event.docs.length > 0) {
        for (var i = 0; i < event.docs.length; i++) {
          setState(() {
            packagesList[i] = event.docs[i].data();
          });
          print("${event.docs[i].id} => ${event.docs[i].data()}");
        }
      }
    }).then((value) {
      _isButtonClickableList = List<bool>.filled(packagesList.length, true);
      if (_isButtonClickableList.length == packagesList.length) {
        setState(() {
          _isdataLoaded = true;
        });
      }
      ;
    });
  }

  @override
  void initState() {
    getdataFromFirestore1();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(133, 255, 255, 255),
      appBar: AppBar(
        title: Text("Save Process Data"),
      ),
      body: _isdataLoaded
          ? SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * .8,
              child: Column(
                children: [
                  Flexible(
                    child: ListView.builder(
                      itemCount: packagesList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Card(
                          child: Column(
                            children: <Widget>[
                              ListTile(
                                title: Center(
                                  child: Text(
                                    'Initial quantity',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                subtitle: Center(
                                    child: Text(
                                  "${packagesList[index]["initialQuantity"]}",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                )),
                              ),
                              Divider(
                                thickness: 5,
                                endIndent: 20,
                                indent: 20,
                                color: Colors.black,
                              ),
                              Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: Text(
                                        "Delivered quantity:",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.remove),
                                      onPressed: () {
                                        packagesList[index]
                                                ["deliveredQuantity"] =
                                            decrementDelivered(
                                                packagesList[index]
                                                    ["deliveredQuantity"]);
                                      },
                                    ),
                                    SizedBox(width: 16.0),
                                    Text(
                                      packagesList[index]["deliveredQuantity"]
                                          .toString(),
                                      style: TextStyle(fontSize: 20.0),
                                    ),
                                    SizedBox(width: 16.0),
                                    IconButton(
                                      icon: Icon(Icons.add),
                                      onPressed: () {
                                        packagesList[index]
                                                ["deliveredQuantity"] =
                                            incrementDelivered(
                                                packagesList[index]
                                                    ["deliveredQuantity"]);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 12),
                                child: ElevatedButton(
                                  onPressed:
                                      packagesList[index]["sended"] == false
                                          ? () async {
                                              setState(() {
                                                packagesList[index]["sended"] =
                                                    true;
                                              });
                                              db
                                                  .collection("products")
                                                  .doc('product$index')
                                                  .set(packagesList[index]);
                                            }
                                          : null,
                                  child: Text("Send"),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            )
          : Container(
              color: Colors.white,
              child: Center(
                child: CircularProgressIndicator(),
              )),
      bottomSheet: Row(children: [
        SizedBox(width: 30),
        ElevatedButton(
            onPressed: _isStarted
                ? null
                : () {
                    setState(() {
                      _isStarted = true;
                    });
                  },
            child: Text("Start")),
        SizedBox(
          width: 200,
        ),
        ElevatedButton(
            onPressed: () {
              deleteCollection("products").then((value) {
                setState(() {
                  _isdataLoaded = false;
                  getdataFromFirestore1().then((value) {
                    _isdataLoaded = true;
                    setState(() {
                      packagesList = [
                        {
                          'Label': 'Product1',
                          'initialQuantity': 10,
                          'deliveredQuantity': 0,
                          "sended": false
                        },
                        {
                          'Label': 'Product2',
                          'initialQuantity': 10,
                          'deliveredQuantity': 0,
                          "sended": false
                        },
                        {
                          'Label': 'Product3',
                          'initialQuantity': 10,
                          'deliveredQuantity': 0,
                          "sended": false
                        },
                        {
                          'Label': 'Product4',
                          'initialQuantity': 10,
                          'deliveredQuantity': 0,
                          "sended": false
                        },
                        {
                          'Label': 'Product5',
                          'initialQuantity': 10,
                          'deliveredQuantity': 0,
                          "sended": false
                        }
                      ];
                    });
                  });
                });
              });
            },
            child: Text("Done")),
      ]),
    );
  }
}
