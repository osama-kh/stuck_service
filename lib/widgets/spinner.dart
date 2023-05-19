import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class ProgressWithIcon extends StatelessWidget {
  const ProgressWithIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 500,
      height: 500,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage('assets/images/wheel-logo.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            height: 70,
            width: 70,
            child: const CircularProgressIndicator(
              strokeWidth: 3,
              color: Color.fromARGB(255, 255, 55, 48), //<-- SEE HERE
            ),
          )

          // you can replace
        ],
      ),
    );
  }
}
