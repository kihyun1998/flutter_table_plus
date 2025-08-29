/// Defines when tooltips should be shown for table cells.
enum TooltipBehavior {
  /// Always show tooltip when textOverflow is TextOverflow.ellipsis.
  /// This is the current default behavior for backward compatibility.
  always,

  /// Never show tooltip, even if textOverflow is TextOverflow.ellipsis.
  never,
}
