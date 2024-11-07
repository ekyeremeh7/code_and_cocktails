import 'package:code_and_cocktails/src/home/home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../../models/ticket_request_success.dart';
import '../../requests/verifying_ticket.dart';

class StatsPage extends StatefulWidget {
  final Barcode? result;

  const StatsPage({super.key, required this.result});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  int selectedTicketIndex = 0;
  bool selectCategory = false;
  bool? verifyingTicket;
  List<TicketSuccessResponse>? results;

  List<Map> ticketTypes = [
    {"name": "All", "price": 0, "currency": "", "ticket_count": 0},
    {
      "name": "Early Bird (Limited)",
      "price": 100,
      "currency": "GHS",
      "ticket_count": 0
    },
    {
      "name": "3 member SQUAD",
      "price": 250,
      "currency": "GHS",
      "ticket_count": 0
    },
    {
      "name": "5 member SQUAD",
      "price": 400,
      "currency": "GHS",
      "ticket_count": 0
    },
    {
      "name": "10 member SQUAD",
      "price": 800,
      "currency": "GHS",
      "ticket_count": 0
    },
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      VerifyingTicketSingleton verifyingTicketSingleton =
          VerifyingTicketSingleton();

      setState(() {
        verifyingTicket = true;
      });

      results = await verifyingTicketSingleton.getAllTickets();

      if (results == null) {
        setState(() {
          verifyingTicket = null;
        });
        return null;
      }

      if (results != null) {
        print("RESP OK:");
        setState(() {
          verifyingTicket = false;
        });
      } else {
        print("RESP ERR:");

        setState(() {
          verifyingTicket = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<TicketSuccessResponse>? currentIndexItems = results
            ?.where((el) =>
                el.ticketType?.toLowerCase().contains(
                    ticketTypes[selectedTicketIndex]['name'].toLowerCase() ??
                        '') ==
                true)
            .toList() ??
        [];
    if (selectedTicketIndex == 0) {
      currentIndexItems = results?.toList();
    }
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (builder) => const HomePage()),
              (route) => false);
        },
        child: Center(
          child: Text(
              "${selectedTicketIndex == 0 ? results?.length : currentIndexItems?.length}"),
        ),
      ),
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.chevron_left,
              color: Theme.of(context).primaryColor,
            )),
        elevation: 0,
        backgroundColor: Theme.of(context).canvasColor,
        centerTitle: true,
        title: Text(
          "All Tickets",
          style: TextStyle(
            fontSize: 18,
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        children: [
          verifyingTicket == true || verifyingTicket == null
              ? Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * .30),
                  child: Column(
                    children: [
                      verifyingTicket == true
                          ? CircularProgressIndicator()
                          : Text(
                              "Error Making request",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: const Color(0xffEA1154),
                                fontSize: 18.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    selectCategory == false
                        ? Card(
                            elevation: 2,
                            shadowColor: Colors.black.withOpacity(.2),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectCategory = true;
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(4.0),
                                        border: Border.all(
                                            color: const Color(0xffEA1154),
                                            width: 1.5)),
                                    width: MediaQuery.of(context).size.width,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0, vertical: 16.0),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                ticketTypes[selectedTicketIndex]
                                                    ['name'],
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .disabledColor
                                                      .withOpacity(.9),
                                                  fontSize: 18.0,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Text(
                                                "",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .disabledColor
                                                      .withOpacity(.9),
                                                  fontSize: 18.0,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Container(
                                                height: 28,
                                                width: 28,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      width: 1.5,
                                                      color: const Color(
                                                          0xffEA1154)),
                                                  color:
                                                      const Color(0xffEA1154),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Center(
                                                  child: Icon(
                                                    Icons.done,
                                                    color: Colors.white,
                                                    size: 13,
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              ]),
                            ),
                          )
                        : Card(
                            color:
                                Theme.of(context).disabledColor.withOpacity(.1),
                            elevation: 2,
                            shadowColor: Colors.black.withOpacity(.2),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  // const SizedBox(
                                  //   height: 8.0,
                                  // ),
                                  for (int i = 0; i < ticketTypes.length; i++)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 6.0),
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedTicketIndex = i;
                                            Future.delayed(
                                                const Duration(
                                                    milliseconds: 300), () {
                                              setState(() {
                                                selectCategory = false;
                                              });
                                            });
                                          });
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(4.0),
                                              border: Border.all(
                                                  color: selectedTicketIndex ==
                                                          i
                                                      ? const Color(0xffEA1154)
                                                      : Theme.of(context)
                                                          .disabledColor
                                                          .withOpacity(.1),
                                                  width: 1.5)),
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0,
                                                vertical: 16.0),
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      ticketTypes[i]['name'],
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        color: Theme.of(context)
                                                            .disabledColor
                                                            .withOpacity(.9),
                                                        fontSize: 18.0,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    Text(
                                                      "",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        color: Theme.of(context)
                                                            .disabledColor
                                                            .withOpacity(.9),
                                                        fontSize: 18.0,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    Container(
                                                      height: 28,
                                                      width: 28,
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                          width: 1.5,
                                                          color: selectedTicketIndex ==
                                                                  i
                                                              ? const Color(
                                                                  0xffEA1154)
                                                              : Theme.of(
                                                                      context)
                                                                  .disabledColor
                                                                  .withOpacity(
                                                                      .1),
                                                        ),
                                                        color:
                                                            selectedTicketIndex ==
                                                                    i
                                                                ? const Color(
                                                                    0xffEA1154)
                                                                : Colors
                                                                    .transparent,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Center(
                                                        child:
                                                            selectedTicketIndex !=
                                                                    i
                                                                ? const SizedBox()
                                                                : const Icon(
                                                                    Icons.done,
                                                                    color: Colors
                                                                        .white,
                                                                    size: 13,
                                                                  ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  const SizedBox(
                                    height: 8.0,
                                  ),
                                ],
                              ),
                            ),
                          ),
                    const SizedBox(
                      height: 16,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 8.0,
                          ),
                          for (int k = 0;
                              k < (currentIndexItems?.length ?? 0);
                              k++)
                            infoDataCard(
                                price: results?[k].payment?.amount ?? 0,
                                isVerified: true,
                                color: Theme.of(context).primaryColor,
                                name: results?[k].ticketType),
                          const SizedBox(
                            height: 8.0,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget infoDataCard(
      {String? name, dynamic price, bool? isVerified, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: GestureDetector(
        onTap: () {},
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.0),
              border: Border.all(
                  color: Theme.of(context).disabledColor.withOpacity(.1),
                  width: 1.5)),
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        name ?? "",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color:
                              Theme.of(context).disabledColor.withOpacity(.9),
                          fontSize: 18.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      "GHS $price",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).disabledColor.withOpacity(.9),
                        fontSize: 18.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      height: 28,
                      width: 28,
                      margin: const EdgeInsets.only(left: 4),
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1.5,
                          color: isVerified == true
                              ? (color?.withOpacity(.1) ??
                                  const Color(0xffEA1154))
                              : Theme.of(context).disabledColor.withOpacity(.1),
                        ),
                        color: isVerified == true
                            ? (color?.withOpacity(.1) ??
                                const Color(0xffEA1154))
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isVerified != true
                            ? const SizedBox(
                                child: Icon(
                                  Icons.close,
                                  color: Colors.red,
                                  size: 13,
                                ),
                              )
                            : const Icon(
                                Icons.done,
                                color: Colors.white,
                                size: 13,
                              ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
