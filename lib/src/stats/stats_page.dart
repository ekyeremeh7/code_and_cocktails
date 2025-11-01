import 'package:code_and_cocktails/src/home/home.dart';
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
            "${selectedTicketIndex == 0 ? results?.length ?? 0 : currentIndexItems?.length ?? 0}",
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Theme.of(context).primaryColor,
              size: 20,
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
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List.generate(
                          ticketTypes.length,
                          (index) {
                            final isSelected = selectedTicketIndex == index;
                            return FilterChip(
                              label: Text(ticketTypes[index]['name']),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  selectedTicketIndex = index;
                                });
                              },
                              selectedColor: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.2),
                              checkmarkColor: Theme.of(context).primaryColor,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey.shade700,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          for (int k = 0;
                              k < (currentIndexItems?.length ?? 0);
                              k++)
                            infoDataCard(
                                price:
                                    currentIndexItems?[k].payment?.amount ?? 0,
                                isVerified: true,
                                color: Theme.of(context).primaryColor,
                                name: currentIndexItems?[k].ticketType),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name ?? "",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "GHS $price",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isVerified == true
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isVerified == true ? Icons.check_circle : Icons.cancel,
                    color: isVerified == true ? Colors.green : Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isVerified == true ? "Verified" : "Failed",
                    style: TextStyle(
                      color: isVerified == true ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
