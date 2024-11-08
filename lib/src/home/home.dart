import 'package:code_and_cocktails/src/results/results.dart';
import 'package:code_and_cocktails/src/scan/scan.dart';
import 'package:code_and_cocktails/src/stats/stats_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../../shared/services/sembast_service.dart';
import '../stats/history_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            // leading:SizedBox(
            //   width: 100,
            //   height: 180,
            //   child: SvgPicture.asset("assets/logo-cb645496.svg"),
            // )            ,
            // Icon(
            //   Icons.code,
            //   color: Theme.of(context).primaryColor,
            // ),
            elevation: 0,
            backgroundColor: Theme.of(context).canvasColor,
            // centerTitle: true,
            title: SizedBox(
              width: 100,
              height: 180,
              child: SvgPicture.asset("assets/logo-cb645496.svg"),
            ),
            // Text(
            //   "Code & Cocktails",
            //   style: TextStyle(
            //     fontSize: 18,
            //     color: Theme.of(context).primaryColor,
            //     fontWeight: FontWeight.bold,
            //   ),
            // ),
            actions: [
              GestureDetector(
                onTap: () {
                  final SembastService _sembastService = SembastService();
                  _sembastService.clearUserStore();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (builder) => const StatsPage(result: null)));
                },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
                  child: Icon(
                    Icons.account_balance_wallet_rounded,
                    size: 40,
                    color: Theme.of(context).disabledColor.withOpacity(.3),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (builder) => const HistoryPage(
                            result: null,
                          )));
                },
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 8.0, right: 15.0, top: 2),
                  child: Icon(
                    Icons.history,
                    size: 40,
                    color: Theme.of(context).disabledColor.withOpacity(.3),
                  ),
                ),
              )
            ],
          ),
          body: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Scan new ticket",
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (builder) => const CodeScanner()));
              },
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).primaryColor,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                      spreadRadius: 5,
                      blurRadius: 7.7,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.qr_code,
                    color: Theme.of(context).canvasColor,
                    size: 50,
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
