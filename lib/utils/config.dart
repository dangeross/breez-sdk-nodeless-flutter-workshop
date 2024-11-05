import 'package:flutter/material.dart';
import 'package:flutter_breez_liquid/flutter_breez_liquid.dart';
import 'package:path_provider/path_provider.dart';

Future<Config> getConfig({
  LiquidNetwork network = LiquidNetwork.mainnet,
  String? breezApiKey,
}) async {
  debugPrint("Getting default SDK config for network: $network");
  final defaultConf = defaultConfig(network: network, breezApiKey: breezApiKey);
  debugPrint("Getting SDK config");
  final workingDir = await getApplicationDocumentsDirectory();
  return defaultConf.copyWith(
    workingDir: workingDir.path,
  );
}

extension ConfigCopyWith on Config {
  Config copyWith({
    String? liquidElectrumUrl,
    String? bitcoinElectrumUrl,
    String? mempoolspaceUrl,
    String? workingDir,
    LiquidNetwork? network,
    BigInt? paymentTimeoutSec,
    int? zeroConfMinFeeRateMsat,
    String? breezApiKey,
  }) {
    return Config(
      liquidElectrumUrl: liquidElectrumUrl ?? this.liquidElectrumUrl,
      bitcoinElectrumUrl: bitcoinElectrumUrl ?? this.bitcoinElectrumUrl,
      mempoolspaceUrl: mempoolspaceUrl ?? this.mempoolspaceUrl,
      workingDir: workingDir ?? this.workingDir,
      network: network ?? this.network,
      paymentTimeoutSec: paymentTimeoutSec ?? this.paymentTimeoutSec,
      zeroConfMinFeeRateMsat: zeroConfMinFeeRateMsat ?? this.zeroConfMinFeeRateMsat,
      breezApiKey: breezApiKey ?? this.breezApiKey,
    );
  }
}
