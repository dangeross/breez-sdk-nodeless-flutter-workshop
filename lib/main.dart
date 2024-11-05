import 'package:bip39/bip39.dart' as bip39;
import 'package:breez_sdk_nodeless_flutter_workshop/home/home_page.dart';
import 'package:breez_sdk_nodeless_flutter_workshop/services/nodeless_sdk.dart';
import 'package:breez_sdk_nodeless_flutter_workshop/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_breez_liquid/flutter_breez_liquid.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'constants.dart';

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
  await sdk.connect(req: req);
}

class App extends StatefulWidget {
  final NodelessSdk sdk;

  const App({super.key, required this.sdk});

  static const title = 'Breez SDK Nodeless Demo';

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: App.title,
      theme: ThemeData.from(colorScheme: ColorScheme.fromSeed(seedColor: Colors.white), useMaterial3: true),
      home: HomePage(sdk: widget.sdk),
    );
  }
}
