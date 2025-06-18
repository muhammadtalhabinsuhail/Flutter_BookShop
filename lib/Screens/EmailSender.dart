import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

class EmailSender extends StatefulWidget {
  const EmailSender({ Key? key }) : super(key: key);

  @override
  _EmailSenderState createState() => _EmailSenderState();
}

class _EmailSenderState extends State<EmailSender> {

  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();



  Future<void> sendEmail() async {
    final Email email = Email(
      body: _bodyController.text,
      subject: _subjectController.text,
      recipients: ['muhammadtalhabinsuhail@gmail.com'], // replace with your recipient
      isHTML: false,
    );

    try {
      await FlutterEmailSender.send(email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Email app opened successfully")),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to send email: $error")),
      );
    }
  }






  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Send Email'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _subjectController,
              decoration: InputDecoration(
                labelText: 'Subject',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _bodyController,
              maxLines: 6,
              decoration: InputDecoration(
                labelText: 'Message',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: sendEmail,
              icon: Icon(Icons.send),
              label: Text('Send Email'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}