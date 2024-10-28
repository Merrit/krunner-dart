<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->

A user-friendly API for KDE's KRunner application.


## Features

- Type safe
- Null safe
- Named parameters
- [API Documentation](https://pub.dev/documentation/krunner/latest/krunner/krunner-library.html)

### Documentation in tooltips

![Documentation in tooltips](https://raw.githubusercontent.com/Merrit/krunner-dart/refs/heads/main/assets/videos/promo/intellisense.gif)

### Code completion

![Code completion](https://raw.githubusercontent.com/Merrit/krunner-dart/refs/heads/main/assets/videos/promo/code_completion.gif)

## Usage

### Creating plugins

```dart
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
```

Refer to the `example` directory for a complete example, including instructions
for debugging and installing plugins.

For a real-world example of a plugin made with this API see [VSCode Runner](https://github.com/Merrit/vscode-runner).


## Additional Information

[API Documentation](https://pub.dev/documentation/krunner/latest/krunner/krunner-library.html)
