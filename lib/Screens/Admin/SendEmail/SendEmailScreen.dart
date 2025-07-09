import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:project/Screens/Admin/AdminDrawer.dart';
import 'package:project/Screens/Admin/SendEmail/SendEmailController.dart';

class EmailSenderScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EmailSenderViewModel(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          title: Container(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 100),
              child: Row(
                children: [
                  Image.asset(
                    "logo.png",
                    height: 45,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text("Readium")
                ],
              ),
            ),
          ),
          centerTitle: true,
        ),
        drawer: AdminDrawer(isDarkMode: false, selectedNavIndex: 2),
        body: Consumer<EmailSenderViewModel>(
          builder: (context, viewModel, _) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: viewModel.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                    controller: viewModel.recipientController,
                    decoration: InputDecoration(
                      labelText: 'Recipient email',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter recipient email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: viewModel.subjectController,
                    decoration: InputDecoration(
                      labelText: 'Subject',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter subject';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: TextFormField(
                      controller: viewModel.bodyController,
                      decoration: InputDecoration(
                        labelText: 'Message',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter message';
                        }
                        return null;
                      },
                      maxLines: null,
                      expands: true,
                      keyboardType: TextInputType.multiline,
                    ),
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        final response = await viewModel.sendEmail();
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(response)),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32.0,
                          vertical: 12.0,
                        ),
                        child: Text('SEND EMAIL'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
