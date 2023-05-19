import 'package:flutter/material.dart';

class start_info_card extends StatelessWidget {
  final cardTitle;
  final cardText;
  final cardColor;
  final cardImage;
  final imagesize;

  start_info_card(this.cardTitle, this.cardText, this.cardImage, this.cardColor,
      this.imagesize);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height - 50,
      width: MediaQuery.of(context).size.width - 50,
      color: Color.fromARGB(77, 255, 255, 255),
      child: Container(
          margin: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width / 7,
              vertical: MediaQuery.of(context).size.height / 7),
          color: Color.fromARGB(77, 255, 255, 255),

          //elevation: 50,
          child: Card(
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: const BorderRadius.all(Radius.circular(5)),
            ),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width - imagesize,
                    height: MediaQuery.of(context).size.height - imagesize,
                    child: Image.asset(
                      cardImage,
                      //fit: BoxFit.,
                    ),
                  ),
                ),
                Flexible(
                  fit: FlexFit.loose,
                  child: Container(
                    color: cardColor,
                    //elevation: 50,
                    child: Container(
                      height: 300,
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.topCenter,
                            child: Text(
                              cardTitle,
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Align(
                              alignment: Alignment.center,
                              child: Text(
                                cardText,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 15, color: Colors.black45),
                              ))
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          )),
    );
  }
}
