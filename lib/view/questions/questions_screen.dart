// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:valu_quest/APIs/urls.dart';
import 'package:valu_quest/Utils/app_colors.dart';
import 'package:valu_quest/Utils/log_utils.dart';
import 'package:http/http.dart' as http;
import 'package:valu_quest/models/question_model.dart';
import 'package:valu_quest/view/results/result_screen.dart';

import '../../Utils/snackbar_utils.dart';

class QuestionsScreen extends StatefulWidget {
  final Function dataStored;
  final String name;
  final String surname;
  final String gender;
  final String dob;
  final String email;
  const QuestionsScreen(
      {super.key,
      required this.name,
      required this.email,
      required this.gender,
      required this.dob,
      required this.surname,
      required this.dataStored});

  @override
  State<QuestionsScreen> createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  List<QuestionsModel> questions = [];
  int currentQuestionIndex = 0;
  Map<String, Map<String, dynamic>> selectedAnswers = {};

  bool questionsLoading = false;
  bool isSelected = false;

  TextEditingController answerController = TextEditingController();

  void setLoading(bool status) {
    setState(() {
      questionsLoading = status;
    });
  }

  Future<void> loadQuestions() async {
    setLoading(true);
    try {
      final response = await http.get(
        Uri.parse("${URLs.baseURL}${URLs.getQuestionsURL}"),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        LogUtils.log("API : ${URLs.baseURL}${URLs.getQuestionsURL}",
            jsonDecode(response.body)['data']);

        if (jsonDecode(response.body)['success'] == true) {
          List data = jsonDecode(response.body)['data'];
          data.map((question) {
            questions.add(QuestionsModel.fromJson(question));
          }).toList();
        }
      } else {
        setLoading(false);
        LogUtils.log("loadQuestions(): ${response.statusCode}", response);
      }
    } catch (e) {
      setLoading(false);
      LogUtils.log("loadQuestions()", e);
    }
    setLoading(false);
  }

  Future<void> storeQuestions() async {
    setLoading(true);
    try {
      final response = await http.post(
        Uri.parse("${URLs.baseURL}${URLs.storeQuestionsURL}"),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "name": widget.name,
          "surname": widget.surname,
          "gender": widget.gender == "Male" ? "1" : "2",
          "dob": widget.dob,
          "email": widget.email,
          "selectedAnswers": selectedAnswers,
        }),
      );
      LogUtils.log(
          "API : ${URLs.baseURL}${URLs.storeQuestionsURL} ", response.body);
      if (response.statusCode == 200 &&
          jsonDecode(response.body)['success'] == true) {
        LogUtils.log("API : ${URLs.baseURL}${URLs.storeQuestionsURL}",
            jsonDecode(response.body));
        widget.dataStored();
        SnacbarUtils.show(
            context, "Your survey submitted successfully!", false);
        LogUtils.log("storeQuestions(): ${response.statusCode}",
            "Data Inserted successfully!");
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ResultScreen(
                selectedAnswers: selectedAnswers,
              ),
            ));
      } else {
        SnacbarUtils.show(context,
            "Something went wrong!, Error: ${response.statusCode} ", true);
        LogUtils.log("storeQuestions(): ${response.statusCode}", response);
      }
    } catch (e) {
      setLoading(false);
      SnacbarUtils.show(context, e.toString(), true);
    }
    setLoading(false);
  }

  void goNext() {
    setState(() {
      if (currentQuestionIndex < questions.length - 1) {
        currentQuestionIndex++;
      } else {
        storeQuestions();
        LogUtils.log("GoNext", "End of Quiz");
      }
    });
    if (selectedAnswers
        .containsKey(questions[currentQuestionIndex].questionId.toString())) {
      answerController.text =
          selectedAnswers[questions[currentQuestionIndex].questionId.toString()]
              ?['option_value'];
    } else {
      answerController.clear();
    }
  }

  void goBack() {
    setState(() {
      if (currentQuestionIndex > 0) {
        currentQuestionIndex--;
      } else {
        LogUtils.log("GoBack", "No previous question");
      }
    });
    if (selectedAnswers.containsKey(
            questions[currentQuestionIndex].questionId.toString()) &&
        questions[currentQuestionIndex].quesType != '2') {
      answerController.text =
          selectedAnswers[questions[currentQuestionIndex].questionId.toString()]
              ?['option_value'];
    } else {
      answerController.clear();
    }
  }

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    loadQuestions();
  }

  @override
  void dispose() {
    // ignore: todo
    // TODO: implement dispose
    super.dispose();
    answerController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColor.backgroundColor,
      appBar: AppBar(
        title: const Text("VALU Quest"),
        backgroundColor: AppColor.backgroundColor,
        centerTitle: true,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: !questionsLoading
            ? questions.isNotEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Question ${currentQuestionIndex + 1}',
                        style: const TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Text(
                        questions[currentQuestionIndex].questionName ??
                            "No Question",
                        style: const TextStyle(
                          fontSize: 18.0,
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      isSelected
                          ? const Text(
                              "Answer is mendatory*",
                              style: TextStyle(color: Colors.red, fontSize: 18),
                            )
                          : const SizedBox.shrink(),
                      const SizedBox(height: 20.0),
                      if (questions[currentQuestionIndex].quesType == '2') ...[
                        ...?(questions[currentQuestionIndex].options)
                            ?.map((option) {
                          bool shouldShowOption = false;
                          if (selectedAnswers.containsKey(
                              questions[currentQuestionIndex]
                                  .questionId
                                  .toString())) {
                            String opId = selectedAnswers[
                                questions[currentQuestionIndex]
                                    .questionId
                                    .toString()]!['optionId'];

                            String opRefId = selectedAnswers[
                                    questions[currentQuestionIndex]
                                        .questionId
                                        .toString()]!['refOptionId'] ??
                                "";
                            if (opId == option.refOptionId ||
                                (option.refOptionId == opRefId)) {
                              shouldShowOption = true;
                            }
                          }
                          return shouldShowOption || option.refOptionId == null
                              ? GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      String qId =
                                          questions[currentQuestionIndex]
                                              .questionId
                                              .toString();
                                      if (selectedAnswers.containsKey(qId)) {
                                        selectedAnswers[qId]?['optionId'] =
                                            option.optionId;
                                        selectedAnswers[qId]?['option_value'] =
                                            option.optionValue;
                                        selectedAnswers[qId]?['refOptionId'] =
                                            option.refOptionId;
                                      } else {
                                        Map<String, dynamic> questionMap = {
                                          "questionId":
                                              questions[currentQuestionIndex]
                                                  .questionId,
                                          "questionName":
                                              questions[currentQuestionIndex]
                                                  .questionName,
                                          "optionId": option.optionId,
                                          "option_value": option.optionValue,
                                          "refOptionId": option.refOptionId,
                                          "blockId":
                                              questions[currentQuestionIndex]
                                                  .blockId
                                        };
                                        selectedAnswers[qId] = questionMap;
                                      }
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(10.0),
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 5.0),
                                    decoration: BoxDecoration(
                                      color: selectedAnswers[questions[
                                                          currentQuestionIndex]
                                                      .questionId
                                                      .toString()]?['optionId']
                                                  .toString() ==
                                              option.optionId
                                          ? Colors.blue
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: Text(
                                      option.optionName!,
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        color: selectedAnswers[questions[
                                                        currentQuestionIndex]
                                                    .questionId
                                                    .toString()]?['optionId'] ==
                                                option.optionId
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink();
                        }).toList(),
                      ] else ...[
                        TextField(
                          onChanged: (value) {
                            setState(() {
                              String qId = questions[currentQuestionIndex]
                                  .questionId
                                  .toString();
                              if (selectedAnswers.containsKey(qId)) {
                                selectedAnswers[qId]?['optionId'] = null;
                                selectedAnswers[qId]?['option_value'] =
                                    answerController.text;
                              } else {
                                Map<String, dynamic> questionMap = {
                                  "questionId": questions[currentQuestionIndex]
                                      .questionId,
                                  "optionId": null,
                                  "option_value": answerController.text,
                                  "questionName":
                                      questions[currentQuestionIndex]
                                          .questionName,
                                  "blockId":
                                      questions[currentQuestionIndex].blockId
                                };
                                selectedAnswers[qId] = questionMap;
                              }
                            });
                          },
                          controller: answerController,
                          maxLines: null,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Enter your answer...',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                      ],
                      const SizedBox(height: 20.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColor.buttonColor,
                                foregroundColor: AppColor.backgroundColor),
                            onPressed: () {
                              if (FocusScope.of(context).hasFocus) {
                                FocusScope.of(context).unfocus();
                              }

                              goBack();
                            },
                            child: const Text(
                              'Back',
                              style: TextStyle(fontSize: 18.0),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColor.buttonColor,
                                foregroundColor: AppColor.backgroundColor),
                            onPressed: () {
                              if (FocusScope.of(context).hasFocus) {
                                FocusScope.of(context).unfocus();
                              }
                              String qId = questions[currentQuestionIndex]
                                  .questionId
                                  .toString();

                              if (selectedAnswers.containsKey(qId) &&
                                  selectedAnswers[qId]!['option_value']
                                      .toString()
                                      .isNotEmpty) {
                                isSelected = false;
                                goNext();
                              } else {
                                setState(() {
                                  isSelected = true;
                                });
                              }
                            },
                            child: Text(
                              currentQuestionIndex < questions.length - 1
                                  ? 'Next'
                                  : 'Finish',
                              style: const TextStyle(fontSize: 18.0),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : const Center(
                    child: Text(
                      "No Question found!",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  )
            : Center(
                child: LoadingAnimationWidget.inkDrop(
                    color: AppColor.buttonColor, size: 50)),
      ),
    );
  }
}
