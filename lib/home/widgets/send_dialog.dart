import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SendPaymentDialog extends StatefulWidget {
  const SendPaymentDialog({super.key});

  @override
  State<SendPaymentDialog> createState() => _SendPaymentDialogState();
}

class _SendPaymentDialogState extends State<SendPaymentDialog> {
  final TextEditingController invoiceController = TextEditingController();
  bool paymentInProgress = false;

  @override
  Widget build(BuildContext context) {
    Widget promptContent() {
      return TextField(
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
            Text("Sending..."),
            const SizedBox(height: 16),
            const CircularProgressIndicator(color: Colors.blue),
          ],
        ),
      );
    }

    Future<void> onOkPressed() async {
      try {
        setState(() => paymentInProgress = true);
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
              TextButton(
                onPressed: onOkPressed,
                child: const Text("Ok"),
              ),
            ],
    );
  }
}
