import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../models/main_theme.dart';
import 'BarIndicator.dart';
import 'Stuck_p.dart';
import 'helper_info_card.dart';

class helper_info_card_panel extends StatelessWidget {
  final ScrollController controller;
  final PanelController panelController;
  final Onlinehelper;
  final Onlinehelperdata;
  final userImage;
  final distances;
  final distanceNeed;
  const helper_info_card_panel(
      {Key? key,
      required this.controller,
      required this.panelController,
      this.Onlinehelper,
      this.Onlinehelperdata,
      this.userImage,
      this.distances,
      this.distanceNeed})
      : super(key: key);
  checker() {
    print(Onlinehelperdata);
    print('$distanceNeed 8888');
    print('$distances 8888');
    print("-------------------------------------------89898");
  }

  @override
  // Widget build(BuildContext context) => ListView(
  //       controller: controller,
  //       padding: EdgeInsets.zero,
  //       children: <Widget>[
  //         SizedBox(
  //           height: 12,
  //         ),
  //         buildDragHandle(),
  //         SizedBox(
  //           height: 36,
  //         ),
  //         //checker(),
  //         //Text(Onlinehelperdata.toString()),

  //         helper_card(),
  //         SizedBox(
  //           height: 36,
  //         )
  //       ],
  //     );

  Widget build(BuildContext context) => CustomScrollView(
        controller: controller,
        slivers: <Widget>[
          SliverAppBar(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12))),
            flexibleSpace: buildDragHandle(),
            automaticallyImplyLeading: false,
            pinned: true,
            toolbarHeight: 20,
            backgroundColor: main_theme().get_white(),
            elevation: 1,
          ),
          SliverList(
              delegate: SliverChildBuilderDelegate(
                  (context, Index) => helper_card(),
                  childCount: 1))
        ],
      );

  Widget buildDragHandle() => GestureDetector(
        child: Center(
          child: Container(
            width: 50,
            height: 5,
            decoration: BoxDecoration(
                color: main_theme().get_blue_grey(),
                borderRadius: BorderRadius.all(Radius.circular(12))),
          ),
        ),
        onTap: togglePanel,
      );

  Widget helper_card() => Container(
        padding: EdgeInsets.all(2),
        child: Column(
          children: [
            for (var key in Onlinehelperdata.keys) ...[
              // Text(Onlinehelperdata[key].toString())
              if (distances[key] / 1000 <= distanceNeed) ...[
                helper_info_card(
                    Onlinehelperdata[key], userImage[key], distances[key],key),
              ]
            ],
          ],
        ),
      );

  void togglePanel() => panelController.isPanelOpen
      ? panelController.close()
      : panelController.open();
}
