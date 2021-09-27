import 'dart:async';
import 'dart:convert';
import 'package:covidfen/models/corona_case.dart';
import 'package:covidfen/models/corona_case_country.dart';
import 'package:covidfen/models/corona_case_total_count.dart';
import 'package:flutter/services.dart';
import 'package:covidfen/models/corona_case.dart';
import 'package:covidfen/models/corona_case_country.dart';
import 'package:covidfen/models/corona_case_total_count.dart';
import 'package:http/http.dart' as http;
import '../models/corona_case_response.dart';
import '../models/corona_case_total_count_response.dart';

class TimeoutException implements Exception {
  final String message = 'Serveur timeout';
  TimeoutException();
  @override
  String toString() => message;
}

class ServerException implements Exception {
  final String message = 'Serveur Saturer'; //Busy
  ServerException();
  @override
  String toString() => message;
}

class ServerErrorException implements Exception {
  String message;
  ServerErrorException(this.message);

  @override
  String toString() => message;
}

const kTimeoutDuration = Duration(seconds: 25);

class CoronaService {
  CoronaService._privateConstructor();
  static final CoronaService instance = CoronaService._privateConstructor();

  static var baseURL =
      'https://services1.arcgis.com/0MSEUqKaxRlEPj5g/arcgis/rest/services/ncov_cases/FeatureServer/1/query';

  static String get caseURL {
    return '$baseURL?f=json&where=(Confirmed%3E%200)%20OR%20(Deaths%3E0)%20OR%20(Recovered%3E0)&returnGeometry=false&spatialRef=esriSpatialRelIntersects&outFields=*&orderByFields=Country_Region%20asc,Province_State%20asc&resultOffset=0&resultRecordCount=250&cacheHint=false';
  }

  static String get totalConfirmedCaseURL {
    return '$baseURL?f=json&where=Confirmed%20%3E%200&returnGeometry=false&spatialRel=esriSpatialRelIntersects&outFields=*&outStatistics=%5B%7B%22statisticType%22%3A%22sum%22,%22onStatisticField%22%3A%22Confirmed%22,%22outStatisticFieldName%22%3A%22value%22%7D%5D&cacheHint=false';
  }

  static String get totalRecoveredCaseURL {
    return '$baseURL?f=json&where=Confirmed%20%3E%200&returnGeometry=false&spatialRel=esriSpatialRelIntersects&outFields=*&outStatistics=%5B%7B%22statisticType%22%3A%22sum%22,%22onStatisticField%22%3A%22Recovered%22,%22outStatisticFieldName%22%3A%22value%22%7D%5D&cacheHint=false';
  }

  static String get totalDeathsCaseURL {
    return '$baseURL?f=json&where=Confirmed%20%3E%200&returnGeometry=false&spatialRel=esriSpatialRelIntersects&outFields=*&outStatistics=%5B%7B%22statisticType%22:%22sum%22,%22onStatisticField%22:%22Deaths%22,%22outStatisticFieldName%22:%22value%22%7D%5D&cacheHint=false';
  }

  Future<CoronaTotalCount> fetchAllTotalCount() async {
    try {
      final confirmedJson = await _fetchJSON(totalConfirmedCaseURL);
      final deathsJson = await _fetchJSON(totalDeathsCaseURL);
      final recoveredJson = await _fetchJSON(totalRecoveredCaseURL);

      final confirmed = CoronaCaseTotalCountResponse.fromJson(confirmedJson)
          .features!
          .first!
          .attributes!
          .value;
      final deaths = CoronaCaseTotalCountResponse.fromJson(deathsJson)
          .features!
          .first!
          .attributes!
          .value;
      final recovered = CoronaCaseTotalCountResponse.fromJson(recoveredJson)
          .features!
          .first!
          .attributes!
          .value;

      if (confirmed == null || deaths == null || recovered == null) {
        throw ServerException();
      }

      return CoronaTotalCount(
          confirmed: confirmed, deaths: deaths, recovered: recovered);
    } on PlatformException catch (_) {
      throw ServerException();
    } on Exception catch (e) {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<CoronaCaseCountry>> fetchCases() async {
    try {
      final url = caseURL;
      final json = await _fetchJSON(url);
      final response = CoronaCaseResponse.fromJson(json);
      final coronaCases = response.features!.map((e) => e!.attributes).toList();


      Map<String, List<CoronaCase>> dict = {};
      coronaCases.forEach((element) {
        if (dict[element!.country] != null) {
          var countryCases = dict[element.country];
          countryCases!.add(element);
          dict[element.country] = countryCases;
        } else {
          var countryCases = <CoronaCase>[];
          countryCases.add(element);
          dict[element.country] = countryCases;
        }
      });

      var coronaCountryCases = <CoronaCaseCountry>[];
      dict.forEach((key, value) {
        final confirmed = value.fold(
            0, (previousValue, element) => int.tryParse(previousValue.toString())! + element.confirmed);
        final deaths = value.fold(
            0, (previousValue, element) => int.tryParse(previousValue.toString())! + element.deaths);
        final recovered = value.fold(
            0, (previousValue, element) => int.tryParse(previousValue.toString())! + element.recovered); //previousValue
        coronaCountryCases.add(CoronaCaseCountry(
            country: key,
            totalConfirmedCount: confirmed,
            totalDeathsCount: deaths,
            totalRecoveredCount: recovered,
            cases: value));
      });

      coronaCountryCases
          .sort((a, b) => b.totalRecoveredCount - a.totalRecoveredCount);
      coronaCountryCases
          .sort((a, b) => b.totalDeathsCount - a.totalDeathsCount);
      coronaCountryCases
          .sort((a, b) => b.totalConfirmedCount - a.totalConfirmedCount);

      return coronaCountryCases;
    } on PlatformException catch (_) {
      throw ServerException();
    } on Exception catch (e) {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> _fetchJSON(String url) async {
    final response =
        await http.get(Uri.parse(url)).timeout(const Duration(seconds: 25), onTimeout: () {
      throw Error();
    });

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw ServerErrorException("Erreur de reception des donnees");
    }
  }
}
