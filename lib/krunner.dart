/// A user-friendly API for interacting with KDE's KRunner.
///
/// At the moment the API supports writing plugins, also called "runners".
/// This is accomplished by using the [KRunnerPlugin].
///
/// Writing a plugin is as simple as specifying an `identifier` and `name`,
/// along with 3 callback functions: check for matches to a query,
/// supply a list of actions this runner can take, and running an action.
///
/// See the example directory for simple examples.
library krunner;

import 'package:krunner/src/plugin/krunner_plugin.dart';

export 'src/plugin/krunner_plugin.dart';
