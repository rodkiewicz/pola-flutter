
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pola_flutter/data/pola_api_repository.dart';
import 'package:pola_flutter/ui/list_item.dart';
import 'package:pola_flutter/ui/menu_bottom_sheet.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import 'scan_bloc.dart';

class ScanPage extends StatefulWidget {
  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  late ScanBloc _scanBloc;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');


  @override
  void initState() {
    _scanBloc = ScanBloc(PolaApiRepository());
  }
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      _scanBloc.controller?.pauseCamera();
    }
    _scanBloc.controller?.resumeCamera();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Center(
          child: IconButton(
            onPressed: () {
              _scanBloc.controller?.toggleFlash();
            },
            icon: Image.asset("assets/ic_flash_on_white_48dp.png"),
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pushNamed(context, '/web',
                arguments: "https://www.pola-app.pl");
          },
          icon: Image.asset("assets/ic_launcher.png"),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showModalBottomSheet<void>(
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  context: context,
                  builder: (BuildContext context) {
                    return MenuBottomSheet();
                  });
            },
            icon: Image.asset("assets/menu.png"),
          )
        ],
      ),
      body: Stack(
        children: <Widget>[
          Expanded(child: _buildQrView(context)),
          SafeArea(
            child: Column(
              children: <Widget>[
                Center(
                    child: Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Text(
                            "Umieść kod kreskowy produktu w prostokącie powyżej aby dowiedzieć się więcej o firmie, która go wyprodukowała.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                            )))),
              ],
            ),
          ),
          SafeArea(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Spacer(),
              BlocBuilder<ScanBloc, ScanState>(
                bloc: _scanBloc,
                builder: (context, state) {
                  if (state is ScanLoaded) {
                    return Container(
                      height: 400,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: ListView.builder(
                          reverse: true,
                          itemCount: state.list.length,
                          itemBuilder: (BuildContext context, int index) {
                            return GestureDetector(
                              child: ListItem(state.list[index]),
                              onTap: () {
                                Navigator.pushNamed(context, '/detail',
                                    arguments: state.list[index]);
                              },
                            );
                          },
                        ),
                      ),
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ],
          )),
        ],
      ),
      extendBodyBehindAppBar: true,
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 250.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      formatsAllowed: [BarcodeFormat.ean8, BarcodeFormat.ean13],
      overlay: QrScannerOverlayShape(
          borderColor: Colors.black, borderWidth: 10, cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    _scanBloc.setQRViewController(controller);
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('no Permission')),
      );
    }
  }
  @override
  void dispose() {
    _scanBloc.controller?.dispose();
    super.dispose();
  }
}
