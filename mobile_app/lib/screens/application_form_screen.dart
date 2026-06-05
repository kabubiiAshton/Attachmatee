import 'package:flutter/material.dart';

class ApplicationFormScreen extends StatefulWidget {
  final Map<String, dynamic> job;

  const ApplicationFormScreen({
    super.key,
    required this.job,
  });

  @override
  State<ApplicationFormScreen> createState() =>
      _ApplicationFormScreenState();
}

class _ApplicationFormScreenState
    extends State<ApplicationFormScreen> {

  final fullNameController =
      TextEditingController();

  final emailController =
      TextEditingController();

  final phoneController =
      TextEditingController();

  final coverLetterController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Application Form",
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Text(
              widget.job["role"],
              style: const TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            Text(
              widget.job["company"],
            ),

            const SizedBox(height: 30),

            TextField(
              controller:
                  fullNameController,
              decoration:
                  const InputDecoration(
                labelText: "Full Name",
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller:
                  emailController,
              decoration:
                  const InputDecoration(
                labelText: "Email",
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller:
                  phoneController,
              decoration:
                  const InputDecoration(
                labelText: "Phone Number",
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller:
                  coverLetterController,
              maxLines: 6,
              decoration:
                  const InputDecoration(
                labelText:
                    "Cover Letter",
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton(
                onPressed: () {

                  showDialog(
                    context: context,
                    builder: (_) =>
                        AlertDialog(
                      title: const Text(
                        "Application Submitted",
                      ),
                      content: Text(
                        "You have successfully applied for ${widget.job["role"]}.",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {

                            Navigator.pop(
                                context);

                            Navigator.pop(
                                context);
                          },
                          child:
                              const Text(
                            "OK",
                          ),
                        )
                      ],
                    ),
                  );
                },
                child:
                    const Text("Submit"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}