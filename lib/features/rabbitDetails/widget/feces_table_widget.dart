import 'package:flutter/material.dart';

class FecesTable extends StatelessWidget {
  final Map<String, int> fecesCount;
  final int totalFeces;

  const FecesTable({Key? key, required this.fecesCount, required this.totalFeces}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 5,
                spreadRadius: 2,
              ),
            ],
          ),
          child: DataTable(
            columns: const [
              DataColumn(
                label: Text(
                  "ประเภทอุจจาระ", // "Feces Type"
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  "จำนวนที่พบ", // "Count"
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
            rows: fecesCount.entries
                .map(
                  (entry) => DataRow(cells: [
                    DataCell(Text(entry.key)),
                    DataCell(Text(entry.value.toString())),
                  ]),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Total: $totalFeces",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
