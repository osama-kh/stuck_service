import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:stuck_service/widgets/notification_to_helper.dart';

import '../models/main_theme.dart';
import 'BarIndicator.dart';
import 'Stuck_p.dart';
import 'helper_info_card.dart';

class notifications_helper_panel extends StatelessWidget {
  final ScrollController controller;
  final PanelController panelController;
  final waitingStucked;

  const notifications_helper_panel(
      {Key? key,
      required this.controller,
      required this.panelController,
      this.waitingStucked})
      : super(key: key);
  checker() {
    print(Onlinehelperdata);

    print("-------------------------------------------89898");
  }

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
                  (context, Index) => notification_card(),
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

  Widget notification_card() => Container(
        padding: EdgeInsets.all(2),
        child: Column(
          children: [
            for (var key in waitingStucked.keys) ...[
              // Text(Onlinehelperdata[key].toString())

              notification_to_helper(waitingStucked[key]),
            ],
          ],
        ),
      );

  void togglePanel() => panelController.isPanelOpen
      ? panelController.close()
      : panelController.open();
}
