import 'package:dbus/dbus.dart';

/// A match that is returned to KRunner in response to a user's query.
class QueryMatch {
  /// A unique ID for this match, for this runner's own internal use.
  ///
  /// Will be included with `action` callbacks.
  final String id;

  /// The main text displayed to the user for this match.
  final String title;

  /// The name of an icon to show with the match.
  ///
  /// Displayed between the [category] and the match's title.
  ///
  /// The names of available icons can be found easily by using
  /// KDE's Icon Viewer tool called "Cuttlefish".
  final String icon;

  /// How closely this match fits the user's query.
  ///
  /// Determines if KRunner will display few or many results for this runner.
  final QueryMatchRating rating;

  /// A secondary match relevance scale from `0.0` to `1.0`.
  ///
  /// [rating] has a higher impact and [relevance] is considered secondary.
  ///
  /// A higher [relevance] causes this runner's results to be listed higher.
  final double relevance;

  /// Optional sub-properties relating to this [QueryMatch].
  final QueryMatchProperties? properties;

  const QueryMatch({
    required this.id,
    required this.title,
    required this.icon,
    required this.rating,
    required this.relevance,
    this.properties,
  });
}

/// Defines how closely the associated [QueryMatch] fits the query.
enum QueryMatchRating {
  /// Indicates this *might* be a match for the query.
  possible,

  /// A match that offers information but no action.
  ///
  /// This match type has a higher ranking than [QueryMatchRating.possible],
  /// and when selected by the user the value is copied to clipboard and
  /// replaces the current search query in their active KRunner interface.
  ///
  /// Examples:
  ///
  /// - A calculator runner could return the result of a calculation.
  /// If the user selects the match the calculation is copied to clipboard.
  ///
  /// - A dictionary runner could return the result of a translation.
  /// If the user selects the match the translation is copied to clipboard.
  information,

  /// Considered as an exact match for the user's query.
  exact,
}

/// Associated numeric values for the enum that KRunner understands.
extension QueryMatchRatingHelper on QueryMatchRating {
  int get value {
    switch (this) {
      case QueryMatchRating.possible:
        return 30;
      case QueryMatchRating.information:
        return 50;
      case QueryMatchRating.exact:
        return 100;
      default:
        return 0; // No match.
    }
  }
}

/// Optional sub-properties relating to a [QueryMatch].
class QueryMatchProperties {
  /// A list of mimetypes associated with this match, if any.
  // KRunner's "urls" property.
  final List<String>? mimetypes;

  /// The category or name this match is associated with,
  /// displayed on the left-hand side of the KRunner match interface.
  ///
  /// Defaults to the `Name` property of the runner's `.desktop` file.
  ///
  /// Leave blank to use the default runner name.
  // KRunner's "category" property.
  final String? category;

  /// Descriptive text for the match. Displayed smaller and
  /// less prominent compared to the title.
  // KRunner's "subtext" property.
  final String? subtitle;

  /// A list of callback function names available for this match, if any.
  ///
  /// If the actions only need to be fetched once (they don't change
  /// between matches for the runner), set the `X-Plasma-Request-Actions-Once`
  /// property of the runner's `.service` file to true.
  // KRunner's "actions" property.
  final List<String>? actions;

  // KRunner's "icon-data" property.
  // final String? iconData;

  const QueryMatchProperties({
    this.mimetypes,
    this.category,
    this.subtitle,
    this.actions,
    // this.iconData,
  });

  DBusDict toDBusDict() {
    return DBusDict.stringVariant({});
  }
}
