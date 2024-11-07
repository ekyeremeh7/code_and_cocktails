import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:convert';
import '../../models/ticket_request_success.dart';

class ResultsData extends StatefulWidget {
  final TicketSuccessResponse? successResponse;
  final Barcode? result;  
  const ResultsData({super.key, required this.successResponse,required this.result});

  @override
  State<ResultsData> createState() => _ResultsDataState();
}

class _ResultsDataState extends State<ResultsData> {




  @override
  Widget build(BuildContext context) {
      String base64String = widget.successResponse?.qrCodeBase64 ?? '';
    Image? qrImage;
    if(base64String.isNotEmpty){
      qrImage = convertBase64StringToImage(base64String.split(',')[1]);
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
      child: Card(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(.2),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
            base64String.isNotEmpty ==true?
              SizedBox(
                height: 100,
                width: 100,
                child: Center(
                  child: qrImage,
                ),
              ):const SizedBox(),
              const SizedBox(
                height: 30,
              ),
            base64String.isNotEmpty ==true?
              Column(
                children: [
              Text(
                widget.successResponse?.ticketType ?? "Ticket Type",
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 30,
              ),
              elRow(
                title: "STATUS",
                color: const Color.fromARGB(255, 3, 211, 9),
                value: widget.successResponse?.payment?.status?.toUpperCase() ?? '',
              ),
              elRow(
                title: "reference".toUpperCase(),
                value: widget.successResponse?.payment?.reference ?? '',
              ),
              elRow(
                  title: "CUSTOMER",
                  value: widget.successResponse?.customer?.name ?? ''),
              elRow(
                  title: '',
                  value: widget.successResponse?.customer?.phone ?? ''),
              elRow(
                  title: '',
                  value: widget.successResponse?.customer?.email ?? ''),
              elRow(
                title: "QUANTITY",
                value: widget.successResponse?.quantity.toString() ?? '',
              ),
              elRow(
                title: 'SQUAD LIMIT',
                value: widget.successResponse?.squadLimit.toString() ?? '',
              ),
              const SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 30,
                  ),
                  Text(
                    "GHS ${widget.successResponse?.payment?.amount ?? ''}",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: SvgPicture.asset("assets/ticket-77dfce33.svg"),
                  ),
                ],
              ),
                ],
              ) : Column(
                children: [
                  SizedBox(width: MediaQuery.of(context).size.width,),
                  Container(
                    width: 180,
                    height: 180,
                    child: Image.asset("assets/tickets.png"),
                  ),
    const SizedBox(
                    height: 80,
                  ),
                  Text("Error verifying ticket",style: TextStyle(
                              color: Colors.red,
                              fontSize: 22,
                              fontWeight: FontWeight.bold
                            ),),
                ],
              ),

              const SizedBox(
                height: 100,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget elRow({String? title, String? value,Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title ?? "data",
            style: TextStyle(
              fontSize: 15,
              color: Theme.of(context).disabledColor.withOpacity(.3),
            ),
          ),
          Flexible(
            child: SizedBox(
              width: (MediaQuery.of(context).size.width / 1.5) - 32,
              child: Text(
                value ?? "Value",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400,color: 
                color),
              ),
            ),
          ),
        ],
      ),
    );
  }
}



Image convertBase64StringToImage(String base64String) {
  Uint8List decodedBytes = base64.decode(base64String);
  return Image.memory(decodedBytes);
}