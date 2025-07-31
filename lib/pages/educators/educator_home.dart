import 'package:carousel_slider/carousel_slider.dart';
import 'detention_log.dart';
import 'educator_student_log_queries.dart';
import 'scan_id.dart';
import '../students/agenda.dart';
import 'components/educator_my_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../themes/theme_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  runApp(const MyAdminHomePage());
}

class MyAdminHomePage extends StatelessWidget {
  const MyAdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home - Educator/Admin',
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeProvider>(context).themeData,
      home: const AdminHomePage(),
    );
  }
}

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Alignment> _topAlignmentAnimation;
  late Animation<Alignment> _bottomAlignmentAnimation;

  @override
  void initState() {
    super.initState();

    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 4));
    _topAlignmentAnimation = TweenSequence<Alignment>([
      TweenSequenceItem<Alignment>(
        tween:
            Tween<Alignment>(begin: Alignment.topLeft, end: Alignment.topRight),
        weight: 1,
      ),
      TweenSequenceItem<Alignment>(
        tween: Tween<Alignment>(
            begin: Alignment.topRight, end: Alignment.bottomRight),
        weight: 1,
      ),
      TweenSequenceItem<Alignment>(
        tween: Tween<Alignment>(
            begin: Alignment.bottomRight, end: Alignment.bottomLeft),
        weight: 1,
      ),
      TweenSequenceItem<Alignment>(
        tween: Tween<Alignment>(
            begin: Alignment.bottomLeft, end: Alignment.topLeft),
        weight: 1,
      )
    ]).animate(_animationController);

    _bottomAlignmentAnimation = TweenSequence<Alignment>([
      TweenSequenceItem<Alignment>(
        tween: Tween<Alignment>(
            begin: Alignment.bottomRight, end: Alignment.bottomLeft),
        weight: 1,
      ),
      TweenSequenceItem<Alignment>(
        tween: Tween<Alignment>(
            begin: Alignment.bottomLeft, end: Alignment.topLeft),
        weight: 1,
      ),
      TweenSequenceItem<Alignment>(
        tween:
            Tween<Alignment>(begin: Alignment.topLeft, end: Alignment.topRight),
        weight: 1,
      ),
      TweenSequenceItem<Alignment>(
        tween: Tween<Alignment>(
            begin: Alignment.topRight, end: Alignment.bottomRight),
        weight: 1,
      )
    ]).animate(_animationController);

    _animationController.repeat();
  }

  @override
  void dispose() {
    FirebaseAuth.instance.signOut();
    _animationController.dispose();
    super.dispose();
  }

  List<String> images = [
    "lib/assets/img/erhs_logo.png",
    "lib/assets/img/hpage3.jpeg",
    "lib/assets/img/hpage2.jpeg",
  ];

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const ScanPage()));
        },
        backgroundColor: Colors.transparent,
        child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, _) {
              return Container(
                width: 75,
                height: 75,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.5),
                    gradient: LinearGradient(
                        colors: const [
                          Color.fromRGBO(17, 93, 223, 1),
                          Color.fromRGBO(68, 17, 194, 1),
                        ],
                        begin: _topAlignmentAnimation.value,
                        end: _bottomAlignmentAnimation.value)),
                child: const Icon(
                  Icons.barcode_reader,
                  color: Colors.white,
                ),
              );
            }),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      drawer: const EducatorMyDrawer(),
      body: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Center(
          child: Column(children: [
            Container(
              decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [
                Color.fromRGBO(38, 99, 202, 1),
                Color.fromRGBO(20, 40, 75, 1)
              ])),
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
                actions: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: GestureDetector(
                      onTap: () {
                        signUserOut();
                      },
                      child: const Icon(
                        Icons.logout,
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              ),
            ),
            Center(
              child: Stack(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 75,
                    decoration: const BoxDecoration(
                        gradient: LinearGradient(colors: [
                      Color.fromRGBO(38, 99, 202, 1),
                      Color.fromRGBO(20, 40, 75, 1)
                    ])),
                  ),
                  Stack(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 75,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: const LinearGradient(colors: [
                              Color.fromRGBO(200, 140, 20, 1),
                              Color.fromRGBO(173, 58, 37, 1)
                            ])),
                        child: Stack(
                          children: [
                            Transform.translate(
                              offset: const Offset(0, -45),
                              child: Center(
                                child: AppBar(
                                  automaticallyImplyLeading: true,
                                  backgroundColor: Colors.transparent,
                                  title: Stack(
                                    children: [
                                      Transform.translate(
                                        offset: Offset(0, 5),
                                        child: Text(
                                          "Welcome, Educator",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20.0,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Transform.translate(
                        offset: const Offset(0, 45),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height / 1.15,
                          decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(20)),
                          child: Column(
                            children: [
                              Column(
                                children: [
                                  const SizedBox(height: 10.0),
                                  const SizedBox(
                                    height: 40.0,
                                    child: Text(
                                      "Be the BEST",
                                      style: TextStyle(fontSize: 30.0),
                                    ),
                                  ),
                                  const SizedBox(height: 10.0),
                                  CarouselSlider(
                                    options: CarouselOptions(
                                      height: 200.0,
                                    ),
                                    items: images.map((i) {
                                      return Builder(
                                        builder: (BuildContext context) {
                                          return Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 5.0),
                                            decoration: BoxDecoration(
                                                color: Colors.blue,
                                                borderRadius:
                                                    BorderRadius.circular(12)),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: Image.asset(
                                                i,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    }).toList(),
                                  ),
                                  const SizedBox(height: 25.0),
                                  OverflowBar(
                                    alignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        height: 75.0,
                                        width: 110.0,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(18.0),
                                            ),
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .tertiary,
                                          ),
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        AgendaApp()));
                                          },
                                          child: const SizedBox(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.timer),
                                                Text(
                                                  "Agenda",
                                                  textAlign: TextAlign.center,
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 50.0),
                                    ],
                                  ),
                                  OverflowBar(
                                    alignment: MainAxisAlignment.center,
                                    children: [
                                      const SizedBox(),
                                      SizedBox(
                                        height: 75.0,
                                        width: 110.0,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(18.0),
                                            ),
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .tertiary,
                                          ),
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        StudentCheckIn()));
                                          },
                                          child: const SizedBox(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.table_chart_rounded),
                                                Text("ID Log")
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 50.0),
                                      SizedBox(
                                        height: 75.0,
                                        width: 110.0,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(18.0),
                                            ),
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .tertiary,
                                          ),
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        DetentionLog()));
                                          },
                                          child: const SizedBox(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.table_chart_rounded),
                                                Text(
                                                  "Tardy Log",
                                                  style: TextStyle(
                                                      fontSize: 13.75),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
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
          ]),
        ),
      ),
    );
  }
}
