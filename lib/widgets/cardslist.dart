import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import './cards.dart';

class Cardlist extends StatefulWidget {
  @override
  State<Cardlist> createState() => _CardlistState();
}

class _CardlistState extends State<Cardlist> {
  final PageController _pageController = PageController();

  bool flag = false;

  final about_us_t =
      "Stuck service is a service provider platform for stucked poeple to find" +
          "a helpers in thier range that have the ability to fix cars . ";

  final Our_Services_t =
      "Stuck service provide a way of connection between helper" +
          " and stuck person, seeing reviews information about helper, and thier location on map. ";

  final Terms_and_Conditions_t =
      // ignore: prefer_interpolation_to_compose_strings
      "By clicking on finish you accept the terms and conditions " +
          "that written below: this app is not responsible about what happend between the helper and " +
          "the stuck person ,this app will need permession of this device to get location and connect the" +
          " money transaction provider.  ";

  //Cardlist();
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Hero(
        tag: 'logo',
        child: Container(
          child: Image.asset("assets/images/final-logo.png"),
          alignment: Alignment.topLeft,
          width: 130,
        ),
      ),
      PageView(
        controller: _pageController,
        children: <Widget>[
          start_info_card("About us", about_us_t,
              './assets/images/mainPhoto.jpg', Colors.white, 25),
          start_info_card("Our Services", Our_Services_t,
              'assets/images/x3.jpg', Colors.white, 100),
          start_info_card("Terms and Conditions", Terms_and_Conditions_t,
              './assets/images/5.jpg', Colors.white, 100)
        ],
        onPageChanged: (index) {
          setState(() {
            if (index == 2) {
              flag = true;
            } else {
              flag = false;
            }
          });

          print(flag);
        },
      ),
      Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            child: Center(
              child: SmoothPageIndicator(
                controller: _pageController,
                count: 3,
                effect: ExpandingDotsEffect(),
                onDotClicked: ((index) => _pageController.animateToPage(index,
                    duration: const Duration(milliseconds: 450),
                    curve: Curves.easeInCubic)),
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          if (flag == false) ...[
            Container(
              height: 60,
              width: MediaQuery.of(context).size.width - 60,
              child: TextButton(
                onPressed: () {
                  _pageController.nextPage(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInCubic);
                },
                child: const Text(
                  'SKIP',
                  style: TextStyle(fontSize: 15),
                ),
              ),
            )
          ] else ...[
            Container(
              height: 60,
              width: MediaQuery.of(context).size.width - 60,
              child: Expanded(
                //  fit: FlexFit.tight,

                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, 'login');
                  },
                  child: Text(
                    "SIGN IN",
                    style: TextStyle(fontSize: 20),
                  ),
                  style: ElevatedButton.styleFrom(shape: StadiumBorder()),
                ),
              ),
            )
          ],
          const SizedBox(
            height: 20,
          )
        ],
      )
    ]);
  }
}
