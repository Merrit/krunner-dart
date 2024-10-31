# KRunner Dart

*A user-friendly API for KDE's KRunner application.*

With KRunner Dart you can create plugins for KDE's KRunner application in an
easy and sane way. The API is designed to be type safe, null safe, and easy to
use.

Unlike the C++ or Python APIs, KRunner Dart provides code completion and 
documentation in tooltips for a better development experience.


- [KRunner Dart](#krunner-dart)
  - [Features](#features)
    - [Documentation in tooltips](#documentation-in-tooltips)
    - [Code completion](#code-completion)
  - [Usage](#usage)
    - [Creating plugins](#creating-plugins)
  - [Documentation](#documentation)
  - [Installing](#installing)
  - [Support](#support)
  - [License](#license)
  - [Contributing](#contributing)


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

Refer to the [example](https://github.com/Merrit/krunner-dart/tree/main/example)
directory for a complete example, including instructions for debugging and
installing plugins.

For a real-world example of a plugin made with this API see [VSCode Runner](https://github.com/Merrit/vscode-runner).


## Documentation

In addition to the documentation available in IDE code completion and hover
popups, the [API Documentation](https://pub.dev/documentation/krunner/latest/krunner/krunner-library.html)
is available online.


## Installing

Add to dependencies:

```
dart pub add krunner
```

## Support

If you encounter any issues or have any questions, please file an issue on the 
[GitHub repository](https://github.com/Merrit/krunner-dart/issues?q=sort%3Aupdated-desc+is%3Aissue+is%3Aopen).


## License

You are free to copy, modify, and distribute KRunner Dart with attribution under 
the terms of the BSD 3-Clause License. See the
[LICENSE](https://github.com/Merrit/krunner-dart/blob/fa1c521642672d378133c74412a663c7b51d994b/LICENSE) file for details.

## Contributing

Contributions are welcome! Feel free to open an issue or a pull request on the
[GitHub repository](https://github.com/Merrit/krunner-dart).
