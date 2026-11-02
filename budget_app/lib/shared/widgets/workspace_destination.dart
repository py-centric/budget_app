import 'package:flutter/widgets.dart';

/// The workspace navigation families shared by the compact bottom navbar, the
/// collapsed rail and the drawer rows
/// (`specs/040-material-cupertino-ui/contracts/navigation_and_navbar_contract.md`,
/// stage 2).
enum WorkspaceDestination {
  overview,
  breakdown,
  wallet,
  tools,
  preferences;

  /// Maps a declared shell index ([AdaptiveWorkspaceShell.selectedIndex]) to
  /// its family. Mirrors the compact NavigationBar destination order: 0
  /// overview, 1 breakdown, 2 wallet, 3 tools, 4 preferences.
  static WorkspaceDestination fromShellIndex(int index) {
    switch (index) {
      case 1:
        return WorkspaceDestination.breakdown;
      case 2:
        return WorkspaceDestination.wallet;
      case 3:
        return WorkspaceDestination.tools;
      case 4:
        return WorkspaceDestination.preferences;
      default:
        return WorkspaceDestination.overview;
    }
  }
}

/// A drawer navigation row bound to the page it opens.
///
/// [destination] MUST equal the `selectedIndex` the target page declares on its
/// workspace shell, so navbar, rail and drawer can never disagree (FR-013).
/// [pageType] is the target page's widget type and drives the exact row match
/// against the page currently hosting the drawer.
class WorkspaceDrawerRow {
  /// Creates a row descriptor.
  const WorkspaceDrawerRow({
    required this.title,
    required this.pageType,
    required this.destination,
    this.isFamilyAnchor = false,
  });

  /// The row's visible label; unique within the drawer.
  final String title;

  /// The runtime type of the page this row opens.
  final Type pageType;

  /// The navigation family this row belongs to.
  final WorkspaceDestination destination;

  /// Whether this row represents [destination] when no exact row matches
  /// (for example for sub-pages that are not drawer rows themselves).
  final bool isFamilyAnchor;

  /// Whether this row's target page currently hosts [context] (the row's page
  /// is the screen the user is on).
  bool isCurrentPage(BuildContext context) {
    bool found = false;
    context.visitAncestorElements((Element element) {
      if (element.widget.runtimeType == pageType) {
        found = true;
        return false;
      }
      return true;
    });
    return found;
  }
}
