import 'package:breez_sdk_nodeless_flutter_workshop/home/widgets/balance.dart';
import 'package:breez_sdk_nodeless_flutter_workshop/home/widgets/receive_dialog.dart';
import 'package:breez_sdk_nodeless_flutter_workshop/home/widgets/send_dialog.dart';
import 'package:breez_sdk_nodeless_flutter_workshop/services/nodeless_sdk.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final NodelessSdk sdk;

  const HomePage({super.key, required this.sdk});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Breez SDK Nodeless Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Balance(getInfoStream: widget.sdk.getInfoStream),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => ReceivePaymentDialog(
                            sdk: widget.sdk.instance!, paymentEventStream: widget.sdk.paymentEventStream),
                      );
                    },
                    child: const Text("Receive"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => SendPaymentDialog(),
                      );
                    },
                    child: const Text("Send"),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
