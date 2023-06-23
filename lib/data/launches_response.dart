import 'dart:convert';
import 'package:http/http.dart' as http;

import '../view models/homeViewModels/launchViewModel.dart';

class LaunchService {

  static Future<List<UpcomingLaunch>> fetchUpcomingLaunches() async {
    final response = await http.get(Uri.parse('https://api.spacexdata.com/v4/launches/upcoming'));
    if (response.statusCode == 200) {
      final launchesJson = json.decode(response.body) as List<dynamic>;
      final futures = <Future>[];

      for (final launchJson in launchesJson) {
        final rocketId = launchJson['rocket'];
        final launchPadId = launchJson['launchpad'];
        final future = ExtractRnLPName().extractRocketAndLaunchPadNames(rocketId, launchPadId)
            .then((rnlpName) {
          launchJson['rocket'] = rnlpName[0];
          launchJson['launchpad'] = rnlpName[1];
        });
        futures.add(future);
      }

      await Future.wait(futures);

      final launches = launchesJson.map((json) => UpcomingLaunch.fromJson(json)).toList();
      return launches;
    } else {
      throw Exception('Failed to fetch upcoming launches.');
    }
  }

  static Future<List<PastLaunch>> fetchPastLaunches() async {
    final response = await http.get(Uri.parse('https://api.spacexdata.com/v4/launches/past'));
    if (response.statusCode == 200) {
      final launchesJson = json.decode(response.body) as List<dynamic>;
      final futures = <Future>[];

      for (final launchJson in launchesJson) {
        final rocketId = launchJson['rocket'];
        final launchPadId = launchJson['launchpad'];
        final future = ExtractRnLPName().extractRocketAndLaunchPadNames(rocketId, launchPadId)
            .then((rnlpName) {
          launchJson['rocket'] = rnlpName[0];
          launchJson['launchpad'] = rnlpName[1];
        });
        futures.add(future);
      }

      await Future.wait(futures);

      final launches = launchesJson.map((json) => PastLaunch.fromJson(json)).toList();
      return launches;
    } else {
      throw Exception('Failed to fetch past launches.');
    }
  }

  static Future<List<dynamic>> fetchNextLaunch() async {
    final response = await http.get(Uri.parse('https://api.spacexdata.com/v4/launches/next'));
    if (response.statusCode == 200) {
      final launches = json.decode(response.body);
      return launches;
    } else {
      throw Exception('Failed to fetch next launch.');
    }
  }

  static Future<List<dynamic>> fetchLatestLaunch() async {
    final response = await http.get(Uri.parse('https://api.spacexdata.com/v4/launches/latest'));
    if (response.statusCode == 200) {
      final launches = json.decode(response.body);
      return launches;
    } else {
      throw Exception('Failed to fetch latest launch.');
    }
  }
}
