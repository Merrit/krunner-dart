/// A super simple and barebones example of a krunner plugin.
///
/// Place the `plasma-runner-simple_runner.desktop` file in
/// ~/.local/share/kservices5/krunner/dbusplugins/ and run the
/// example with `dart run /path/to/example/simple_runner.dart`
///
/// Kill KRunner by running `kquitapp5 krunner`.
/// Now by activating KRunner and entering `hello` you will see your result.

import 'package:krunner/krunner.dart';

Future<void> main() async {
  /// Create a runner instance.
  final runner = KRunnerPlugin(
    identifier: 'com.example.plugin_name',
    name: '/plugin_name',
    matchQuery: (String query) async {
      /// If the KRunner query matches exactly `hello` we return a match.
      if (query == 'hello') {
        return [
          QueryMatch(
            id: 'uniqueMatchId',
            title: 'This is presented to the user',
            icon: 'checkmark',
            rating: QueryMatchRating.exact,
            relevance: 1.0,
            properties: QueryMatchProperties(subtitle: 'Subtitle for match'),
          ),
        ];
      } else {
        return []; // Empty response (no matches).
      }
    },
    retrieveActions: () async => [
      SecondaryAction(
        id: 'uniqueActionId',
        text: 'hoverText',
        icon: 'addressbook-details',
      ),
    ],
    runAction: ({required String actionId, required String matchId}) async {
      if (actionId == 'uniqueActionId') {
        print('User clicked secondary action!');
      }
    },
  );

  /// Start the runner.
  await runner.init();
}
