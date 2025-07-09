import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

class EmailSenderViewModel extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final recipientController = TextEditingController(text: 'example@example.com');
  final subjectController = TextEditingController();
  final bodyController = TextEditingController();

  void disposeControllers() {
    recipientController.dispose();
    subjectController.dispose();
    bodyController.dispose();
  }

  Future<String> sendEmail() async {
    if (!formKey.currentState!.validate()) return 'Form not valid';

    final email = Email(
      body: bodyController.text,
      subject: subjectController.text,
      recipients: [recipientController.text],
      isHTML: false,
    );

    try {
      await FlutterEmailSender.send(email);
      return 'Email sent successfully';
    } catch (e) {
      return e.toString();
    }
  }
}
