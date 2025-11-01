import 'package:code_and_cocktails/requests/verifying_ticket.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../../models/err_success_model.dart';
import '../../shared/utils/enums.dart';
import 'results_data.dart';

class ResultsPage extends StatefulWidget {
  final Barcode? result;

  const ResultsPage({super.key, required this.result});

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  // bool? verifyingTicket;
  VerificationStatus? verifyingTicket;

  ErrSuccResponse? results;

  @override
  void initState() {
    super.initState();
    _verifyingTicket();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: (results?.ticketSuccess?.qrCodeBase64 ?? '').isNotEmpty
            ? Theme.of(context).primaryColor
            : const Color(0xffEA1154),
        onPressed: () {
          Navigator.pop(context);
          // Navigator.of(context).pushAndRemoveUntil(
          //     MaterialPageRoute(builder: (builder) => const HomePage()),
          //     (route) => false);
        },
        child: Icon(
          (results?.ticketSuccess?.qrCodeBase64 ?? '').isNotEmpty
              ? Icons.done
              : Icons.close,
          color: Theme.of(context).canvasColor,
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
          "Ticket Verification",
          style: TextStyle(
            fontSize: 18,
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        children: [
          verifyingTicket == VerificationStatus.success
              ? const SizedBox()
              : Column(
                  children: [
                    const SizedBox(
                      height: 30,
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 70),
                      child: Stack(
                        children: [
                          Column(
                            children: [
                              Align(
                                alignment: Alignment.center,
                                child: Container(
                                  // color: Colors.amber,
                                  width: 120,
                                  height: 120,
                                  child: SvgPicture.asset(
                                      "assets/ticket-77dfce33.svg"),
                                ),
                              ),
                              _buildVerifyingTicketResponse()
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Text(
                        "Click arrow to scan next ticket",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          color:
                              Theme.of(context).disabledColor.withOpacity(.9),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
          verifyingTicket == VerificationStatus.success
              ? successWidget()
              : const SizedBox(),
        ],
      ),
    );
  }

  _buildVerifyingTicketResponse() {
    return verifyingTicket == VerificationStatus.loading
        ? loader()
        : verifyingTicket == VerificationStatus.error
            ? errorWidget(results!.error!.message ?? "Error verifying ticket")
            : verifyingTicket == VerificationStatus.usedUp
                ? usedUpWidget(context)
                : const SizedBox();
  }

  _verifyingTicket() {
    Future.microtask(() async {
      VerifyingTicketSingleton verifyingTicketSingleton =
          VerifyingTicketSingleton();

      setState(() {
        verifyingTicket = VerificationStatus.loading;
      });

      results = await verifyingTicketSingleton.verifyMyTicket(
          ticketID: widget.result?.code ?? '');
      debugPrint("Results ${results!.ticketSuccess}");
      if (results == null) {
        setState(() {
          verifyingTicket = null;
        });
        return null;
      }

      if (results?.error == null) {
        debugPrint("RESP OK:");
        setState(() {
          verifyingTicket = VerificationStatus.success;
        });
      } else if (results?.error?.message == "Ticket is used up") {
        // Specific case when ticket is used up
        debugPrint("Ticket is used up");
        setState(() {
          verifyingTicket = VerificationStatus.usedUp;
        });
      } else {
        debugPrint("RESP ERR:");

        setState(() {
          verifyingTicket = VerificationStatus.error;
        });
      }
    });
  }

  loader() {
    return const Padding(
      padding: EdgeInsets.only(top: 20.0),
      child: SizedBox(
        width: 30,
        height: 30,
        child: CircularProgressIndicator(
          strokeWidth: 3,
        ),
      ),
    );
  }

  successWidget() {
    return Column(
      children: [
        // const SizedBox(
        //   height: 30,
        // ),

        ResultsData(
          successResponse: results?.ticketSuccess,
          result: widget.result,
        ),
      ],
    );
  }

  errorWidget(String message) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Text(
        message,
        textAlign: TextAlign.center,
        maxLines: 6,
        style: const TextStyle(
          color: Colors.red,
          fontSize: 20,
        ),
      ),
    );
  }

  usedUpWidget(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: const Text(
        "This ticket has been used up",
        textAlign: TextAlign.center,
        maxLines: 6,
        style: TextStyle(
          color: Colors.orange,
          fontWeight: FontWeight.w400,
          // color: Theme.of(context).primaryColor,
          fontSize: 20,
        ),
      ),
    );
  }
}
