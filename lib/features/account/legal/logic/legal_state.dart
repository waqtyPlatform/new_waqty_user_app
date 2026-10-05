enum LegalTab { privacy, terms }

class LegalState {
  final LegalTab selectedTab;

  const LegalState({required this.selectedTab});
}
