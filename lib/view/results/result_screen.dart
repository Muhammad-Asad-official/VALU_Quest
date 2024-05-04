import 'package:d_chart/d_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:spider_chart/spider_chart.dart';
import 'package:valu_quest/Utils/app_colors.dart';
import 'package:valu_quest/Utils/log_utils.dart';
import 'package:valu_quest/view/results/widgets/line_chart.dart';
import 'package:valu_quest/view/results/widgets/table.dart';

class ResultScreen extends StatefulWidget {
  final Map<String, dynamic> selectedAnswers;
  const ResultScreen({super.key, required this.selectedAnswers});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool isLoading = true;

  List<Color> colors = [
    Colors.deepPurpleAccent,
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    Colors.indigo,
    Colors.teal,
    Colors.pink,
    Colors.cyan,
    Colors.deepOrange,
    Colors.deepPurple,
    Colors.black,
  ];
  List<double> blockAverages = [];
  double allBlockAverage = 0.0;
  List<String> sortedUniqueBlockIds = [];
  List<Color> blockColors = [];

  List columnDataBlockAverage = [];
  List columnDataFreeText = [];

  void setLoading(bool status) {
    setState(() {
      isLoading = status;
    });
  }

  void calculations(Map<String, dynamic> answers) {
    setLoading(true);
    blockAverages.clear();
    sortedUniqueBlockIds.clear();
    blockColors.clear();
    allBlockAverage = 0.0;
    columnDataBlockAverage.clear();
    columnDataFreeText.clear();
    try {
      Set<int> uniqueBlockIds = {};
      Map<int, List<double>> blockValues = {};

      answers.forEach((key, value) {
        int blockId = int.parse(value['blockId'].toString());
        double optionValue = double.parse(value['option_value'].toString());
        uniqueBlockIds.add(blockId);
        if (!blockValues.containsKey(blockId)) {
          blockValues[blockId] = [optionValue];
        } else {
          blockValues[blockId]!.add(optionValue);
        }
      });
      blockValues.forEach((blockId, values) {
        double sum = values.reduce((value, element) => value + element);
        double average = sum / values.length;
        average = double.parse(average.toStringAsFixed(2));
        blockAverages.add(average);
      });
      sortedUniqueBlockIds =
          uniqueBlockIds.toList().map((id) => id.toString()).toList();
      sortedUniqueBlockIds.sort((a, b) => int.parse(a).compareTo(int.parse(b)));
      blockAverages.sort((a, b) => a.compareTo(b));

      double allBlockSum = 0.0;
      for (var element in blockAverages) {
        allBlockSum += element;
      }
      allBlockAverage = double.parse(
          (allBlockSum / sortedUniqueBlockIds.length).toStringAsFixed(2));
      for (var i = 0; i < sortedUniqueBlockIds.length; i++) {
        blockColors.add(colors[i]);
        columnDataBlockAverage.add({
          "id": "Blocco ${sortedUniqueBlockIds[i]}",
          "average": blockAverages[i]
        });
      }
      columnDataBlockAverage
          .add({"id": "Media Globale", "average": allBlockAverage});

      answers.forEach((key, value) {
        if (value['optionId'] == null) {
          columnDataFreeText.add(
              {"id": value['questionName'], "average": value["option_value"]});
        }
      });
      if (kDebugMode) {
        print("Block IDs: $sortedUniqueBlockIds");
        print("Total Blocks: ${sortedUniqueBlockIds.length}");
        print("Average Option Values for Each Block:");
        for (var entry in blockAverages) {
          if (kDebugMode) {
            print("Block $entry");
          }
        }
      }
    } catch (e) {
      LogUtils.log("calculation()", e.toString());
    }
    setLoading(false);
  }

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    calculations(widget.selectedAnswers);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      appBar: AppBar(
        title: const Text("Result"),
        backgroundColor: AppColor.backgroundColor,
        centerTitle: true,
        foregroundColor: Colors.black,
      ),
      body: !isLoading
          ? SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      right: 10,
                      left: 10,
                      bottom: 20,
                    ),
                    child: TableWidget(
                        headerText: const [' S.no', "", "Blocco", "Resultati"],
                        columnData: columnDataBlockAverage),
                  ),
                  blockAverages.length == sortedUniqueBlockIds.length
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(top: 40, bottom: 40),
                          color: Colors.white30,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.8,
                            height: MediaQuery.of(context).size.width * 0.8,
                            child: SpiderChart(
                              data: blockAverages,
                              labels: sortedUniqueBlockIds,
                              decimalPrecision: 2,
                              colorSwatch: Colors.cyan,
                              colors: blockColors,
                            ),
                          ),
                        )
                      : const Text("Something went wrong!"),
                  blockAverages.length == sortedUniqueBlockIds.length
                      ? LineChartWidget(
                          allBlockAverage: allBlockAverage,
                          blockAverage: blockAverages,
                          sortedUniqueIds: sortedUniqueBlockIds,
                        )
                      : const Text("Something went wrong!"),
                  Padding(
                    padding: const EdgeInsets.only(
                        right: 10, left: 10, bottom: 20, top: 20),
                    child: TableWidget(
                        headerText: const [' S.no', "", "Question", "Result"],
                        columnData: columnDataFreeText),
                  ),
                ],
              ),
            )
          : Center(
              child: LoadingAnimationWidget.inkDrop(
                  color: AppColor.buttonColor, size: 50)),
    );
  }
}


/*
DChartLineN(
                            animationDuration: const Duration(seconds: 1),
                            animate: true,
                            allowSliding: true,
                            configRenderLine: ConfigRenderLine(
                              includePoints: true,
                            ),
                            groupList: [
                              NumericGroup(
                                id: '1',
                                color: Colors.blue,
                                data: blockAverages.map((e) {
                                  return NumericData(
                                      domain: int.parse(sortedUniqueBlockIds
                                          .elementAt(blockAverages.indexOf(e))),
                                      measure: e,
                                      color: Colors.red);
                                }).toList(),
                              ),
                              NumericGroup(
                                id: '2',
                                color: Colors.red,
                                chartType: ChartType.line,
                                data: sortedUniqueBlockIds.map((e) {
                                  return NumericData(
                                      domain: double.parse(e),
                                      measure: allBlockAverage,
                                      color: Colors.red);
                                }).toList(),
                              ),
                            ],
                          ),
                        )
*/