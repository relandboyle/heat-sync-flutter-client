import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:intl/intl.dart';

final logger = Logger();

// ignore: must_be_immutable
class TemperatureGraph extends StatefulWidget {
  TemperatureGraph(
      {super.key, required this.insideSpots, required this.outsideSpots, required this.bottomTitleSpacer, required this.bottomTitleInterval});

  List<FlSpot> insideSpots = [const FlSpot(0.0, 0.0)];
  List<FlSpot> outsideSpots = [const FlSpot(0.0, 0.0)];
  List<int> bottomTitleSpacer = [];
  double bottomTitleInterval;
  Set<String> dateLabels = {};

  @override
  State<TemperatureGraph> createState() => _TemperatureGraphState();
}

class _TemperatureGraphState extends State<TemperatureGraph> {
  List<Color> insideGradient = [
    const Color.fromRGBO(180, 0, 219, 86),
    const Color.fromRGBO(0, 103, 219, 86),
  ];
  List<Color> outsideGradient = [
    const Color.fromRGBO(219, 33, 0, 86),
    const Color.fromRGBO(219, 110, 0, 86),
  ];

  String getFormattedDate(double dateMillis) {
    String formattedDate = DateFormat('EEE, MMM d').format(DateTime.fromMillisecondsSinceEpoch(dateMillis.toInt()));
    // logger.i('FORMATTED DATE: $formattedDate');
    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 1.70,
          child: Padding(
            padding: const EdgeInsets.only(
              right: 18,
              left: 12,
              top: 24,
              bottom: 12,
            ),
            child: LineChart(
              chartData(),
              duration: const Duration(milliseconds: 800),
              chartRendererKey: const Key('linechart'),
            ),
          ),
        ),
      ],
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    if (widget.bottomTitleSpacer.isEmpty) {
      return Container();
    }
    TextStyle style = TextStyle(
      color: Theme.of(context).colorScheme.onPrimary,
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );
    String date;
    Widget text;
    date = getFormattedDate(value);
    text = Transform.translate(
      offset: const Offset(-15.0, 22.0),
      child: Transform.rotate(
        angle: -pi / 5,
        child: Text(date, style: style),
      ),
    );
    return text;
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    if (widget.bottomTitleSpacer.isEmpty) {
      return Container();
    }
    TextStyle style = TextStyle(
      color: Theme.of(context).colorScheme.onPrimary,
      fontWeight: FontWeight.bold,
      fontSize: 15,
    );
    String text;
    switch (value.toInt()) {
      case 0:
        text = '0°F';
        break;
      case 20:
        text = '20°F';
        break;
      case 40:
        text = '40°F';
        break;
      case 60:
        text = '60°F';
        break;
      case 80:
        text = '80°F';
        break;
      case 100:
        text = '100°F';
        break;
      default:
        return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.left);
  }

  LineChartData chartData() {
    return LineChartData(
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: Theme.of(context).colorScheme.primaryContainer,
          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
            // map is returning x and y for both touchedBarSpots
            // consider a loop and return x/y for one, y-only for the other
            return touchedBarSpots.map((barSpot) {
              final flSpot = barSpot;
              if (flSpot.x == widget.insideSpots.first.x ||
                  flSpot.x == widget.outsideSpots.first.x ||
                  flSpot.x == widget.insideSpots.last.x ||
                  flSpot.x == widget.outsideSpots.last.x) {
                return null;
              }
              String date = getFormattedDate(flSpot.x);
              return LineTooltipItem(
                '${flSpot.y}°F\n$date',
                TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              );
            }).toList();
          },
        ),
        handleBuiltInTouches: true,
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 5,
        verticalInterval: widget.bottomTitleInterval,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Theme.of(context).colorScheme.secondary,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: Theme.of(context).colorScheme.secondary,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 50,
            interval: widget.bottomTitleInterval,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 42,
            interval: 20,
            getTitlesWidget: leftTitleWidgets,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Theme.of(context).colorScheme.secondary),
      ),
      minX: widget.insideSpots.first.x,
      maxX: widget.insideSpots.last.x,
      minY: -10,
      maxY: 110,
      lineBarsData: [
        LineChartBarData(
          spots: widget.insideSpots.isNotEmpty ? widget.insideSpots : [const FlSpot(0.0, 0.0)],
          isCurved: true,
          gradient: LinearGradient(
            colors: insideGradient,
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: const Alignment(-1.0, 0.0),
              end: const Alignment(1.0, 0.0),
              colors: insideGradient.map((color) => color.withOpacity(0.3)).toList(),
            ),
          ),
        ),
        LineChartBarData(
          // curveSmoothness: 1.5,
          spots: widget.outsideSpots.isNotEmpty ? widget.outsideSpots : [const FlSpot(0.0, 0.0)],
          isCurved: true,
          gradient: LinearGradient(
            colors: outsideGradient,
          ),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: const Alignment(-1.0, 0.0),
              end: const Alignment(1.0, 0.0),
              colors: outsideGradient.map((color) => color.withOpacity(0.2)).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
