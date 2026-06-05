import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState
    extends State<ProfileScreen> {

  final nameController =
      TextEditingController(
    text: "Ashton Ndegwa",
  );

  final emailController =
      TextEditingController(
    text: "ashton@example.com",
  );

  final universityController =
      TextEditingController(
    text: "JKUAT",
  );

  final courseController =
      TextEditingController(
    text:
        "Bachelor of Business Information Technology",
  );

  final yearController =
      TextEditingController(
    text: "3",
  );

  final githubController =
      TextEditingController();

  final linkedinController =
      TextEditingController();

  final portfolioController =
      TextEditingController();

  List<String> skills = [
    "Flutter",
    "Django",
    "Python",
  ];

  final skillController =
      TextEditingController();

  double profileCompletion() {

    int completed = 0;

    if (nameController.text.isNotEmpty) completed++;
    if (emailController.text.isNotEmpty) completed++;
    if (universityController.text.isNotEmpty) completed++;
    if (courseController.text.isNotEmpty) completed++;
    if (yearController.text.isNotEmpty) completed++;
    if (githubController.text.isNotEmpty) completed++;
    if (linkedinController.text.isNotEmpty) completed++;
    if (portfolioController.text.isNotEmpty) completed++;
    if (skills.isNotEmpty) completed++;

    return completed / 9;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor:
          const Color(0xFFF8FAFC),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            // =====================
            // PROFILE HEADER
            // =====================

            Center(
              child: Column(
                children: [

                  Stack(
                    children: [

                      const CircleAvatar(
                        radius: 55,
                        backgroundColor:
                            Colors.blue,
                        child: Icon(
                          Icons.person,
                          color:
                              Colors.white,
                          size: 55,
                        ),
                      ),

                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration:
                              const BoxDecoration(
                            color:
                                Colors.white,
                            shape:
                                BoxShape.circle,
                          ),
                          child: IconButton(
                            icon:
                                const Icon(
                              Icons.camera_alt,
                              color:
                                  Colors.blue,
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(
                                      context)
                                  .showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Image upload coming soon",
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  Text(
                    nameController.text,
                    style:
                        const TextStyle(
                      fontSize: 22,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  Text(
                    emailController.text,
                    style:
                        const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // =====================
            // PROFILE COMPLETION
            // =====================

            Card(
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                        20),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.all(
                        20),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [

                    const Text(
                      "Profile Completion",
                      style: TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                        height: 10),

                    LinearProgressIndicator(
                      value:
                          profileCompletion(),
                      minHeight: 10,
                    ),

                    const SizedBox(
                        height: 10),

                    Text(
                      "${(profileCompletion() * 100).toInt()}% Completed",
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "Personal Information",
              style: TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            buildField(
              "Full Name",
              nameController,
            ),

            buildField(
              "Email",
              emailController,
            ),

            buildField(
              "University",
              universityController,
            ),

            buildField(
              "Course",
              courseController,
            ),

            buildField(
              "Year of Study",
              yearController,
            ),

            const SizedBox(height: 25),

            // =====================
            // SKILLS
            // =====================

            const Text(
              "Skills",
              style: TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            Row(
              children: [

                Expanded(
                  child: TextField(
                    controller:
                        skillController,
                    decoration:
                        InputDecoration(
                      hintText:
                          "Add skill",
                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                                    15),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                ElevatedButton(
                  onPressed: () {

                    if (skillController
                        .text
                        .isNotEmpty) {

                      setState(() {

                        skills.add(
                          skillController
                              .text,
                        );

                        skillController
                            .clear();
                      });
                    }
                  },
                  child:
                      const Text("Add"),
                ),
              ],
            ),

            const SizedBox(height: 15),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: skills
                  .map(
                    (skill) => Chip(
                      label: Text(skill),
                      deleteIcon:
                          const Icon(
                        Icons.close,
                        size: 18,
                      ),
                      onDeleted: () {

                        setState(() {

                          skills.remove(
                            skill,
                          );
                        });
                      },
                    ),
                  )
                  .toList(),
            ),

            const SizedBox(height: 25),

            // =====================
            // CV
            // =====================

            const Text(
              "Curriculum Vitae",
              style: TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(
                      20),
              decoration:
                  BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(
                        15),
                border: Border.all(
                  color: Colors.grey
                      .shade300,
                ),
              ),
              child: Column(
                children: [

                  const Icon(
                    Icons.upload_file,
                    size: 40,
                    color: Colors.blue,
                  ),

                  const SizedBox(
                      height: 10),

                  const Text(
                    "Upload CV",
                  ),

                  const SizedBox(
                      height: 10),

                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(
                              context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Connect File Picker here",
                          ),
                        ),
                      );
                    },
                    child: const Text(
                        "Choose File"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // =====================
            // LINKS
            // =====================

            const Text(
              "Professional Links",
              style: TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            buildField(
              "GitHub Profile",
              githubController,
            ),

            buildField(
              "LinkedIn Profile",
              linkedinController,
            ),

            buildField(
              "Portfolio Website",
              portfolioController,
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton.icon(
                icon:
                    const Icon(Icons.save),

                style:
                    ElevatedButton
                        .styleFrom(
                  backgroundColor:
                      const Color(
                          0xFF2563EB),
                  foregroundColor:
                      Colors.white,
                ),

                onPressed: () {

                  ScaffoldMessenger.of(
                          context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Profile Updated Successfully",
                      ),
                    ),
                  );
                },

                label:
                    const Text(
                  "Save Changes",
                ),
              ),
            ),
            const SizedBox(height: 30),

Container(
  width: double.infinity,
  height: 55,

  child: OutlinedButton.icon(
    icon: const Icon(
      Icons.logout,
      color: Colors.red,
    ),

    label: const Text(
      "Logout",
      style: TextStyle(
        color: Colors.red,
      ),
    ),

    onPressed: () {

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/',
        (route) => false,
      );
    },
  ),
),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget buildField(
    String label,
    TextEditingController controller,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 15,
      ),
      child: TextField(
        controller: controller,

        decoration: InputDecoration(
          labelText: label,

          filled: true,
          fillColor: Colors.white,

          border:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
                    15),
          ),
        ),
      ),
    );
  }
}
