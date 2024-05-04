import 'package:flutter/material.dart';
import 'package:valu_quest/Utils/app_colors.dart';

class TableWidget extends StatelessWidget {
  final List<String> headerText;
  final List columnData;

  const TableWidget({
    super.key,
    required this.headerText,
    required this.columnData,
  });

  final double tableRowHeight = 50;
  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths: const {
        0: FixedColumnWidth(50),
        1: FixedColumnWidth(0.5),
        2: FlexColumnWidth(5),
        3: FlexColumnWidth(2)
      },
      children: [
        TableRow(
          decoration: BoxDecoration(
              color: AppColor.buttonColor.withOpacity(0.4),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8))),
          children: headerText
              .map(
                (e) => SizedBox(
                  height: tableRowHeight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          " $e",
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )
              .toList(),
        ),
        ...columnData
            .asMap()
            .entries
            .map(
              (item) => TableRow(
                  decoration: BoxDecoration(
                    color: item.key % 2 == 1
                        ? AppColor.buttonColor.withOpacity(0.1)
                        : Colors.grey[200],
                    borderRadius: (item.key == columnData.length - 1)
                        ? const BorderRadius.vertical(
                            bottom: Radius.circular(8))
                        : null,
                  ),
                  children: [
                    SizedBox(
                      height: tableRowHeight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            (item.key + 1).toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: tableRowHeight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          VerticalDivider(
                            width: 0.5,
                            thickness: 0.5,
                            color: AppColor.buttonColor.withOpacity(0.8),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: tableRowHeight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(
                            width: 4,
                          ),
                          Flexible(
                            child: Text(
                              item.value['id'] ?? "",
                              overflow: TextOverflow.ellipsis,
                              maxLines: 3,
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 40,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            " ${item.value["average"].toString()}",
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]),
            )
            .toList(),
      ],
    );
  }
}
