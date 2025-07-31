import 'package:carousel_slider/carousel_slider.dart';
import 'agenda.dart';
import 'components/my_drawer.dart';
import 'tutors.dart';
import 'tutor_chat_list_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../themes/theme_provider.dart';
import 'id.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  runApp(const MyStudentHomePage());
}

class MyStudentHomePage extends StatelessWidget {
  const MyStudentHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home - Student',
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeProvider>(context).themeData,
      home: const StudentHomePage(),
    );
  }
}

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Alignment> _topAlignmentAnimation;
  late Animation<Alignment> _bottomAlignmentAnimation;

  @override
  void dispose() {
    FirebaseAuth.instance.signOut();
    _animationController.dispose();
    super.dispose();
  }

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
    return PopScope(
      canPop: false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const MyIdPage()));
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
                            Color(0xffF99E43),
                            Color(0xFFDA2323),
                          ],
                          begin: _topAlignmentAnimation.value,
                          end: _bottomAlignmentAnimation.value)),
                  child: const Icon(
                    Icons.perm_identity_sharp,
                    color: Colors.white,
                  ),
                );
              }),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        drawer: const MyDrawer(),
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
                          height: 90,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: const LinearGradient(colors: [
                                Color.fromRGBO(200, 140, 20, 1),
                                Color.fromRGBO(173, 58, 37, 1)
                              ])),
                          child: Stack(
                            children: [
                              // const Padding(
                              //   padding: EdgeInsets.only(left: 16.0, top:12.65),
                              //   child: Icon(
                              //     Icons.format_align_justify_sharp
                              //   ),
                              // ),
                              // const Padding(
                              //   padding: EdgeInsets.only(left: 16.0, top:12.65),
                              //   child: Icon(
                              //     Icons.format_align_justify_sharp
                              //   ),
                              // ),
                              Transform.translate(
                                offset: const Offset(0, -47.5),
                                child: Center(
                                  child: AppBar(
                                    automaticallyImplyLeading: true,
                                    backgroundColor: Colors.transparent,
                                    title: Transform.translate(
                                      offset: const Offset(0, 5),
                                      child: Stack(
                                        children: [
                                          Transform.translate(
                                            offset: const Offset(0, -5),
                                            child: Text(
                                              "Welcome, Student",
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
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 5.0),
                                              decoration: BoxDecoration(
                                                  color: Colors.blue,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12)),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12.0),
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
                                      alignment: MainAxisAlignment.spaceEvenly,
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
                                      ],
                                    ),
                                    OverflowBar(
                                      alignment: MainAxisAlignment.spaceEvenly,
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
                                                          Tutors()));
                                            },
                                            child: const SizedBox(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.book_online),
                                                  Text("Tutoring")
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
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
                                                          TutorChatListPage()));
                                            },
                                            child: const SizedBox(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.book_online),
                                                  Text("Tutoring Chat")
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
      ),
    );
  }
}
