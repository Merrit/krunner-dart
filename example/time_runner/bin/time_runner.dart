import 'dart:io';

import 'package:desktop_notifications/desktop_notifications.dart';
import 'package:krunner/krunner.dart';

Future<void> main(List<String> arguments) async {
  // Check if already running.
  await checkIfAlreadyRunning();

  // Instantiate the plugin, provider identifiers and callback functions.
  final runner = KRunnerPlugin(
    identifier: 'com.example.time_runner',
    name: '/time_runner',
    matchQuery: matchQuery,
    retrieveActions: retrieveActions,
    runAction: runAction,
  );

  // Start the plugin and enter the event loop.
  await runner.init();
}

/// Check if an instance of this plugin is already running.
///
/// If we don't check KRunner will just launch a new instance every time.
Future<void> checkIfAlreadyRunning() async {
  final result = await Process.run('pidof', ['time_runner']);
  final hasError = result.stderr != '';
  if (hasError) {
    print('Issue checking for existing process: ${result.stderr}');
    return;
  }
  final output = result.stdout as String;
  final runningInstanceCount = output.trim().split(' ').length;
  if (runningInstanceCount != 1) {
    print('An instance of vscode_runner appears to already be running. '
        'Aborting run of new instance.');
    exit(0);
  }
}

Future<List<QueryMatch>> matchQuery(String query) async {
  // Only match if the query is exactly "time".
  if (query != 'time') return const [];
  final matches = <QueryMatch>[];
  final time = DateTime.now();
  final parsedTime = '${time.hour}:${time.minute}';
  // Return one match.
  matches.add(QueryMatch(
    icon: 'clock',
    id: parsedTime,
    rating: QueryMatchRating.exact,
    relevance: 1.0,
    title: parsedTime,
    properties: QueryMatchProperties(subtitle: 'Hello from Dart!'),
  ));
  return matches;
}

Future<List<SecondaryAction>> retrieveActions() async {
  return [
    SecondaryAction(id: 'notify', text: 'Notify', icon: 'notifications'),
  ];
}

Future<void> runAction({
  required String matchId,
  String? actionId,
}) async {
  if (actionId == 'notify') {
    // Secondary action: Notification with local timezone.
    final timezone = DateTime.now().timeZoneName;
    await sendNotification('Current timezone is: $timezone');
  } else {
    // Primary action: Notification with current time.
    await sendNotification('Current time is: $matchId');
  }
}

/// Send a desktop notification containing [value].
Future<void> sendNotification(String value) async {
  final client = NotificationsClient();
  await client.notify(value);
  await client.close();
}
