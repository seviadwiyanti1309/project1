import 'package:flutter/material.dart';

class DocumentPage extends StatefulWidget {
  const DocumentPage({super.key});

  @override
  State<DocumentPage> createState() => _DocumentPageState();
}

class _DocumentPageState extends State<DocumentPage> {
  String? selectedPosition;
  String fileName = "No file chosen";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                  top: 60, left: 20, right: 20, bottom: 30),
              decoration: const BoxDecoration(
                color: Color(0xFF5B06A9),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(Icons.arrow_back, color: Colors.white, size: 28),
                  SizedBox(height: 20),
                  Text(
                    "Job Registration",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Please fill out all the required fields\nand attach your resume below.",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // FORM
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  _label("Name"),
                  Row(
                    children: [
                      Expanded(child: _textfield(hint: "First Name")),
                      const SizedBox(width: 10),
                      Expanded(child: _textfield(hint: "Last Name")),
                    ],
                  ),

                  const SizedBox(height: 16),
                  _label("Address"),
                  _textfield(hint: "Address"),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _textfield(hint: "City")),
                      const SizedBox(width: 10),
                      Expanded(child: _textfield(hint: "State")),
                    ],
                  ),

                  const SizedBox(height: 16),
                  _label("Home Phone"),
                  _textfield(hint: "+62"),

                  const SizedBox(height: 16),
                  _label("Email"),
                  Row(
                    children: [
                      Expanded(child: _textfield(hint: "Email")),
                      const SizedBox(width: 10),
                      _textfield(hint: ".com", width: 70),
                    ],
                  ),

                  const SizedBox(height: 16),
                  _label("Upload your resume"),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        fileName = "resume_example.pdf";
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Text("Choose File",
                              style: TextStyle(color: Colors.grey)),
                          const SizedBox(width: 10),
                          Text(fileName,
                              style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  _label("Position You Are Applying For"),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        hint: const Text("Web Developer"),
                        value: selectedPosition,
                        items: const [
                          DropdownMenuItem(
                              value: "Web Developer",
                              child: Text("Web Developer")),
                          DropdownMenuItem(
                              value: "UI/UX Designer",
                              child: Text("UI/UX Designer")),
                          DropdownMenuItem(
                              value: "Mobile Developer",
                              child: Text("Mobile Developer")),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedPosition = value;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CC06C),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 35, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      onPressed: () {},
                      child: const Text(
                        "Submit",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // COMPONENTS

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _textfield({required String hint, double? width}) {
    return Container(
      width: width,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
        ),
      ),
    );
  }
}
