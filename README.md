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

## Step 2
In `lib/home/home_page.dart` pass the Nodeless SDK `getInfoStream` to the `Balance` widget.
```dart
            Balance(getInfoStream: widget.sdk.getInfoStream),
```
Update the imports in `lib/home/widgets/balance.dart`.
```dart
import 'package:breez_sdk_nodeless_flutter_workshop/services/nodeless_sdk.dart';
import 'package:flutter_breez_liquid/flutter_breez_liquid.dart';
```
Update the `Balance` widget class to pass the Nodeless SDK `getInfoStream`.
```dart
class Balance extends StatelessWidget {
  final Stream<GetInfoResponse> getInfoStream;

  const Balance({super.key, required this.getInfoStream});
```
Replace the `build()` function with a StreamBuilder that listens to the `getInfoStream` and updates the widget.
Whenever the getInfo changes the wallet balance and pending balanaces are updated.
```dart
  Widget build(BuildContext context) {
    return StreamBuilder<GetInfoResponse>(
      stream: getInfoStream,
      builder: (context, getInfoSnapshot) {
        if (getInfoSnapshot.hasError) {
          return Center(child: Text('Error: ${getInfoSnapshot.error}'));
        }

        if (!getInfoSnapshot.hasData) {
          return const Center(child: Text('Loading...'));
        }

        final getInfo = getInfoSnapshot.data!;

        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "${getInfo.balanceSat} sats",
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Colors.blue),
              ),
              if (getInfo.pendingReceiveSat != BigInt.zero) ...[
                Text(
                  "Pending Receive: ${getInfo.pendingReceiveSat} sats",
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.blueGrey),
                ),
              ],
              if (getInfo.pendingSendSat != BigInt.zero) ...[
                Text(
                  "Pending Send: ${getInfo.pendingSendSat} sats",
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.blueGrey),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
```