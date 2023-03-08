import 'package:dbus/dbus.dart';

import 'secondary_action.dart';
import 'query_match.dart';

/// Interface to simplify communication with KRunner via DBus while
/// ensuring type safety and checking requirements.
///
/// Arguments:
///
/// [path] is a String for the top-level name of the DBus object.
/// Example: `com.mysite.project_name`.
class KRunnerDBusInterface extends DBusObject {
  final Future<List<QueryMatch>> Function(String) matchQueryCallback;
  final Future<List<SecondaryAction>> Function() retrieveActionsCallback;
  final Future<void> Function({
    required String matchId,
    required String actionId,
  }) runActionCallback;

  KRunnerDBusInterface(
    String path, {
    required this.matchQueryCallback,
    required this.retrieveActionsCallback,
    required this.runActionCallback,
  }) : super(DBusObjectPath(path));

  // Method signatures primarily sourced from:
  // https://invent.kde.org/frameworks/krunner/-/blob/master/src/data/org.kde.krunner1.xml

  /// Incoming request from KRunner to check if this runner
  /// has any match for the query.
  ///
  /// Accepts a String argument `query`.
  ///
  /// KRunner expects a return of `a(sssida{sv})`, which translates to:
  /// `Array(Struct{String, String, String, int, double, Dict{String: Variant(String)}})`
  ///
  /// This interface will convert to/from this format to [QueryMatch].
  final _matchIntrospectMethod = DBusIntrospectMethod(
    'Match',
    args: [
      DBusIntrospectArgument(
        DBusSignature('s'),
        DBusArgumentDirection.in_,
        name: 'query',
      ),
      DBusIntrospectArgument(
        DBusSignature('a(sssida{sv})'),
        DBusArgumentDirection.out,
        annotations: [
          DBusIntrospectAnnotation(
            'org.qtproject.QtDBus.QtTypeName.Out0',
            'RemoteMatches',
          ),
        ],
      ),
    ],
  );

  /// Returns the list of actions supported by the runner.
  ///
  /// Each item in the return value is a `Struct` of strings that
  /// correspond to `{ID, Text, IconName}`.
  final _actionsIntrospectMethod = DBusIntrospectMethod(
    'Actions',
    args: [
      DBusIntrospectArgument(
        DBusSignature('a(sss)'),
        DBusArgumentDirection.out,
        name: 'matches',
        annotations: [
          DBusIntrospectAnnotation(
            'org.qtproject.QtDBus.QtTypeName.Out0',
            'RemoteActions',
          ),
        ],
      ),
    ],
  );

  /// Executes a callback.
  ///
  /// Takes two `String` arguments:
  ///
  /// `matchId` is the unique ID returned from the `Match` method.
  ///
  /// `actionId` is the ID of a secondary action to run. For the "default"
  /// action this will be empty.
  final _runIntrospectMethod = DBusIntrospectMethod(
    'Run',
    args: [
      DBusIntrospectArgument(
        DBusSignature('s'),
        DBusArgumentDirection.in_,
        name: 'matchId',
      ),
      DBusIntrospectArgument(
        DBusSignature('a(sssida{sv})'),
        DBusArgumentDirection.out,
        annotations: [
          DBusIntrospectAnnotation(
            'org.qtproject.QtDBus.QtTypeName.Out0',
            'RemoteMatches',
          ),
        ],
      ),
    ],
  );

  @override
  List<DBusIntrospectInterface> introspect() {
    return [
      DBusIntrospectInterface(
        'org.kde.krunner1',
        methods: [
          _matchIntrospectMethod,
          _actionsIntrospectMethod,
          _runIntrospectMethod,
        ],
      )
    ];
  }

  @override
  Future<DBusMethodResponse> handleMethodCall(DBusMethodCall methodCall) async {
    switch (methodCall.name) {
      case 'Match':
        return await _getQueryMatches(methodCall.values);
      case 'Actions':
        return await _getActions();
      case 'Run':
        return await _runAction(methodCall.values);
      default:
        return DBusMethodErrorResponse.unknownMethod();
    }
  }

  /// Gather the matches from the runner and return to KRunner via DBus.
  Future<DBusMethodSuccessResponse> _getQueryMatches(
    List<DBusValue> args,
  ) async {
    if (args.isEmpty) return DBusMethodSuccessResponse();
    final query = args.first.toNative() as String;
    final matches = await matchQueryCallback(query);
    final List<DBusValue> convertedMatches;

    convertedMatches = matches.map((QueryMatch match) {
      return DBusStruct(
        [
          DBusString(match.id),
          DBusString(match.title),
          DBusString(match.icon),
          DBusInt32(match.rating.value),
          DBusDouble(match.relevance),
          _propertiesToDBusDict(match.properties),
        ],
      );
    }).toList();

    return DBusMethodSuccessResponse(
      <DBusValue>[
        DBusArray(
          DBusSignature('(sssida{sv})'),
          convertedMatches,
        ),
      ],
    );
  }

  /// Convert a [QueryMatchProperties] object to the DBus dict representation.
  DBusDict _propertiesToDBusDict(QueryMatchProperties? properties) {
    final emptyDict = DBusDict.stringVariant({});
    if (properties == null) return emptyDict;
    final children = <String, DBusValue>{};

    if (properties.actions != null) {
      children['actions'] = DBusArray.string(properties.actions!);
    }

    if (properties.category != null) {
      children['category'] = DBusString(properties.category!);
    }

    if (properties.mimetypes != null) {
      children['urls'] = DBusArray.string(properties.mimetypes!);
    }

    if (properties.subtitle != null) {
      children['subtext'] = DBusString(properties.subtitle!);
    }

    return DBusDict.stringVariant(children);
  }

  /// Gather the available secondary actions from the runner and
  /// return to KRunner via DBus.
  Future<DBusMethodSuccessResponse> _getActions() async {
    final actions = await retrieveActionsCallback();
    final convertedActions = actions.map((action) {
      return DBusStruct([
        DBusString(action.id),
        DBusString(action.text),
        DBusString(action.icon),
      ]);
    }).toList();
    return DBusMethodSuccessResponse(
      <DBusValue>[
        DBusArray(
          DBusSignature('(sss)'),
          convertedActions,
        ),
      ],
    );
  }

  /// Pass the message from KRunner for this runner to run an action.
  Future<DBusMethodSuccessResponse> _runAction(List<DBusValue> args) async {
    if (args.isEmpty) return DBusMethodSuccessResponse();
    await runActionCallback(
      matchId: args[0].toString(),
      actionId: args[1].toString(),
    );
    return DBusMethodSuccessResponse();
  }
}
