import 'package:flutter/material.dart';
import 'package:myschool/views/admin/AdminScreen.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class QRScannerScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  final TextEditingController passwordController = TextEditingController();
  Barcode? result;
  QRViewController? controller;
  bool scanningPaused = false; // Flag to track if scanning is paused
  final String correctPassword = "school123"; // The correct password
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code Scanner'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 3, // Reduced the camera view to occupy a smaller portion
            child: Stack(
              alignment: Alignment.center,
              children: [
                QRView(
                  key: qrKey,
                  onQRViewCreated: _onQRViewCreated,
                  // Specify a reduced width and height
                  overlay: QrScannerOverlayShape(
                    borderColor: Colors.blue,
                    borderRadius: 10,
                    borderLength: 30,
                    borderWidth: 10,
                    cutOutSize: 200,
                  ),
                ),
                // Vertical box scanner effect
                Positioned(
                  top: _animationController.value *
                      250, // Adjust the range for vertical movement
                  child: Container(
                    width: 200, // Width of the scanning box
                    height: 2,
                    color: Colors.redAccent.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (result != null)
                      Text(
                        'Barcode Type: ${result!.format}   Data: ${result!.code}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    else
                      Text(
                        'Scan a code',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blueGrey,
                        ),
                      ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock),
                        labelText: 'Enter Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (passwordController.text == correctPassword) {
                          // Correct password entered
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AdminRespect(),
                            ),
                          );
                        } else {
                          // Show an error alert for incorrect password
                          QuickAlert.show(
                            context: context,
                            type: QuickAlertType.error,
                            text: 'Incorrect Password!',
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        'Submit',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;

    controller.scannedDataStream.listen((scanData) {
      if (!scanningPaused) {
        setState(() {
          result = scanData;
          if (result!.code == 'schoolismy') {
            // Correct QR code scanned
            scanningPaused =
                true; // Pause scanning to prevent further detections
            controller.pauseCamera(); // Pause camera preview
            // Navigate directly to the Admin screen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => AdminRespect(),
              ),
            );
          } else {
            // Invalid QR code scanned
            scanningPaused =
                true; // Pause scanning to prevent further detections
            controller.pauseCamera(); // Pause camera preview
            // Show an error alert
            QuickAlert.show(
              context: context,
              type: QuickAlertType.error,
              text: 'Invalid QR Code: Please scan a valid QR code.',
            ).then((_) {
              // Resume scanning after a short delay
              Future.delayed(Duration(seconds: 2), () {
                scanningPaused = false; // Allow scanning again
                controller.resumeCamera(); // Resume camera preview
              });
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}
