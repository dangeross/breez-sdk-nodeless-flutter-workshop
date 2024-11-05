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

## Step 3
In `lib/home/home_page.dart` pass the Nodeless SDK singleton and `paymentEventStream` to the `ReceivePaymentDialog` widget.
```dart
                        builder: (context) => ReceivePaymentDialog(
                            sdk: widget.sdk.instance!, paymentEventStream: widget.sdk.paymentEventStream),
```
Update the imports in `lib/home/widgets/receive_dialog.dart`.
```dart
import 'package:breez_sdk_nodeless_flutter_workshop/services/nodeless_sdk.dart';
import 'package:flutter_breez_liquid/flutter_breez_liquid.dart';
```
Update the `ReceivePaymentDialog` widget class to pass the Nodeless SDK singleton and `paymentEventStream`.
```dart
class ReceivePaymentDialog extends StatefulWidget {
  final BindingLiquidSdk sdk;
  final Stream<PaymentEvent> paymentEventStream;

  const ReceivePaymentDialog({super.key, required this.sdk, required this.paymentEventStream});
```
Add to the `_ReceivePaymentDialogState` class a `streamSubscription` variable.
```dart
  StreamSubscription<PaymentEvent>? streamSubscription;
```
Replace the `initState()` function to listen to the `paymentEventStream` and pop the dialog when the created receive payment is paid.
```dart
  void initState() {
    super.initState();
    streamSubscription = widget.paymentEventStream.listen((paymentEvent) {
      if (invoiceDestination != null && invoiceDestination!.isNotEmpty) {
        final payment = paymentEvent.payment;
        // Is it the payment for our created invoice
        final doesDestinationMatch =
            payment.destination != null && payment.destination! == invoiceDestination!;
        // Has the payment state changed to Pending or Complete
        final isPaymentReceived = payment.paymentType == PaymentType.receive &&
            (payment.status == PaymentState.pending || payment.status == PaymentState.complete);

        if (doesDestinationMatch && isPaymentReceived) {
          debugPrint("Payment Received! Destination: ${payment.destination}, Status: ${payment.status}");
          if (mounted) {
            Navigator.of(context).pop();
          }
        }
      }
    });
  }
```
In the `dispose()` function cancel the `streamSubscription`.
```dart
  @override
  void dispose() {
    streamSubscription?.cancel();
    super.dispose();
  }
```
In the `onOkPressed()` function first prepare the receive payment using the input amount, store the receiving fees in the state, then confirm the payment using the response from the prepare request.
```dart
        // Parse the input amount and prepare to receive a lightning payment
        int amountSat = int.parse(payerAmountController.text);
        PrepareReceiveRequest prepareReceiveReq = PrepareReceiveRequest(
          paymentMethod: PaymentMethod.lightning,
          payerAmountSat: BigInt.from(amountSat),
        );
        PrepareReceiveResponse prepareResponse = await widget.sdk.prepareReceivePayment(
          req: prepareReceiveReq,
        );
        // Set the feesSat state from the prepare response. These are the fees the receiver will pay
        setState(() {
          payerAmountSat = prepareResponse.payerAmountSat?.toInt();
          feesSat = prepareResponse.feesSat.toInt();
        });
        // Confirm the payment with the prepare response
        ReceivePaymentRequest receiveReq = ReceivePaymentRequest(
          prepareResponse: prepareResponse,
        );
        ReceivePaymentResponse resp = await widget.sdk.receivePayment(req: receiveReq);
        debugPrint(
          "Created Invoice for $payerAmountSat sats with $feesSat sats fees.\nDestination:${resp.destination}",
        );
        // Set the invoiceDestination state to display the QR code
        setState(() => invoiceDestination = resp.destination);
```
