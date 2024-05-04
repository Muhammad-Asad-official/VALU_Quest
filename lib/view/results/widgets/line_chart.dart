import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LineChartWidget extends StatefulWidget {
  final List<double> blockAverage;
  final List<String> sortedUniqueIds;
  final double allBlockAverage;
  const LineChartWidget({
    super.key,
    required this.blockAverage,
    required this.sortedUniqueIds,
    required this.allBlockAverage,
  });

  @override
  State<StatefulWidget> createState() => LineChartWidgetState();
}

class LineChartWidgetState extends State<LineChartWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          // Row(
          //   crossAxisAlignment: CrossAxisAlignment.center,
          //   mainAxisSize: MainAxisSize.min,
          //   mainAxisAlignment: MainAxisAlignment.start,
          //   children: <Widget>[
          //     // Container(
          //     //     width: 14, height: 14, child: Image.asset(Images.pie_chart)),
          //     SizedBox(
          //       width: 5,
          //     ),
          //     Text(
          //       'Results',
          //     ),
          //     Spacer(),
          //     Row(
          //       crossAxisAlignment: CrossAxisAlignment.start,
          //       children: [
          //         Row(
          //           children: [
          //             Icon(Icons.circle,
          //                 size: 7, color: Theme.of(context).primaryColor),
          //             Text(
          //               'Income',
          //             ),
          //           ],
          //         ),
          //         SizedBox(
          //           width: 10,
          //         ),
          //         Row(
          //           children: [
          //             Icon(Icons.circle,
          //                 size: 7,
          //                 color: Theme.of(context)
          //                     .secondaryHeaderColor
          //                     .withOpacity(.3)),
          //             Text(
          //               'Expense',
          //             ),
          //           ],
          //         ),
          //       ],
          //     ),
          //   ],
          // ),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: Container(
              color: Colors.white30,
              padding: EdgeInsets.only(right: 20, bottom: 0, top: 20),
              child: LineChart(
                LineChartData(
                  lineTouchData: lineTouchData1,
                  gridData: gridData,
                  titlesData: titlesData1,
                  borderData: borderData,
                  lineBarsData: lineBarsData1,
                ),
                swapAnimationDuration: const Duration(seconds: 1),
                swapAnimationCurve: Curves.linear,
              ),
            ),
          ),
        ],
      ),
    );
  }

  LineTouchData get lineTouchData1 => LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: Colors.white,
        ),
      );

  FlTitlesData get titlesData1 => FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: bottomTitles,
        ),
        leftTitles: AxisTitles(
          sideTitles:
              SideTitles(showTitles: true, reservedSize: 40, interval: 0.5),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
      );

  List<LineChartBarData> get lineBarsData1 => [
        lineChartBarDataExpense,
        lineChartBarDataIncome,
      ];

  LineTouchData get lineTouchData2 => LineTouchData(
        enabled: true,
      );

  FlTitlesData get titlesData2 => FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: bottomTitles,
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      );

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff72719b),
      fontWeight: FontWeight.normal,
      fontSize: 10,
    );

    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Text(
        value.toInt().toString(),
        style: style,
      ),
    );
  }

  SideTitles get bottomTitles => SideTitles(
        showTitles: true,
        reservedSize: 50,
        interval: 1,
        getTitlesWidget: bottomTitleWidgets,
      );

  FlGridData get gridData => FlGridData(
        show: true,
        verticalInterval: 1,
        drawVerticalLine: false,
      );

  FlBorderData get borderData => FlBorderData(
        show: true,
        border: const Border(
          bottom: BorderSide(color: Color(0xff4e4965), width: 1),
          left: BorderSide(color: Colors.transparent),
          right: BorderSide(color: Colors.transparent),
          top: BorderSide(color: Colors.transparent),
        ),
      );

  LineChartBarData get lineChartBarDataExpense => LineChartBarData(
        isCurved: false,
        color: Colors.deepPurpleAccent,
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: FlDotData(show: true),
        belowBarData: BarAreaData(
          show: false,
          color: Color.fromARGB(255, 136, 0, 255),
        ),
        spots: widget.blockAverage.map((e) {
          return FlSpot(
              double.parse((widget.blockAverage.indexOf(e) + 1).toString()), e);
        }).toList(),
      );

  LineChartBarData get lineChartBarDataIncome => LineChartBarData(
        isCurved: false,
        color: Color.fromARGB(255, 255, 0, 0),
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: FlDotData(show: true),
        belowBarData: BarAreaData(
          show: false,
          color: Color.fromARGB(3, 136, 0, 255),
        ),
        spots: widget.sortedUniqueIds.map((e) {
          return FlSpot(double.parse(e), widget.allBlockAverage);
        }).toList(),
      );
}
