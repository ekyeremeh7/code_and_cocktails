import 'dart:developer';
import 'dart:io';

import 'package:code_and_cocktails/src/results/results.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class CodeScanner extends StatefulWidget {
  const CodeScanner({super.key});

  @override
  State<CodeScanner> createState() => _CodeScannerState();
}

class _CodeScannerState extends State<CodeScanner> {
  bool dataRetrieved = false;
  int addingScannedInvoicesToMyAccount = 0;
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  void toggleFlash() async {
    await controller?.toggleFlash();
  }

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      Future.delayed(const Duration(milliseconds: 10), () async {
        if (Platform.isAndroid) {
          await controller!.pauseCamera();
        }
        await controller?.resumeCamera();
        setState(() {});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    List iconsAndLabels = [
      {
        "label": Icons.flash_on_outlined,
        'tap': () {
          toggleFlash();
        }
      },
    ];

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: <Widget>[
              Expanded(flex: 4, child: _buildQrView(context)),
            ],
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).viewPadding.top + 30),
              child: Text(
                "Point your camera to the QR code you'd like to scan",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).canvasColor,
                  fontSize: 20,
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 60,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  for (int i = 0; i < 1; i++)
                    GestureDetector(
                      onTap: () {
                        iconsAndLabels[i]['tap']?.call();
                      },
                      child: Column(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .canvasColor
                                  .withOpacity(.05),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: Icon(
                                iconsAndLabels[i]['label'],
                                color: Theme.of(context).canvasColor,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Flash",
                            style: TextStyle(
                              color: Theme.of(context).canvasColor,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Align(
          //   alignment: Alignment.center,
          //   child:  result != null ?TextItem(
          //     "Data: ${result!.code}",
          //     color: Theme.of(context).canvasColor,
          //     textAlign: TextAlign.center,
          //     size: 16,
          //   ) : const Text('Scan a code'),
          // ),

          addingScannedInvoicesToMyAccount > 0
              ? Center(
                  child: Container(
                    height: 100.0,
                    width: 100.0,
                    decoration: BoxDecoration(
                      color: Theme.of(context).canvasColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: CupertinoActivityIndicator(
                        radius: 12, color: Theme.of(context).primaryColor),
                  ),
                )
              : const SizedBox(),
        ],
      ),
    );
  }

  Widget qrBottom() {
    return Expanded(
      flex: 1,
      child: FittedBox(
        fit: BoxFit.contain,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            if (result != null)
              Text(
                  'Barcode Type: ${describeEnum(result!.format)}   Data: ${result!.code}')
            else
              const Text('Scan a code'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.all(8),
                  child: ElevatedButton(
                      onPressed: () async {
                        await controller?.toggleFlash();
                        setState(() {});
                      },
                      child: FutureBuilder(
                        future: controller?.getFlashStatus(),
                        builder: (context, snapshot) {
                          return Text('Flash: ${snapshot.data}');
                        },
                      )),
                ),
                Container(
                  margin: const EdgeInsets.all(8),
                  child: ElevatedButton(
                      onPressed: () async {
                        await controller?.flipCamera();
                        setState(() {});
                      },
                      child: FutureBuilder(
                        future: controller?.getCameraInfo(),
                        builder: (context, snapshot) {
                          if (snapshot.data != null) {
                            return Text(
                                'Camera facing ${describeEnum(snapshot.data!)}');
                          } else {
                            return const Text('loading');
                          }
                        },
                      )),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.all(8),
                  child: ElevatedButton(
                    onPressed: () async {
                      await controller?.pauseCamera();
                    },
                    child: const Text('pause', style: TextStyle(fontSize: 20)),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(8),
                  child: ElevatedButton(
                    onPressed: () async {
                      await controller?.resumeCamera();
                    },
                    child: const Text('resume', style: TextStyle(fontSize: 20)),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = 200.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) async {
      if (dataRetrieved == true) return;

      dataRetrieved = true;
      // tin info
      setState(() {
        result = scanData;
      });

      addingScannedInvoicesToMyAccount++;
      Map dataToSend = {"data": result!.code!};

      Navigator.pop(context);

      var res = await Navigator.of(context).push(
          MaterialPageRoute(builder: (builder) => ResultsPage(result: result)));

      if (res == "   ") {
        dataRetrieved = false;
      }
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {}
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
