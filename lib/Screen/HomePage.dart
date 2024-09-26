import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:excel/excel.dart';
import 'question_page.dart'; // Import the QuestionPage

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? selectedSemester = 'Semester II';
  String? selectedSubject;
  String? selectedField;
  String? pickedFileName;
  List<String> questions = []; // Store extracted questions

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text(
          'ATTAINMENT AI',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Container(
          width: 600,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  buildDropdown('Semester II', ['Semester I', 'Semester II'],
                      selectedSemester, (value) {
                    setState(() {
                      selectedSemester = value;
                    });
                  }),
                  buildDropdown(
                      'Subject', ['Subject 1', 'Subject 2'], selectedSubject,
                      (value) {
                    setState(() {
                      selectedSubject = value;
                    });
                  }),
                  buildDropdown('Field', ['Field 1', 'Field 2'], selectedField,
                      (value) {
                    setState(() {
                      selectedField = value;
                    });
                  }),
                ],
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () async {
                  await pickFile(); // Ensure the method is awaited
                },
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      pickedFileName ?? 'Drag And Drop Excel File',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  if (questions.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            QuestionPage(questions: questions),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Please select a valid Excel file')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: Text(
                  'RUN AI',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to pick file
  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xls', 'xlsx'], // Allow both .xls and .xlsx
    );

    if (result != null) {
      PlatformFile file = result.files.first;
      setState(() {
        pickedFileName = file.name;
      });

      // Process the Excel file to extract questions
      await extractQuestions(file.path!); // Ensure this method is awaited
    } else {
      setState(() {
        pickedFileName = null;
      });
    }
  }

  // Function to extract questions from the Excel file
  Future<void> extractQuestions(String filePath) async {
    try {
      var file = File(filePath);
      var bytes = file.readAsBytesSync();
      print("File size: ${bytes.length} bytes");

      // Try decoding the Excel file
      var excel = Excel.decodeBytes(bytes);
      print("Excel file decoded successfully");

      questions.clear(); // Clear any existing questions

      // Iterate over sheets and rows to extract questions
      for (var table in excel.tables.keys) {
        var sheet = excel.tables[table]!;
        print("Processing sheet: $table"); // Debugging log

        for (var row in sheet.rows) {
          print(
              "Row data: ${row.map((cell) => cell?.value).toList()}"); // Debugging log

          // Assuming questions are in the first column
          String? question = row[0]?.value?.toString();
          if (question != null && question.isNotEmpty) {
            questions.add(question);
            print("Added question: $question"); // Debugging log
          }
        }
      }

      if (questions.isEmpty) {
        // If no questions were found
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('No questions found in the selected Excel file.')),
        );
      } else {
        setState(() {
          pickedFileName = 'File loaded with ${questions.length} questions';
        });
      }
    } catch (e) {
      print("Error reading Excel file: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Error reading Excel file. Please ensure it is a valid .xls or .xlsx file.')),
      );
    }
  }

  // Function to build dropdown menus
  Widget buildDropdown(String label, List<String> items, String? selectedItem,
      Function(String?) onChanged) {
    return DropdownButton<String>(
      value: selectedItem,
      hint: Text(label, style: TextStyle(color: Colors.white)),
      dropdownColor: Colors.grey[800],
      style: TextStyle(color: Colors.white),
      iconEnabledColor: Colors.white,
      items: items.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, style: TextStyle(color: Colors.white)),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
