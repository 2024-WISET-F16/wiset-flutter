import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AnalyzePage extends StatefulWidget {
  const AnalyzePage({super.key});

  @override
  _AnalyzePageState createState() => _AnalyzePageState();
}

class _AnalyzePageState extends State<AnalyzePage> {
  final List<double> data = [
    10.0, 20.5, 30.2, 40.3, 35.0, 45.7,
    50.3, 48.6, 60.2, 55.1, 65.3, 70.5
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Analyze Page"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LineChart(
          LineChartData(
            backgroundColor: Colors.white,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              getDrawingHorizontalLine: (value) => FlLine(
                color: Colors.grey[300]!,
                strokeWidth: 1,
              ),
              getDrawingVerticalLine: (value) => FlLine(
                color: Colors.grey[300]!,
                strokeWidth: 1,
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 32,
                  getTitlesWidget: (value, meta) {
                    switch (value.toInt()) {
                      case 0:
                        return Text('6 AM');
                      case 1:
                        return Text('7 AM');
                      case 2:
                        return Text('8 AM');
                      case 3:
                        return Text('9 AM');
                      case 4:
                        return Text('10 AM');
                      case 5:
                        return Text('11 AM');
                      case 6:
                        return Text('12 PM');
                      case 7:
                        return Text('1 PM');
                      case 8:
                        return Text('2 PM');
                      case 9:
                        return Text('3 PM');
                      case 10:
                        return Text('4 PM');
                      case 11:
                        return Text('5 PM');
                      default:
                        return Text('');
                    }
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 10, // Y축 간격
                  getTitlesWidget: (value, meta) {
                    return Text(value.toString());
                  },
                ),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(
                color: Colors.blueAccent,
                width: 2,
              ),
            ),
            minX: 0,
            maxX: 11, // 12개의 데이터 포인트
            minY: 0,
            maxY: 80, // y축 최대값은 80으로 설정
            lineBarsData: [
              LineChartBarData(
                spots: data
                    .asMap()
                    .entries
                    .map((e) => FlSpot(e.key.toDouble(), e.value))
                    .toList(),
                isCurved: true,
                color: Colors.blue,
                barWidth: 3,
                belowBarData: BarAreaData(
                  show: true,
                  color: Colors.blue.withOpacity(0.2),
                ),
                dotData: FlDotData(
                  show: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
