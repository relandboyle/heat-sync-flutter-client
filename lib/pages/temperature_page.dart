import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:heat_sync/models/sensor_data_response.dart';
import 'package:logger/logger.dart';
import 'package:heat_sync/components/building_autocomplete.dart';
import 'package:heat_sync/components/date_picker.dart';
import 'package:heat_sync/components/unit_autocomplete.dart';
import 'package:intl/intl.dart';
import '../components/temperature_graph.dart';
import '../models/building_data.dart';
import '../models/temperature_entry.dart';
import '../models/unit_data.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

final logger = Logger();

class TemperaturePage extends StatefulWidget {
  const TemperaturePage({super.key});

  @override
  State<TemperaturePage> createState() => _TemperaturePageState();
}

class _TemperaturePageState extends State<TemperaturePage> {
  var selectedBuilding = BuildingData(fullAddress: '');
  var selectedUnit = UnitData(fullUnit: '');
  Iterable<TemperatureEntry> temperatureEntries = <TemperatureEntry>[];
  SensorDataResponse sensorDataResponse = SensorDataResponse();
  List<int> bottomTileSpacer = [];
  List<FlSpot> spots = [const FlSpot(0, 20)];
  List<FlSpot> outsideSpots = [const FlSpot(0, 20)];
  DateTime startDate = DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day - 7);
  DateTime endDate = DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day, 23, 59, 59);

  void selectBuilding(BuildingData building) {
    setState(() => selectedBuilding = building);
    logger.i('SELECTED BUILDING: ${selectedBuilding.fullAddress}');
  }

  void selectUnit(UnitData unit) {
    setState(() => selectedUnit = unit);
    logger.i('SELECTED UNIT: ${selectedUnit.fullUnit}');
  }

  void getStartDate(DateTime date) {
    setState(() => startDate = date);
    logger.i('START DATE: $startDate');
  }

  void getEndDate(DateTime date) {
    setState(() => endDate = DateTime(date.year, date.month, date.day, 23, 59, 59));
    logger.i('END DATE: $endDate');
  }

  void getDateRange(DateTime start, DateTime end) {
    setState(() {
      startDate = start;
      endDate = end;
    });
    // logger.i('DATE RANGE: $startDate - $endDate');
  }

  // TODO: move this to sensor_service.dart
  void getTemperatureData() async {
    // request sensor data from the server passing channelId, startTime, and endTime
    await getSensorData(selectedUnit.channelId, startDate.toIso8601String(), endDate.toIso8601String());
    // for (var entry in temperatureEntries) {
    //   logger.i('ENTRY: ${entry.temperature}');
    // }
    spots = temperatureEntries
        .map((entry) => FlSpot(
              entry.serverTime.toDouble(),
              double.parse((double.parse(entry.temperature) * (9 / 5) + 32).toStringAsFixed(2)),
            ))
        .toList();

    outsideSpots = temperatureEntries
        .map((entry) => FlSpot(
              entry.serverTime.toDouble(),
              double.parse((double.parse(entry.outsideTemperature) * (9 / 5) + 32).toStringAsFixed(2)),
            ))
        .toList();

    // logger.i('SPOTS: $spots');
    // logger.i('SPOTS: ${spots.first.x.runtimeType}, ${spots.first.y.runtimeType}');
    // logger.i('OUTSIDE SPOTS: $outsideSpots');

    setState(() {
      spots = spots;
      outsideSpots = outsideSpots;
    });

    // logger.i('SPOTS: $spots');
    double myInt = 12.05;
    logger.i('${myInt.toDouble()}, ${myInt.runtimeType}, ${myInt.toDouble().runtimeType}');
    logger.i('SPOTS: ${spots.first.x.toDouble().runtimeType}, ${spots.first.y.runtimeType}');
    // logger.i('OUTSIDE SPOTS: $outsideSpots');
  }

  // TODO: move this to sensor_service.dart
  Future<void> getSensorData(String? channelId, String dateRangeStart, String dateRangeEnd) async {
    // logger.i('QUERY PARAMS: $channelId, $dateRangeStart, $dateRangeEnd');

    final response = await http
        .post(
            // Uri.parse("http://localhost:8089/api/v1/sensor/filteredSensorData"),
            Uri.parse('https://heat-sync-534f0413abe0.herokuapp.com/api/v1/sensor/filteredSensorData'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, String?>{
              'channelId': channelId,
              'dateRangeStart': dateRangeStart,
              'dateRangeEnd': dateRangeEnd,
            }))
        .catchError((onError) {
      logger.e('Error fetching temperature data: $onError');
      return onError;
    });

    SensorDataResponse res = SensorDataResponse.fromJson(json.decode(response.body));
    logger.i("RESPONSE: ${res.sensorData[0].flutterSpot['value0'].runtimeType}, ${res.sensorData[0].flutterSpot['value1'].runtimeType}");

    // setState(() => temperatureEntries = res.sensorData.map((entry) => TemperatureEntry.fromJson(entry)));
    setState(() => temperatureEntries = res.sensorData);
    setState(() => bottomTileSpacer = res.bottomTileSpacer);
    // logger.i('SPACER: ${res.bottomTileSpacer}');
    // logger.i('SENSOR DATA: ${res.sensorData}');
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 800,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Card(
                    color: Theme.of(context).colorScheme.primary,
                    elevation: 10,
                    child: TemperatureGraph(
                      spots: spots,
                      outsideSpots: outsideSpots,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: SizedBox(
                    width: 350,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Text('Date Range: ${DateFormat('MM/dd/yyyy').format(startDate)} - ${DateFormat('MM/dd/yyyy').format(endDate)}'),
                            const SizedBox(width: 10),
                            DatePicker(startDate: startDate, endDate: endDate, dateGetter: getDateRange),
                          ],
                        ),
                        const SizedBox(height: 40),
                        BuildingAutocomplete(
                          selectBuilding: selectBuilding,
                        ),
                        const SizedBox(height: 25),
                        UnitAutocomplete(
                          selectUnit: selectUnit,
                          selectedBuildingId: selectedBuilding.id,
                        ),
                        const SizedBox(height: 25),
                        ElevatedButton(
                          onPressed: selectedUnit.channelId.isNotEmpty ? getTemperatureData : null,
                          style: selectedUnit.channelId.isNotEmpty
                              ? ButtonStyle(
                                  shape: MaterialStateProperty.all(
                                    const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(5),
                                      ),
                                    ),
                                  ),
                                  elevation: MaterialStateProperty.all(5),
                                  foregroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.onSecondaryContainer),
                                  backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primary),
                                  padding: MaterialStateProperty.all(
                                    const EdgeInsets.all(15),
                                  ),
                                )
                              : ButtonStyle(
                                  shape: MaterialStateProperty.all(
                                    const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(5),
                                      ),
                                    ),
                                  ),
                                  foregroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primaryContainer),
                                  backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.inversePrimary),
                                  padding: MaterialStateProperty.all(
                                    const EdgeInsets.all(15),
                                  ),
                                ),
                          child: const Text('Get Temperature Data'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
