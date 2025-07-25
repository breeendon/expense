import 'package:flutter/material.dart';
List<String> tests = [];
List<String> scores = [];

class ScoresPage extends StatefulWidget {
  const ScoresPage({super.key});
  

  @override
  State<ScoresPage> createState() => _ScoresPageState();
}

class _ScoresPageState extends State<ScoresPage> {
  
  int score = 5;
  String test = "";

  void addScore(int? nscore) {
    setState(() {
      scores.add(nscore.toString());
    });
  }

  void addTest(String? test) {
    setState(() {
       tests.add(test.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownMenu(
                      onSelected: (test) {
                        tests.add(test.toString());
                      },
                      hintText: 'Select an AP Exam',
                      dropdownMenuEntries: const <DropdownMenuEntry<String>>[
                        DropdownMenuEntry(
                            value: 'AP African American Studies',
                            label: 'AP African American Studies'),
                        DropdownMenuEntry(
                            value: 'AP Art History', label: 'AP Art History'),
                        DropdownMenuEntry(
                            value: 'AP 2-D Art and Design',
                            label: 'AP 2-D Art and Design'),
                        DropdownMenuEntry(
                            value: 'AP 3-D Art and Design',
                            label: 'AP 3-D Art and Design'),
                        DropdownMenuEntry(
                            value: 'AP Drawing', label: 'AP Drawing'),
                        DropdownMenuEntry(
                            value: 'AP Biology', label: 'AP Biology'),
                        DropdownMenuEntry(
                            value: 'AP Calculus AB', label: 'AP Calculus AB'),
                        DropdownMenuEntry(
                            value: 'AP Calculus BC', label: 'AP Calculus BC'),
                        DropdownMenuEntry(
                            value: 'AP Calculus BC: AB Subscore', label: 'AP Calculus BC: AB Subscore'),
                        DropdownMenuEntry(
                            value: 'AP Chemistry', label: 'AP Chemistry'),
                        DropdownMenuEntry(
                            value: 'AP Chinese Language and Culture',
                            label: 'AP Chinese Language and Culture'),
                        DropdownMenuEntry(
                            value: 'AP Comparative Government and Politics',
                            label: 'AP Comparative Government and Politics'),
                        DropdownMenuEntry(
                            value: 'AP Computer Science A',
                            label: 'AP Computer Science A'),
                        DropdownMenuEntry(
                            value: 'AP Computer Science Principles',
                            label: 'AP Computer Science Principles'),
                        DropdownMenuEntry(
                            value: 'AP English Language and Composition',
                            label: 'AP English Language and Composition'),
                        DropdownMenuEntry(
                            value: 'AP English Literature and Composition',
                            label: 'AP English Literature and Composition'),
                        DropdownMenuEntry(
                            value: 'AP Environmental Science',
                            label: 'AP Environmental Science'),
                        DropdownMenuEntry(
                            value: 'AP European History',
                            label: 'AP European History'),
                        DropdownMenuEntry(
                            value: 'AP French Language and Culture',
                            label: 'AP French Language and Culture'),
                        DropdownMenuEntry(
                            value: 'AP German Language and Culture',
                            label: 'AP German Language and Culture'),
                        DropdownMenuEntry(
                            value: 'AP Human Geography',
                            label: 'AP Human Geography'),
                        DropdownMenuEntry(
                            value: 'AP Italian Language and Culture',
                            label: 'AP Italian Language and Culture'),
                        DropdownMenuEntry(
                            value: 'AP Japanese Language and Culture',
                            label: 'AP Japanese Language and Culture'),
                        DropdownMenuEntry(value: 'AP Latin', label: 'AP Latin'),
                        DropdownMenuEntry(
                            value: 'AP Macroeconomics',
                            label: 'AP Macroeconomics'),
                        DropdownMenuEntry(
                            value: 'AP Microeconomics',
                            label: 'AP Microeconomics'),
                        DropdownMenuEntry(
                            value: 'AP Music Theory', label: 'AP Music Theory'),
                        DropdownMenuEntry(
                            value: 'AP Physics 1: Algebra-Based',
                            label: 'AP Physics 1: Algebra-Based'),
                        DropdownMenuEntry(
                            value: 'AP Physics 2: Algebra-Based',
                            label: 'AP Physics 2: Algebra-Based'),
                        DropdownMenuEntry(
                            value: 'AP Physics C: Electricity and Magnetism',
                            label: 'AP Physics C: Electricity and Magnetism'),
                        DropdownMenuEntry(
                            value: 'AP Physics C: Mechanics',
                            label: 'AP Physics C: Mechanics'),
                        DropdownMenuEntry(
                            value: 'AP Psychology', label: 'AP Psychology'),
                        DropdownMenuEntry(
                            value: 'AP Research', label: 'AP Research'),
                        DropdownMenuEntry(
                            value: 'AP Seminar', label: 'AP Seminar'),
                        DropdownMenuEntry(
                            value: 'AP Spanish Language and Culture',
                            label: 'AP Spanish Language and Culture'),
                        DropdownMenuEntry(
                            value: 'AP Spanish Literature and Culture',
                            label: 'AP Spanish Literature and Culture'),
                        DropdownMenuEntry(
                            value: 'AP Statistics', label: 'AP Statistics'),
                        DropdownMenuEntry(
                            value: 'AP United States Government and Politics',
                            label: 'AP United States Government and Politics'),
                        DropdownMenuEntry(
                            value: 'AP United States History',
                            label: 'AP United States History'),
                        DropdownMenuEntry(
                            value: 'AP World History: Modern',
                            label: 'AP World History: Modern'),
                      ]),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(100.0, 0.0, 0.0, 0.0),
                  child: DropdownButton(
                    hint: const Text('Score'),
                    onChanged: addScore,
                    items: const [
                      DropdownMenuItem<int>(
                        value: 1,
                        child: Text('1'),
                      ),
                      DropdownMenuItem<int>(
                        value: 2,
                        child: Text('2'),
                      ),
                      DropdownMenuItem<int>(
                        value: 3,
                        child: Text('3'),
                      ),
                      DropdownMenuItem<int>(
                        value: 4,
                        child: Text('4'),
                      ),
                      DropdownMenuItem<int>(
                        value: 5,
                        child: Text('5'),
                      ),
                    ],
                    value: score,
                  ),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: tests.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    child: ListTile(
                        title: Text(tests[index]),
                        trailing: Text(
                          // ignore: deprecated_member_use
                          textScaleFactor: 1.5,
                          scores[index],
                        )),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
