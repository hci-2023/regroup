import 'package:flutter/material.dart';
import 'package:regroup/views/register_page.dart';
import 'package:flutter/foundation.dart';
import 'package:introduction_screen/introduction_screen.dart';

class Intro extends StatefulWidget {
  const Intro({Key? key}) : super(key: key);

  @override
  OnBoardingPageState createState() => OnBoardingPageState();
}

class OnBoardingPageState extends State<Intro> {
  final introKey = GlobalKey<IntroductionScreenState>();

  Widget _buildImage(String assetName, [double width = 350]) {
    return Image.asset('assets/$assetName', width: width);
  }

  @override
  Widget build(BuildContext context) {
    const pageDecoration = PageDecoration(
      pageColor: Colors.white,
      imagePadding: EdgeInsets.zero,
    );

    return IntroductionScreen(
      key: introKey,
      globalBackgroundColor: Colors.white,
      allowImplicitScrolling: true,
      showSkipButton: true,
      skip: const Text('Skip', style: TextStyle(fontWeight: FontWeight.w600)),
      next: const Icon(Icons.arrow_forward),
      done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
      onDone: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const RegisterPage(),
        ),
      ),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Color(0xFFBDBDBD),
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
      curve: Curves.fastLinearToSlowEaseIn,
      controlsMargin: const EdgeInsets.all(16),
      controlsPadding: kIsWeb ? const EdgeInsets.all(12.0) : const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      // globalHeader: Align(
      //   alignment: Alignment.topCenter,
      //   child: SafeArea(
      //     child: Padding(
      //       padding: const EdgeInsets.only(top: 16, right: 16),
      //       child: _buildImage('regroup.png', 128),
      //     ),
      //   ),
      // ),
      pages: [
        PageViewModel(
          title: "Join a group to stay connected and safe",
          body: "With ReGroup, you can easily join a group with your teacher and classmates to stay connected during your trip.",
          image: _buildImage('onboarding-01.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Real-time location tracking and safety notifications",
          body: "ReGroup provides real-time location tracking for all group members using Bluetooth technology.",
          image: Image.asset(
            'assets/onboarding-02.png',
            width: 224,
          ),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: 'Instant safety alerts',
          body: "ReGroup sends you instant safety alerts if you stray from your group or if there are any safety concerns during your trip.",
          image: _buildImage('onboarding-03.png'),
          decoration: pageDecoration,
        ),
      ],
    );
  }
}
