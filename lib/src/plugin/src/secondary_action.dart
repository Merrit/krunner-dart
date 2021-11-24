/// Secondary actions appear in runner results as icons to the right
/// of the match's title.
class SecondaryAction {
  /// A unique ID to identify this action if asked to run it.
  final String id;

  /// Text to show if the user hovers the mouse over the icon.
  final String text;

  /// Name of the icon to display for this secondary action.
  ///
  /// Names for icons can be easily found using KDE's `Cuttlefish` icon browser.
  final String icon;

  const SecondaryAction({
    required this.id,
    required this.text,
    required this.icon,
  });
}
