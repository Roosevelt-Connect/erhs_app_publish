import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_barcodes/barcodes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class MyIdPage extends StatelessWidget {
  const MyIdPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const IdPage(title: "Mustang ID");
  }
}

class IdPage extends StatefulWidget {
  const IdPage({super.key, required this.title});
  final String title;

  @override
  State<IdPage> createState() => _IdPageState();
}

class _IdPageState extends State<IdPage> {
  final user = FirebaseAuth.instance.currentUser!;
  String dropdownvalue = 'Off Campus';
  var items = [
    'Off Campus',
    'Event',
  ];

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color.fromRGBO(38, 99, 202, 1), Color.fromRGBO(20, 40, 75, 1)])
            ),
            child: AppBar(
              backgroundColor: Colors.transparent,
              centerTitle: true,
              automaticallyImplyLeading: false,
              toolbarHeight: 45,
              title: const Column(
                children: [
                  Text(
                    "ERHS Mustangs",
                    style: TextStyle(color: Colors.white, fontSize: 25.0),
                  )
                ],
              ),
            ),
          ),
          Center(
            child: Stack(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 75,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [Color.fromRGBO(38, 99, 202, 1), Color.fromRGBO(20, 40, 75, 1)])
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 75,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: const LinearGradient(colors: [Color.fromRGBO(200, 140, 20, 1), Color.fromRGBO(173, 58, 37, 1)])
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Transform.translate(
                      offset: const Offset(0, 45),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height/1.15,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(20)
                        ),
                        child: Column(
                          children: [
                            Transform.translate(
                              offset: const Offset(0, 60),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(DateFormat('yyyy-MM-dd – hh:mm a')
                                      .format(DateTime.now())),
                                ],
                              ),
                            ),
                            Transform.translate(
                              offset: const Offset(0, 150),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 300,
                                    height: 200,
                                    color: Colors.white,
                                    margin:
                                        const EdgeInsets.only(left: 20.0, right: 20.0),
                                    child: SfBarcodeGenerator(
                                      backgroundColor: Colors.white,
                                      value: user.email!.split("@students.cnusd.k12.ca.us")[0],
                                      showValue: true,
                                      textStyle: TextStyle(color: Colors.black),
                                      textSpacing: 15,
                                      barColor: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                color: Colors.transparent,
                                child: const Text(
                                  textAlign: TextAlign.center,
                                  "Digital ID",
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Color.fromARGB(
                                          243, 248, 248, 248)),
                                ),
                              ),
                            )
                          ],
                        ),
                        // IconButton for back navigation
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_outlined,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  }
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
