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

## Step 1
In `pubspec.yaml` add the Breez SDK nodeless dependencies.
```yaml
  breez_liquid:
    git:
      url: https://github.com/breez/breez-sdk-liquid-dart
  flutter_breez_liquid:
    git:
      url: https://github.com/breez/breez-sdk-liquid-flutter
  flutter_rust_bridge: 2.4.0
```

Copy over the config helper and NodelessSdk singleton class.
- `lib/utils/config.dart`
- `lib/services/nodeless_sdk.dart`

Update the imports in `lib/main.dart` and set the `breezApiKey` in `lib/constants.dart`.
```dart
import 'package:bip39/bip39.dart' as bip39;
import 'package:flutter_breez_liquid/flutter_breez_liquid.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'constants.dart';
```
Update the `main()` function to initialize and connect to the Nodeless SDK.
We are also reading the mnemonic from the Flutter secure storage. 
If the mnemonic does not exist, then we generate a new one.
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize the Breez SDK Nodeless bindings
  await initialize();
  final NodelessSdk sdk = NodelessSdk();
  const secureStorage = FlutterSecureStorage();

  var mnemonic = await secureStorage.read(key: "mnemonic");
  if (mnemonic == null) {
    mnemonic = bip39.generateMnemonic();
    secureStorage.write(key: "mnemonic", value: mnemonic);
  }

  await reconnect(sdk: sdk, mnemonic: mnemonic);
  runApp(App(sdk: sdk));
}

Future<void> reconnect({
  required NodelessSdk sdk,
  required String mnemonic,
  LiquidNetwork network = LiquidNetwork.mainnet,
}) async {
  // Get the default config using the breezApiKey set in `lib/constants.dart`
  final config = await getConfig(
    network: network,
    breezApiKey: breezApiKey,
  );
  final req = ConnectRequest(
    mnemonic: mnemonic,
    config: config,
  );
}
```
Update the `App` and `HomePage` widget classes to pass the NodelessSdk singleton.
```dart
class App extends StatefulWidget {
  final NodelessSdk sdk;

  const App({super.key, required this.sdk});
```

```dart
class HomePage extends StatefulWidget {
  final NodelessSdk sdk;

  const HomePage({super.key, required this.sdk});
```