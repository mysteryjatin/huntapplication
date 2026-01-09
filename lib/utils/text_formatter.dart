/// Utility class for formatting and cleaning text from AI responses
class TextFormatter {
  /// Removes markdown formatting and emojis from text
  /// 
  /// Removes:
  /// - Markdown headers (#, ##, ###, etc.)
  /// - Markdown bold/italic markers (*, **, _)
  /// - Emojis (Unicode emoji characters)
  /// - Extra whitespace
  static String cleanText(String text) {
    String cleaned = text;

    // Remove markdown headers (#, ##, ###, etc.)
    cleaned = cleaned.replaceAll(RegExp(r'^#{1,6}\s+', multiLine: true), '');

    // Remove markdown bold (**text** or __text__)
    cleaned = cleaned.replaceAll(RegExp(r'\*\*([^*]+)\*\*'), r'$1');
    cleaned = cleaned.replaceAll(RegExp(r'__([^_]+)__'), r'$1');

    // Remove markdown italic (*text* or _text_)
    cleaned = cleaned.replaceAll(RegExp(r'(?<!\*)\*([^*]+)\*(?!\*)'), r'$1');
    cleaned = cleaned.replaceAll(RegExp(r'(?<!_)_([^_]+)_(?!_)'), r'$1');

    // Remove markdown list markers (-, *, +) but keep numbered lists
    cleaned = cleaned.replaceAll(RegExp(r'^[-*+]\s+', multiLine: true), '');
    // Don't remove numbered lists - they're needed for parsing

    // Remove emojis - using a simpler approach that works with Dart
    // Remove common emoji patterns by filtering characters
    final runes = cleaned.runes.toList();
    final filteredRunes = <int>[];
    
    for (final rune in runes) {
      // Keep ASCII printable characters (32-126)
      if (rune >= 32 && rune <= 126) {
        filteredRunes.add(rune);
      }
      // Keep newlines, carriage returns, and tabs
      else if (rune == 10 || rune == 13 || rune == 9) {
        filteredRunes.add(rune);
      }
      // Keep common Unicode text ranges but exclude emoji ranges
      else if (rune >= 0x00A0 && rune <= 0x024F) { // Latin Extended
        filteredRunes.add(rune);
      }
      else if (rune >= 0x2000 && rune <= 0x206F) { // General Punctuation
        // Exclude zero width joiner and combining keycap which are used in emojis
        if (rune != 0x200D && rune != 0x20E3) {
          filteredRunes.add(rune);
        }
      }
      else if (rune >= 0x2070 && rune <= 0x209F) { // Superscripts and Subscripts
        filteredRunes.add(rune);
      }
      else if (rune >= 0x20A0 && rune <= 0x20CF) { // Currency Symbols
        filteredRunes.add(rune);
      }
      // Keep Indian script characters (Devanagari, etc.)
      else if (rune >= 0x0900 && rune <= 0x097F) { // Devanagari
        filteredRunes.add(rune);
      }
      else if (rune >= 0x0980 && rune <= 0x09FF) { // Bengali
        filteredRunes.add(rune);
      }
      else if (rune >= 0x0A00 && rune <= 0x0A7F) { // Gurmukhi
        filteredRunes.add(rune);
      }
      else if (rune >= 0x0A80 && rune <= 0x0AFF) { // Gujarati
        filteredRunes.add(rune);
      }
      else if (rune >= 0x0B00 && rune <= 0x0B7F) { // Oriya
        filteredRunes.add(rune);
      }
      else if (rune >= 0x0B80 && rune <= 0x0BFF) { // Tamil
        filteredRunes.add(rune);
      }
      else if (rune >= 0x0C00 && rune <= 0x0C7F) { // Telugu
        filteredRunes.add(rune);
      }
      else if (rune >= 0x0C80 && rune <= 0x0CFF) { // Kannada
        filteredRunes.add(rune);
      }
      else if (rune >= 0x0D00 && rune <= 0x0D7F) { // Malayalam
        filteredRunes.add(rune);
      }
      // Exclude all other Unicode ranges (which include emojis)
      // This effectively removes emojis while keeping text
    }
    
    cleaned = String.fromCharCodes(filteredRunes);

    // Clean up extra whitespace
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');
    cleaned = cleaned.replaceAll(RegExp(r'\n\s*\n\s*\n'), '\n\n');

    // Trim each line
    cleaned = cleaned.split('\n').map((line) => line.trim()).join('\n');

    return cleaned.trim();
  }
}
