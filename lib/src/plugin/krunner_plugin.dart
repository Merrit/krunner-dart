import 'dart:io';

import 'package:dbus/dbus.dart';

import 'src/secondary_action.dart';
import 'src/dbus_interface.dart';
import 'src/query_match.dart';

export 'src/query_match.dart';
export 'src/secondary_action.dart';

/// A Dart interface for creating and running a KRunner plugin.
class KRunnerPlugin {
  /// A unique reverse-domain identifier for this runner.
  ///
  /// Examples: `com.google.calendar`, `org.kde.krita`, etc.
  final String identifier;

  /// A name for this runner.
  ///
  /// Must start with a `/` and may be composed of
  /// the following characters `[A-Z][a-z][0-9]_`.
  ///
  /// This is the label for this item that lives under the [identifier].
  ///
  /// If your [identifier] was `org.kde.vscode` your [name] might be
  /// `/krunner`, so that the krita namespace could contain multiple grouped
  /// service names like: `/krunner`, `/workspaces`, `/client`, etc.
  final String name;

  /// KRunner sends a query as a String when the user is typing,
  /// asking for a return of any possible matches.
  final Future<List<QueryMatch>> Function(String) matchQuery;

  /// Return a list of secondary actions this runner can perform.
  ///
  /// If this function returns any [SecondaryAction]s the runner results will have
  /// an icon(s) to the right to allow the user to trigger secondary
  /// actions for a match.
  ///
  /// Example: The runner returns a list files. The primary action will call
  /// [runAction] with no `actionId`, and perhaps the runner will launch
  /// that file. The runner had also returned an [SecondaryAction] from *this* function,
  /// and when [runAction] is called with that [SecondaryAction]'s id (by the user
  /// clicking the icon in the match or pressing `Shift+Enter`) the callback
  /// can know to run the secondary action on that match, such as perhaps
  /// opening that file's containing folder instead.
  final Future<List<SecondaryAction>> Function() retrieveActions;

  /// KRunner has requested to run an action on a match.
  ///
  /// [matchId] is the ID that was returned with a [QueryMatch].
  ///
  /// [actionId] (if present) is the [SecondaryAction.id] associated with
  /// a specific action (callback).
  ///
  /// If the user selects the default action (by for example pressing enter)
  /// only the [matchId] will be passed and [actionId] will be null.
  ///
  /// If any actions returned from [retrieveActions]
  final Future<void> Function({
    required String matchId,
    required String actionId,
  }) runAction;

  const KRunnerPlugin({
    required this.identifier,
    required this.name,
    required this.matchQuery,
    required this.retrieveActions,
    required this.runAction,
  });

  /// Start the runner and listen for queries.
  Future<void> init() async {
    final client = DBusClient.session();

    DBusRequestNameReply result;

    try {
      result = await client.requestName(
        identifier,
        flags: {
          DBusRequestNameFlag.allowReplacement,
          DBusRequestNameFlag.doNotQueue,
          DBusRequestNameFlag.replaceExisting,
        },
      );
    } catch (e) {
      print('Unable to get DBus name for this runner: $e');
      exit(1);
    }

    if (result != DBusRequestNameReply.primaryOwner) {
      print('Unable to get DBus name for this runner: $result');
      exit(1);
    } else {
      print('Got DBus ownership for this runner, proceeding to activate.');
    }

    await client.registerObject(
      KRunnerDBusInterface(
        name,
        matchQueryCallback: matchQuery,
        retrieveActionsCallback: retrieveActions,
        runActionCallback: runAction,
      ),
    );
  }
}
