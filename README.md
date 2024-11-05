# Breez SDK Nodeless Flutter Workshop

This workshop demonstrates how to integrate lightning payments into a Flutter
application. The workshop starts with a UI with some dialogs. Step by step we
will take you through integrating lightning payments.

- [Setup the SDK](https://github.com/dangeross/breez-sdk-nodeless-flutter-workshop/tree/step-1)
- [Update the balance](https://github.com/dangeross/breez-sdk-nodeless-flutter-workshop/tree/step-2)
- [Receive a payment](https://github.com/dangeross/breez-sdk-nodeless-flutter-workshop/tree/step-3)
- [Send a payment](https://github.com/dangeross/breez-sdk-nodeless-flutter-workshop/tree/step-4)

In order to follow this workshop, look at the steps below, each step in the workflow 
has it's own branch. You either paste in the code, or go to the next step.
At each step, explain what the new code is doing.

## Prerequisites
- Flutter 3.22.0 installed
- Android studio or Xcode installed
- An Android emulator or iOS simulator running.
- A valid breez API key set in `lib/constants.dart`

## Step 4
In `lib/home/home_page.dart` pass the Nodeless SDK singleton to the `SendPaymentDialog` widget.
```dart
                        builder: (context) => SendPaymentDialog(sdk: widget.sdk.instance!),
```
Update the imports in `lib/home/widgets/send_dialog.dart`.
```dart
import 'package:breez_sdk_nodeless_flutter_workshop/services/nodeless_sdk.dart';
import 'package:flutter_breez_liquid/flutter_breez_liquid.dart';
```
Update the `SendPaymentDialog` widget class to pass the Nodeless SDK singleton.
```dart
class SendPaymentDialog extends StatefulWidget {
  final BindingLiquidSdk sdk;

  const SendPaymentDialog({super.key, required this.sdk});
```
Add to the `_SendPaymentDialogState` class a `prepareResponse` variable.
```dart
  PrepareSendResponse? prepareResponse;
```
Replace the `promptContent()` function which will now show the send payment fees once the invoice is pasted.
```dart
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
```
In the `onOkPressed()` function prepare the send payment using the pasted invoice, then store the prepare response in the state to show the fees.
```dart
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
```
In the `onConfirmPressed()` function once the fees are accepted, use the `prepareResponse` to confirm the payment.
```dart
        // Confirm the payment with the prepare response
        SendPaymentRequest sendPaymentReq = SendPaymentRequest(
          prepareResponse: prepareResponse!,
        );
        SendPaymentResponse res = await widget.sdk.sendPayment(req: sendPaymentReq);
        debugPrint("Paid ${res.payment.txId}");
```
Update the `AlertDialog` actions to either show the Ok or Confirm button depending if the send payment has been prepared.
```dart
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
```
