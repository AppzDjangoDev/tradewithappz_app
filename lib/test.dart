import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:animate_do/animate_do.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    });

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            Icon(Icons.flash_on, size: 100, color: Colors.blue),
            SizedBox(height: 20),
            Text('Welcome to Option Chain', style: TextStyle(fontSize: 24)),
          ],
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: <Widget>[
              Container(
                height: 400,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/background.png'),
                    fit: BoxFit.fill
                  )
                ),
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      left: 30,
                      width: 80,
                      height: 200,
                      child: FadeInUp(duration: Duration(seconds: 1), child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/light-1.png')
                          )
                        ),
                      )),
                    ),
                    Positioned(
                      left: 140,
                      width: 80,
                      height: 150,
                      child: FadeInUp(duration: Duration(milliseconds: 1200), child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/light-2.png')
                          )
                        ),
                      )),
                    ),
                    Positioned(
                      right: 40,
                      top: 40,
                      width: 80,
                      height: 150,
                      child: FadeInUp(duration: Duration(milliseconds: 1300), child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/clock.png')
                          )
                        ),
                      )),
                    ),
                    Positioned(
                      child: FadeInUp(duration: Duration(milliseconds: 1600), child: Container(
                        margin: EdgeInsets.only(top: 50),
                        // child: Center(
                        //   child: Text("Login", style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),),
                        // ),
                      )),
                    )
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(30.0),
                child: Column(
                  children: <Widget>[
                    FadeInUp(duration: Duration(milliseconds: 1800), child: Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Color.fromRGBO(143, 148, 251, 1)),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromRGBO(143, 148, 251, .2),
                            blurRadius: 20.0,
                            offset: Offset(0, 10)
                          )
                        ]
                      ),
                      child: Column(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              border: Border(bottom: BorderSide(color:  Color.fromRGBO(143, 148, 251, 1)))
                            ),
                            child: TextField(
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Email or Phone number",
                                hintStyle: TextStyle(color: Colors.grey[700])
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(8.0),
                            child: TextField(
                              obscureText: true,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Password",
                                hintStyle: TextStyle(color: Colors.grey[700])
                              ),
                            ),
                          )
                        ],
                      ),
                    )),
                    SizedBox(height: 30,),
                    FadeInUp(duration: Duration(milliseconds: 1900), child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(
                          colors: [
                            Color.fromRGBO(143, 148, 251, 1),
                            Color.fromRGBO(143, 148, 251, .6),
                          ]
                        )
                      ),
                      // child: Center(
                      //   child: Text("Login", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                      // ),
                    )),
                    SizedBox(height: 70,),
                    FadeInUp(duration: Duration(milliseconds: 2000), child: Text("Forgot Password?", style: TextStyle(color: Color.fromRGBO(143, 148, 251, 1)),)),
                  ],
                ),
              )
            ],
          ),
        ),
      )
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static const List<String> _titles = [
    'DASHBOARD',
    'MIDCPNIFTY',
    'FINNIFTY',
    'BANKNIFTY',
    'NIFTY',
    'CONTROLS',
  ];

  static const List<List<CardInfo>> _cardInfos = [
    dashBoardCardInfo,
    MIDCPNIFTYCardInfo,
    finniftyCardInfo,
    bankNiftyCardInfo,
    niftyCardInfo,
    controlsCardInfo,
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.cast),
        title: Text(_titles[_selectedIndex]),
        actions: const <Widget>[
          Padding(
            padding: EdgeInsetsDirectional.only(end: 16.0),
            child: CircleAvatar(child: Icon(Icons.account_circle)),
          ),
        ],
      ),
      body: CarouselExample(cardInfos: _cardInfos[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'HOME',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'MIDCPNIFTY',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: 'FINNIFTY',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance),
            label: 'BANKNIFTY',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'NIFTY',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'CONTROLS',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}

class CarouselExample extends StatelessWidget {
  const CarouselExample({super.key, required this.cardInfos});

  final List<CardInfo> cardInfos;

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;

    return Column(
      children: <Widget>[
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: height / 1),
          child: CarouselSlider(
            options: CarouselOptions(
              height: height / 6,
              viewportFraction: 0.95,
              enlargeCenterPage: true,
            ),
            items: cardInfos.map((CardInfo info) {
              return Builder(
                builder: (BuildContext context) {
                  return HeroLayoutCard(cardInfo: info);
                },
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

class HeroLayoutCard extends StatelessWidget {
  const HeroLayoutCard({
    super.key,
    required this.cardInfo,
  });

  final CardInfo cardInfo;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    return Container(
      width: width * 0.95,
      color: Colors.lightBlue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              cardInfo.title,
              overflow: TextOverflow.clip,
              softWrap: false,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: const Color.fromARGB(255, 73, 75, 76)),
            ),
            const SizedBox(height: 5),
            Text(
              cardInfo.subtitle,
              overflow: TextOverflow.clip,
              softWrap: false,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Color.fromARGB(255, 15, 174, 71)),
            ),
          ],
        ),
      ),
    );
  }
}

enum CardInfo {
  dashBoard('Index : Dashboard', 'Dashboard Overview status'),
  MIDCPNIFTY('Index : MIDCPNIFTY', 'Running : 42000'),
  finnifty('Index : FINNIFTY', 'Running : 34000'),
  bankNifty('Index : BANKNIFTY', 'Running : 52000'),
  nifty('Index : NIFTY', 'Running : 16000'),
  portfolio('Portfolio : 25000', 'order Qty : 10');

  const CardInfo(this.title, this.subtitle);
  final String title;
  final String subtitle;
}

const dashBoardCardInfo = [
  CardInfo.dashBoard,
  CardInfo.portfolio,
];

const MIDCPNIFTYCardInfo = [
  CardInfo.MIDCPNIFTY,
  CardInfo.portfolio,
];

const finniftyCardInfo = [
  CardInfo.finnifty,
  CardInfo.portfolio,
];

const bankNiftyCardInfo = [
  CardInfo.bankNifty,
  CardInfo.portfolio,
];

const niftyCardInfo = [
  CardInfo.nifty,
  CardInfo.portfolio,
];

const controlsCardInfo = [
  CardInfo.portfolio,
];
