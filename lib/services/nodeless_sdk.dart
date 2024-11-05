import 'dart:async';
import 'package:flutter_breez_liquid/flutter_breez_liquid.dart' as liquid_sdk;
import 'package:rxdart/rxdart.dart';

class NodelessSdk {
  static final NodelessSdk _singleton = NodelessSdk._internal();
  factory NodelessSdk() => _singleton;

  NodelessSdk._internal() {
    initializeLogStream();
  }

  liquid_sdk.BindingLiquidSdk? _instance;
  liquid_sdk.BindingLiquidSdk? get instance => _instance;

  // Connect to the Nodeless SDK using the ConnectRequest.
  // Initialize, subscribe and update the SDK streams
  Future<void> connect({
    required liquid_sdk.ConnectRequest req,
  }) async {
    try {
      _instance = await liquid_sdk.connect(req: req);
      _initializeEventsStream(_instance!);
      _subscribeSdkStreams(_instance!);
      await _updateSdkStreams(_instance!);
    } catch (e) {
      _instance = null;
      rethrow;
    }
  }

  // Disconnect from the Nodeless SDK.
  // Unsubscribe from the SDK streams
  void disconnect() {
    if (_instance == null) {
      throw Exception();
    }

    _instance!.disconnect();
    _unsubscribeSdkStreams();
    _instance = null;
  }

  // SDK log stream
  StreamSubscription<liquid_sdk.LogEntry>? _sdkLogSubscription;
  Stream<liquid_sdk.LogEntry>? _sdkLogStream;

  final _logStreamController = StreamController<liquid_sdk.LogEntry>.broadcast();
  Stream<liquid_sdk.LogEntry> get logStream => _logStreamController.stream;

  // Call only once in your app entrypoint or SDK singleton initialization
  void initializeLogStream() {
    _sdkLogStream ??= liquid_sdk.breezLogStream().asBroadcastStream();
  }

  void _subscribeToLogStream() {
    _sdkLogSubscription = _sdkLogStream?.listen((logEntry) {
      _logStreamController.add(logEntry);
    }, onError: (e) {
      _logStreamController.addError(e);
    });
  }

  // SDK event stream
  StreamSubscription<liquid_sdk.SdkEvent>? _sdkEventSubscription;
  Stream<liquid_sdk.SdkEvent>? _sdkEventStream;

  final StreamController<PaymentEvent> _paymentEventStream = StreamController.broadcast();
  Stream<PaymentEvent> get paymentEventStream => _paymentEventStream.stream;

  void _initializeEventsStream(liquid_sdk.BindingLiquidSdk sdk) {
    _sdkEventStream ??= sdk.addEventListener().asBroadcastStream();
  }

  void _subscribeToEventStream(liquid_sdk.BindingLiquidSdk sdk) {
    _sdkEventSubscription = _sdkEventStream?.listen(
      (event) async {
        if (event.isPaymentEvent) {
          _paymentEventStream.add(PaymentEvent.fromSdkEvent(event));
        } else if (event is liquid_sdk.SdkEvent_PaymentFailed) {
          _paymentEventStream.addError(event);
        }
        await _updateSdkStreams(sdk);
      },
    );
  }

  // Subscribe to both log and event streams
  void _subscribeSdkStreams(liquid_sdk.BindingLiquidSdk sdk) {
    _subscribeToEventStream(sdk);
    _subscribeToLogStream();
  }

  // Unsubscribe from both log and event streams
  void _unsubscribeSdkStreams() {
    _sdkEventSubscription?.cancel();
    _sdkLogSubscription?.cancel();
  }

  // SDK streams for balance and payments
  final StreamController<liquid_sdk.GetInfoResponse> _getInfoController =
      BehaviorSubject<liquid_sdk.GetInfoResponse>();
  Stream<liquid_sdk.GetInfoResponse> get getInfoStream => _getInfoController.stream;

  final StreamController<liquid_sdk.Payment> _paymentResultStream = StreamController.broadcast();
  final StreamController<List<liquid_sdk.Payment>> _paymentsController =
      BehaviorSubject<List<liquid_sdk.Payment>>();
  Stream<List<liquid_sdk.Payment>> get paymentsStream => _paymentsController.stream;

  Future<void> _updateSdkStreams(liquid_sdk.BindingLiquidSdk sdk) async {
    await _getInfo(sdk);
    await _listPayments(sdk: sdk);
  }

  Future<liquid_sdk.GetInfoResponse> _getInfo(liquid_sdk.BindingLiquidSdk sdk) async {
    final getInfoRes = await sdk.getInfo();
    _getInfoController.add(getInfoRes);
    return getInfoRes;
  }

  Future<List<liquid_sdk.Payment>> _listPayments({
    required liquid_sdk.BindingLiquidSdk sdk,
  }) async {
    const req = liquid_sdk.ListPaymentsRequest();
    final paymentsList = await sdk.listPayments(req: req);
    _paymentsController.add(paymentsList);
    return paymentsList;
  }
}

extension PaymentEventExtension on liquid_sdk.SdkEvent {
  bool get isPaymentEvent {
    return this is liquid_sdk.SdkEvent_PaymentFailed ||
        this is liquid_sdk.SdkEvent_PaymentPending ||
        this is liquid_sdk.SdkEvent_PaymentRefunded ||
        this is liquid_sdk.SdkEvent_PaymentRefundPending ||
        this is liquid_sdk.SdkEvent_PaymentSucceeded ||
        this is liquid_sdk.SdkEvent_PaymentWaitingConfirmation;
  }
}

class PaymentEvent {
  final liquid_sdk.SdkEvent sdkEvent;
  final liquid_sdk.Payment payment;

  PaymentEvent({required this.sdkEvent, required this.payment});

  factory PaymentEvent.fromSdkEvent(liquid_sdk.SdkEvent event) {
    return PaymentEvent(sdkEvent: event, payment: (event as dynamic).details);
  }
}
