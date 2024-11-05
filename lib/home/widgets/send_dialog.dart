import 'package:breez_sdk_nodeless_flutter_workshop/services/nodeless_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_breez_liquid/flutter_breez_liquid.dart';

class SendPaymentDialog extends StatefulWidget {
  final BindingLiquidSdk sdk;

  const SendPaymentDialog({super.key, required this.sdk});

  @override
  State<SendPaymentDialog> createState() => _SendPaymentDialogState();
}

class _SendPaymentDialogState extends State<SendPaymentDialog> {
  final TextEditingController invoiceController = TextEditingController();
  bool paymentInProgress = false;

  PrepareSendResponse? prepareResponse;

  @override
  Widget build(BuildContext context) {
    Widget promptContent() {
      return prepareResponse != null
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                      'Please confirm that you agree to the payment fee of ${prepareResponse!.feesSat} sats.'),
                ],
              ),
            )
          : TextField(
              decoration: InputDecoration(
                label: const Text("Enter Invoice"),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.paste, color: Colors.blue),
                  onPressed: () async {
                    final clipboardData = await Clipboard.getData('text/plain');
                    if (clipboardData != null && clipboardData.text != null) {
                      invoiceController.text = clipboardData.text!;
                    }
                  },
                ),
              ),
              controller: invoiceController,
            );
    }

    Widget inProgressContent() {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(prepareResponse == null ? "Preparing..." : "Sending..."),
            const SizedBox(height: 16),
            const CircularProgressIndicator(color: Colors.blue),
          ],
        ),
      );
    }

    Future<void> onOkPressed() async {
      try {
        setState(() => paymentInProgress = true);
        // Use the input text as the destination of the send payment
        PrepareSendRequest prepareSendReq = PrepareSendRequest(
          destination: invoiceController.text,
        );
        PrepareSendResponse res = await widget.sdk.prepareSendPayment(
          req: prepareSendReq,
        );
        debugPrint(
          "PrepareSendResponse destination ${res.destination}, fees: ${res.feesSat}",
        );
        // Set the prepareResponse state to display the fees
        setState(() => prepareResponse = res);
      } catch (e) {
        final errMsg = "Error preparing payment: $e";
        debugPrint(errMsg);
        if (context.mounted) {
          Navigator.pop(context);
          final snackBar = SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(errMsg),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      } finally {
        setState(() => paymentInProgress = false);
      }
    }

    Future<void> onConfirmPressed() async {
      try {
        setState(() => paymentInProgress = true);
        // Confirm the payment with the prepare response
        SendPaymentRequest sendPaymentReq = SendPaymentRequest(
          prepareResponse: prepareResponse!,
        );
        SendPaymentResponse res = await widget.sdk.sendPayment(req: sendPaymentReq);
        debugPrint("Paid ${res.payment.txId}");
        if (context.mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        final errMsg = "Error sending payment: $e";
        debugPrint(errMsg);
        if (context.mounted) {
          Navigator.pop(context);
          final snackBar = SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(errMsg),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      } finally {
        setState(() => paymentInProgress = false);
      }
    }

    return AlertDialog(
      title: const Text("Send Payment"),
      content: paymentInProgress ? inProgressContent() : promptContent(),
      actions: paymentInProgress
          ? []
          : [
              TextButton(
                child: const Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              prepareResponse == null
                  ? TextButton(
                      onPressed: onOkPressed,
                      child: const Text("Ok"),
                    )
                  : TextButton(
                      onPressed: onConfirmPressed,
                      child: const Text("Confirm"),
                    ),
            ],
    );
  }
}
